// Edge Function que se ejecuta diariamente via cron de Supabase
// Busca productos de una lista fija en ambas tiendas y guarda los precios en historial_precios

import { createClient } from "jsr:@supabase/supabase-js@2";

// Lista de búsquedas a ejecutar diariamente
const PRODUCTOS_A_MONITOREAR = [
  "leche",
  "arroz",
  "aceite",
  "frijol",
  "azucar",
  "sal",
  "pan",
  "atun",
  "pasta",
  "cereal",
  "jamon",
];

// Tiendas VTEX a consultar
const TIENDAS: Record<string, string> = {
  "Walmart GT": "https://www.walmart.com.gt",
  "La Torre": "https://www.latorre.com.gt",
};

const HEADERS = {
  "User-Agent":
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/124.0.0.0 Safari/537.36",
  "Accept": "application/json",
};

// Extrae el EAN del producto desde la respuesta VTEX
function extraerEan(item: Record<string, unknown>): string | null {
  try {
    const items = item["items"] as Record<string, unknown>[];
    if (!items?.length) return null;

    const eanDirecto = items[0]["ean"];
    if (eanDirecto) return String(eanDirecto).replace(/^0+/, "") || null;

    const ref = items[0]["referenceId"] as Record<string, string>[];
    for (const r of ref ?? []) {
      if (r["Key"] === "EAN" || r["Key"] === "RefId") {
        return r["Value"]?.replace(/^0+/, "") || null;
      }
    }
  } catch {
    return null;
  }
  return null;
}

// Extrae el precio de venta del producto
function extraerPrecio(item: Record<string, unknown>): number | null {
  try {
    const items = item["items"] as Record<string, unknown>[];
    const sellers = items?.[0]?.["sellers"] as Record<string, unknown>[];
    const offer = sellers?.[0]?.["commertialOffer"] as Record<string, unknown>;
    const precio = offer?.["Price"] ?? offer?.["ListPrice"];
    return precio ? Number(precio) : null;
  } catch {
    return null;
  }
}

// Busca TODOS los productos en una tienda VTEX paginando de 50 en 50
async function buscarEnTienda(
  tienda: string,
  baseUrl: string,
  query: string,
): Promise<
  {
    ean: string;
    tienda: string;
    nombre: string;
    marca: string;
    precio: number;
  }[]
> {
  const resultados = [];
  const pageSize = 50;
  let desde = 0;

  while (true) {
    const url =
      `${baseUrl}/api/catalog_system/pub/products/search?ft=${query}&_from=${desde}&_to=${
        desde + pageSize - 1
      }`;

    try {
      const resp = await fetch(url, { headers: HEADERS });
      if (!resp.ok) break;

      const productos = await resp.json() as Record<string, unknown>[];

      // Si no hay más productos, terminar paginación
      if (!productos.length) break;

      for (const item of productos) {
        const ean = extraerEan(item);
        const precio = extraerPrecio(item);
        if (!ean || !precio) continue;

        resultados.push({
          ean,
          tienda,
          nombre: String(item["productName"] ?? "Sin nombre"),
          marca: String(item["brand"] ?? ""),
          precio,
        });
      }

      // Si devolvió menos de pageSize, no hay más páginas
      if (productos.length < pageSize) break;

      desde += pageSize;

      // Pausa de 500ms entre páginas para no saturar la API VTEX
      await new Promise((resolve) => setTimeout(resolve, 500));
    } catch {
      break;
    }
  }

  return resultados;
}

Deno.serve(async (_req) => {
  try {
    // Inicializar cliente Supabase con variables de entorno del proyecto
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    const hace24h = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
    let insertados = 0;
    let omitidos = 0;

    for (const query of PRODUCTOS_A_MONITOREAR) {
      // Buscar en ambas tiendas en paralelo
      const resultados = await Promise.all(
        Object.entries(TIENDAS).map(([tienda, baseUrl]) =>
          buscarEnTienda(tienda, baseUrl, query)
        ),
      );

      const todos = resultados.flat();

      for (const p of todos) {
        // Verificar si ya existe un registro reciente (últimas 24h)
        const { data: existe } = await supabase
          .from("historial_precios")
          .select("id")
          .eq("ean", p.ean)
          .eq("tienda", p.tienda)
          .gte("fecha", hace24h)
          .limit(1);

        if (existe && existe.length > 0) {
          omitidos++;
          continue;
        }

        // Insertar nuevo registro de precio
        await supabase.from("historial_precios").insert({
          ean: p.ean,
          tienda: p.tienda,
          nombre: p.nombre,
          marca: p.marca,
          precio: p.precio,
        });

        insertados++;
      }
    }

    return new Response(
      JSON.stringify({
        ok: true,
        insertados,
        omitidos,
        productos_monitoreados: PRODUCTOS_A_MONITOREAR.length,
      }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ ok: false, error: String(error) }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});
