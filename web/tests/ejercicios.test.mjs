// Pruebas de la lógica pura de web/ojs/ejercicios.js (corrección de ejercicios).
import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

globalThis.__EJ_TEST__ = true;
const aqui = dirname(fileURLToPath(import.meta.url));
// El módulo es un IIFE para el navegador: se evalúa y se recogen sus exportaciones de prueba.
new Function(readFileSync(join(aqui, "..", "ojs", "ejercicios.js"), "utf8"))();
const { parseNumero, parseTolerancia, comprobarNumerico, normalizaVF, mismasOpciones } = globalThis.__EJ_EXPORTS__;

test("parseNumero admite coma decimal, notación científica y unidades", () => {
  assert.equal(parseNumero("0,0307"), 0.0307);
  assert.equal(parseNumero("3.07e-2"), 0.0307);
  assert.equal(parseNumero("3,07·10^-2"), 0.0307);
  assert.equal(parseNumero("30,7 mm"), 30.7);
  assert.equal(parseNumero("−2,5"), -2.5);
  assert.ok(Number.isNaN(parseNumero("abc")));
});

test("parseTolerancia distingue relativa y absoluta", () => {
  assert.deepEqual(parseTolerancia("1%"), { tipo: "rel", valor: 0.01 });
  assert.deepEqual(parseTolerancia("abs:0.05"), { tipo: "abs", valor: 0.05 });
  assert.deepEqual(parseTolerancia(""), { tipo: "rel", valor: 0.01 });
});

test("comprobarNumerico respeta la tolerancia", () => {
  assert.equal(comprobarNumerico("19,6", 19.596, "0.5%").ok, true);
  assert.equal(comprobarNumerico("20", 19.596, "0.5%").ok, false);
  assert.equal(comprobarNumerico("x", 1, "1%").invalida, true);
});

test("normalizaVF y mismasOpciones", () => {
  assert.equal(normalizaVF("Sí"), "verdadero");
  assert.equal(normalizaVF("falso"), "falso");
  assert.equal(mismasOpciones("c, a", "a,c"), true);
  assert.equal(mismasOpciones("a", "a,c"), false);
});
