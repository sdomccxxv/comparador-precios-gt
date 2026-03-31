from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
import httpx
import asyncio

app = FastAPI(title="Comparador de Precios GT")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    ),
    "Accept": "application/json",
}

TIENDAS = {
    "Walmart GT": "https://www.walmart.com.gt",
    "La Torre":   "https://www.latorre.com.gt",
}


def extraer_precio(item: dict) -> float | None:
    try:
        items = item.get("items", [])
        if items:
            sellers = items[0].get("sellers", [])
            if sellers:
                offer = sellers[0].get("commertialOffer", {})
                precio = offer.get("Price") or offer.get("ListPrice")
                return float(precio) if precio else None
    except Exception:
        pass
    return None


def extraer_imagen(item: dict) -> str | None:
    try:
        items = item.get("items", [])
        if items:
            images = items[0].get("images", [])
            if images:
                return images[0].get("imageUrl")
    except (KeyError, IndexError, TypeError):
        return None
    
def extraer_ean(item: dict) -> str | None:
    try:
        items = item.get("items", [])
        if not items:
            return None

        ean_directo = items[0].get("ean")
        if ean_directo:
            return str(ean_directo)

        ref = items[0].get("referenceId", [])
        for r in ref:
            if r.get("Key") in ("EAN", "RefId"):
                return r.get("Value")
    except (KeyError, IndexError, TypeError):
        pass
    return None


def formatear_producto(item: dict, tienda: str, base_url: str) -> dict | None:
    precio = extraer_precio(item)
    if precio is None:
        return None

    link = item.get("linkText", "")
    return {
        "tienda":  tienda,
        "nombre":  item.get("productName", "Sin nombre"),
        "marca":   item.get("brand", ""),
        "precio":  precio,
        "url":     f"{base_url}/{link}/p",
        "imagen":  extraer_imagen(item),
        "ean":     extraer_ean(item),
    }


async def buscar_en_tienda(
    client: httpx.AsyncClient,
    tienda: str,
    base_url: str,
    query: str,
) -> list[dict]:
    url = (
        f"{base_url}/api/catalog_system/pub/products/search"
        f"?ft={query}&_from=0&_to=19"
    )
    try:
        resp = await client.get(url, headers=HEADERS, timeout=12)
        print(f"[{tienda}] Status: {resp.status_code}")
        
        # Aceptamos 200 y 206 (Partial Content)
        if resp.status_code not in (200, 206):
            print(f"[{tienda}] Status inesperado: {resp.status_code}")
            return []
        
        productos = resp.json()
        print(f"[{tienda}] Productos recibidos: {len(productos)}")
        resultados = []
        for item in productos:
            p = formatear_producto(item, tienda, base_url)
            if p:
                resultados.append(p)
        print(f"[{tienda}] Productos con precio: {len(resultados)}")

        #if productos:
        #    print(f"[{tienda}] Keys: {list(productos[0].keys())}")
        
        return resultados
    except Exception as e:
        print(f"[{tienda}] Error: {e}")
        return []

@app.get("/")
def root():
    return {"mensaje": "Comparador de Precios GT funcionando ✅"}


@app.get("/buscar")
async def buscar(
    q: str = Query(..., min_length=1, description="Producto a buscar")
):
    async with httpx.AsyncClient() as client:
        tareas = [
            buscar_en_tienda(client, tienda, base_url, q)
            for tienda, base_url in TIENDAS.items()
        ]
        resultados_por_tienda = await asyncio.gather(*tareas)

    todos = [p for lista in resultados_por_tienda for p in lista]

    # Encontrar EANs que aparecen en ambas tiendas
    eans_walmart = {p["ean"] for p in todos if p["tienda"] == "Walmart GT" and p["ean"]}
    eans_torre   = {p["ean"] for p in todos if p["tienda"] == "La Torre"   and p["ean"]}
    eans_comunes = eans_walmart & eans_torre

    # Marcar productos que coinciden en ambas tiendas
    for p in todos:
        p["coincide_ambas"] = p["ean"] in eans_comunes if p["ean"] else False

    # Ordenar: primero los que coinciden en ambas, luego por precio
    todos.sort(key=lambda x: (not x["coincide_ambas"], x["precio"]))

    walmart = [p for p in todos if p["tienda"] == "Walmart GT"]
    torre   = [p for p in todos if p["tienda"] == "La Torre"]

    return {
        "query":          q,
        "total":          len(todos),
        "walmart_count":  len(walmart),
        "latorre_count":  len(torre),
        "coincidencias":  len(eans_comunes),
        "resultados":     todos,
    }