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

def extraer_list_price(item: dict) -> float | None:
    try:
        items = item.get("items", [])
        if items:
            sellers = items[0].get("sellers", [])
            if sellers:
                offer = sellers[0].get("commertialOffer", {})
                list_price = offer.get("ListPrice")
                return float(list_price) if list_price else None
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
            return str(ean_directo).lstrip('0') or None

        ref = items[0].get("referenceId", [])
        for r in ref:
            if r.get("Key") in ("EAN", "RefId"):
                valor = r.get("Value", "")
                return valor.lstrip('0') or None
    except (KeyError, IndexError, TypeError):
        pass
    return None


def formatear_producto(item: dict, tienda: str, base_url: str) -> dict | None:
    precio = extraer_precio(item)
    if precio is None:
        return None

    list_price = extraer_list_price(item)
    link = item.get("linkText", "")
    return {
        "tienda":      tienda,
        "nombre":      item.get("productName", "Sin nombre"),
        "marca":       item.get("brand", ""),
        "precio":      precio,
        "precio_antes": list_price if list_price and list_price > precio else None,
        "url":         f"{base_url}/{link}/p",
        "imagen":      extraer_imagen(item),
        "ean":         extraer_ean(item),
    }


def _marcar_y_ordenar(todos: list[dict]) -> tuple[list[dict], set]:
    eans_walmart = {p["ean"] for p in todos if p["tienda"] == "Walmart GT" and p["ean"]}
    eans_torre   = {p["ean"] for p in todos if p["tienda"] == "La Torre"   and p["ean"]}
    eans_comunes = eans_walmart & eans_torre

    for p in todos:
        p["coincide_ambas"] = p["ean"] in eans_comunes if p["ean"] else False

    todos.sort(key=lambda x: (not x["coincide_ambas"], x["precio"]))
    return todos, eans_comunes


async def buscar_en_tienda(
    client: httpx.AsyncClient,
    tienda: str,
    base_url: str,
    query: str,
) -> list[dict]:
    url = (
        f"{base_url}/api/catalog_system/pub/products/search"
        f"?ft={query}&_from=0&_to=49"
    )
    try:
        resp = await client.get(url, headers=HEADERS, timeout=12)
        print(f"[{tienda}] Status: {resp.status_code}")

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
        return resultados
    except Exception as e:
        print(f"[{tienda}] Error: {e}")
        return []


async def buscar_en_tienda_por_ean(
    client: httpx.AsyncClient,
    tienda: str,
    base_url: str,
    ean: str,
) -> list[dict]:
    # Normalizar EAN: quitar ceros a la izquierda para comparar
    ean_norm = ean.lstrip('0')

    # VTEX endpoint específico para buscar por EAN
    url = (
        f"{base_url}/api/catalog_system/pub/products/search"
        f"?fq=alternateIds_Ean:{ean}&_from=0&_to=5"
    )
    try:
        resp = await client.get(url, headers=HEADERS, timeout=12)
        print(f"[{tienda}] EAN Status: {resp.status_code}")

        if resp.status_code not in (200, 206):
            return []

        productos = resp.json()
        print(f"[{tienda}] EAN Productos recibidos: {len(productos)}")

        # Si no encuentra con el EAN original, intentar con ceros adicionales
        if not productos and not ean.startswith('0'):
            url2 = (
                f"{base_url}/api/catalog_system/pub/products/search"
                f"?fq=alternateIds_Ean:0{ean}&_from=0&_to=5"
            )
            resp2 = await client.get(url2, headers=HEADERS, timeout=12)
            if resp2.status_code in (200, 206):
                productos = resp2.json()
                print(f"[{tienda}] EAN con 0 Productos: {len(productos)}")

        resultados = []
        for item in productos:
            p = formatear_producto(item, tienda, base_url)
            if p:
                resultados.append(p)
        return resultados
    except Exception as e:
        print(f"[{tienda}] Error EAN: {e}")
        return []


@app.get("/")
def root():
    return {"mensaje": "Comparador de Precios GT funcionando ✅"}


@app.get("/health")
def health():
    return {"status": "ok"}


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
    todos, eans_comunes = _marcar_y_ordenar(todos)

    walmart = [p for p in todos if p["tienda"] == "Walmart GT"]
    torre   = [p for p in todos if p["tienda"] == "La Torre"]

    return {
        "query":         q,
        "total":         len(todos),
        "walmart_count": len(walmart),
        "latorre_count": len(torre),
        "coincidencias": len(eans_comunes),
        "resultados":    todos,
    }


@app.get("/buscar-ean")
async def buscar_por_ean(
    ean: str = Query(..., min_length=1, description="EAN a buscar")
):
    async with httpx.AsyncClient() as client:
        tareas = [
            buscar_en_tienda_por_ean(client, tienda, base_url, ean)
            for tienda, base_url in TIENDAS.items()
        ]
        resultados_por_tienda = await asyncio.gather(*tareas)

    todos = [p for lista in resultados_por_tienda for p in lista]

    # Si no encontró nada por EAN exacto, hacer búsqueda por texto como fallback
    if not todos:
        print(f"[EAN] Sin resultados para {ean}, usando búsqueda por texto")
        async with httpx.AsyncClient() as client:
            tareas = [
                buscar_en_tienda(client, tienda, base_url, ean)
                for tienda, base_url in TIENDAS.items()
            ]
            resultados_por_tienda = await asyncio.gather(*tareas)
        todos = [p for lista in resultados_por_tienda for p in lista]

    todos, eans_comunes = _marcar_y_ordenar(todos)

    walmart = [p for p in todos if p["tienda"] == "Walmart GT"]
    torre   = [p for p in todos if p["tienda"] == "La Torre"]

    return {
        "query":         ean,
        "total":         len(todos),
        "walmart_count": len(walmart),
        "latorre_count": len(torre),
        "coincidencias": len(eans_comunes),
        "resultados":    todos,
    }