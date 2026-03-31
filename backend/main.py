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
        sellers = item.get("sellers", [])
        if sellers:
            offer = sellers[0].get("commertialOffer", {})
            precio = offer.get("Price") or offer.get("ListPrice")
            return float(precio) if precio else None
    except Exception:
        pass
    return None


def extraer_imagen(item: dict) -> str | None:
    try:
        return item["items"][0]["images"][0]["imageUrl"]
    except (KeyError, IndexError, TypeError):
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
        resp.raise_for_status()
        productos = resp.json()
        resultados = []
        for item in productos:
            p = formatear_producto(item, tienda, base_url)
            if p:
                resultados.append(p)
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
    todos.sort(key=lambda x: x["precio"])

    walmart = [p for p in todos if p["tienda"] == "Walmart GT"]
    torre   = [p for p in todos if p["tienda"] == "La Torre"]

    return {
        "query":         q,
        "total":         len(todos),
        "walmart_count": len(walmart),
        "latorre_count": len(torre),
        "resultados":    todos,
    }