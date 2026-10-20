// Verificación cruzada JS ↔ Julia. Ejecutar: node --test web/tests/
import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { analizar, baseDesdeAngulo, dibujarSVG } from "../ojs/bases.js";

const ref = JSON.parse(
  readFileSync(new URL("../datos/bases_ref.json", import.meta.url), "utf8"),
);
const cerca = (a, b, tol = 1e-12) => assert.ok(Math.abs(a - b) <= tol, `${a} ≠ ${b}`);
const cercaV = (a, b) => a.forEach((x, i) => cerca(x, b[i]));

for (const [k, c] of ref.casos.entries()) {
  test(`caso ${k + 1}: coincide con Julia ${ref.julia}`, () => {
    const r = analizar(c.g1, c.g2, c.V);
    c.g.forEach((fila, i) => cercaV(r.g[i], fila));
    cercaV(r.d1, c.d1);
    cercaV(r.d2, c.d2);
    cercaV(r.contra, c.contra);
    cercaV(r.co, c.co);
    cercaV(r.reciprocidad[0], [1, 0]); // gⁱ·gⱼ = δⁱⱼ
    cercaV(r.reciprocidad[1], [0, 1]);
  });
}

test("base degenerada lanza error", () => {
  assert.throws(() => analizar([1, 0], [2, 0], [1, 1]));
});

test("baseDesdeAngulo y SVG se generan", () => {
  const { g1, g2 } = baseDesdeAngulo(1, 1, 70);
  const r = analizar(g1, g2, [1, 1]);
  const svg = dibujarSVG(g1, g2, [1, 1], r);
  assert.match(svg, /^<svg/);
  assert.ok(!svg.includes("NaN"));
});
