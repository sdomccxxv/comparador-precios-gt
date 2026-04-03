import pytest
from main import _marcar_y_ordenar, extraer_precio, extraer_ean, TIENDAS


def test_tiendas_configuradas():
    assert "Walmart GT" in TIENDAS
    assert "La Torre" in TIENDAS
    assert "Paiz" in TIENDAS
    assert "Maxi Despensa" in TIENDAS


def test_marcar_y_ordenar_ean_comun():
    productos = [
        {"tienda": "Walmart GT", "ean": "123", "precio": 10.0, "coincide_ambas": False},
        {"tienda": "Paiz",       "ean": "123", "precio": 12.0, "coincide_ambas": False},
        {"tienda": "La Torre",   "ean": "999", "precio": 5.0,  "coincide_ambas": False},
    ]
    resultado, eans_comunes = _marcar_y_ordenar(productos)
    assert "123" in eans_comunes
    assert "999" not in eans_comunes
    assert resultado[0]["ean"] == "123"


def test_marcar_y_ordenar_sin_ean():
    productos = [
        {"tienda": "Walmart GT", "ean": None, "precio": 5.0, "coincide_ambas": False},
        {"tienda": "La Torre",   "ean": None, "precio": 3.0, "coincide_ambas": False},
    ]
    resultado, eans_comunes = _marcar_y_ordenar(productos)
    assert len(eans_comunes) == 0
    assert not any(p["coincide_ambas"] for p in resultado)


def test_marcar_y_ordenar_orden_precio():
    productos = [
        {"tienda": "Walmart GT", "ean": None, "precio": 20.0, "coincide_ambas": False},
        {"tienda": "La Torre",   "ean": None, "precio": 10.0, "coincide_ambas": False},
    ]
    resultado, _ = _marcar_y_ordenar(productos)
    assert resultado[0]["precio"] == 10.0


def test_extraer_precio_valido():
    item = {"items": [{"sellers": [{"commertialOffer": {"Price": 25.5, "ListPrice": 30.0}}]}]}
    assert extraer_precio(item) == 25.5


def test_extraer_precio_item_vacio():
    assert extraer_precio({}) is None
    assert extraer_precio({"items": []}) is None


def test_extraer_ean():
    item = {"items": [{"ean": "0012345678901", "referenceId": []}]}
    assert extraer_ean(item) == "12345678901"