import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { polarBase, polarComps, christoffelPolar, hypar, curvaturasPrincipales, euler, dibujarPolar, dibujarEuler } from "../ojs/laboratorios.js";

const ref = JSON.parse(readFileSync(join(dirname(fileURLToPath(import.meta.url)), "..", "datos", "labs_ref.json"), "utf8"));
const cerca = (a, b, tol = 1e-5) => assert.ok(Math.abs(a - b) <= tol, `${a} ≠ ${b}`);
const cercaV = (a, b, tol) => a.forEach((x, i) => (Array.isArray(x) ? cercaV(x, b[i], tol) : cerca(x, b[i], tol)));

test("polares: métrica y componentes coinciden con Geometria", () => {
  ref.polares.forEach((c) => {
    cercaV(polarBase(c.r, c.t).metric, c.g);
    const { up, dn } = polarComps(c.r, c.t, c.V);
    cercaV(up, c.up); cercaV(dn, c.dn);
  });
});

test("polares: Christoffel", () => {
  const { G122, G212 } = christoffelPolar(2);
  assert.equal(G122, -2); assert.equal(G212, 0.5);
});

test("paraboloide: aαβ, bαβ, K, H y curvaturas principales", () => {
  ref.hypar.forEach((c) => {
    const h = hypar(c.Rx, c.Ry, c.x, c.y);
    cercaV(h.a, c.a); cercaV(h.b, c.b);
    cerca(h.K, c.K); cerca(h.H, c.H);
    cercaV(h.k, c.k);
  });
});

test("Euler coincide con la referencia y con el cálculo directo", () => {
  ref.euler.forEach((c) => cerca(euler(c.k1, c.k2, c.phi), c.kappa, 1e-12));
  const a = [[1, 0], [0, 1]], b = [[0.2, 0.1], [0.1, -0.3]];
  const pc = curvaturasPrincipales(a, b);
  assert.ok(pc.k[0] <= pc.k[1]);
  cerca(pc.K, 0.2 * -0.3 - 0.01, 1e-12);
});

test("las figuras SVG se generan", () => {
  assert.ok(dibujarPolar(2, 0.5, [1, 0]).includes("<svg"));
  assert.ok(dibujarEuler(-0.3, 0.46).includes("<polygon"));
});
