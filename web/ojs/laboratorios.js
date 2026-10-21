// Módulo de los laboratorios interactivos de los Bloques B y C.
// Las fórmulas se verifican contra Geometria (Julia) con web/tests/laboratorios.test.mjs
// y web/datos/labs_ref.json (generado por julia/scripts/generar_referencia_labs.jl).

const AZUL = "#1b6ca8", NARANJA = "#d95f02", VERDE = "#2a9d8f", GRIS = "#6b7280", VIOLETA = "#6f42c1", MALLA = "#cbd5e1";
const f2 = (x) => (Math.abs(x) < 5e-10 ? 0 : x).toFixed(3);

/* ---------------------------------------------------------------- Polares (B1, B4) */

/** Base natural y jacobiana de las coordenadas polares en (r, θ). */
export function polarBase(r, t) {
  const g1 = [Math.cos(t), Math.sin(t)];
  const g2 = [-r * Math.sin(t), r * Math.cos(t)];
  // ∂(x,y)/∂(r,θ) tiene columnas g1, g2; ∂(r,θ)/∂(x,y) es su inversa
  const det = g1[0] * g2[1] - g2[0] * g1[1];
  const jac = [[g2[1] / det, -g2[0] / det], [-g1[1] / det, g1[0] / det]];
  return { g1, g2, metric: [[1, 0], [0, r * r]], det, jac };
}

/** Componentes contravariantes y covariantes polares de un vector cartesiano. */
export function polarComps(r, t, V) {
  const { g1, g2, jac } = polarBase(r, t);
  const up = [jac[0][0] * V[0] + jac[0][1] * V[1], jac[1][0] * V[0] + jac[1][1] * V[1]];
  const dn = [V[0] * g1[0] + V[1] * g1[1], V[0] * g2[0] + V[1] * g2[1]];
  return { up, dn };
}

/** Símbolos de Christoffel no nulos de las polares: Γ¹₂₂ = −r, Γ²₁₂ = Γ²₂₁ = 1/r. */
export function christoffelPolar(r) {
  return { G122: -r, G212: 1 / r };
}

/** Figura SVG: malla polar, base natural en el punto y vector V (cartesiano). */
export function dibujarPolar(r, t, V, ancho = 480, alto = 400) {
  const s = 62, ox = 60, oy = alto - 50;
  const X = (p) => ox + s * p[0], Y = (p) => oy - s * p[1];
  const { g1, g2 } = polarBase(r, t);
  const P = [r * Math.cos(t), r * Math.sin(t)];
  const flecha = (a, b, c, w, et, dash = "") => {
    const ang = Math.atan2(-(Y(b) - Y(a)), X(b) - X(a));
    const h1 = [X(b) - 9 * Math.cos(ang - 0.4), Y(b) + 9 * Math.sin(ang - 0.4)];
    const h2 = [X(b) - 9 * Math.cos(ang + 0.4), Y(b) + 9 * Math.sin(ang + 0.4)];
    return `<line x1="${X(a)}" y1="${Y(a)}" x2="${X(b)}" y2="${Y(b)}" stroke="${c}" stroke-width="${w}" ${dash && `stroke-dasharray="${dash}"`}/><polygon points="${X(b)},${Y(b)} ${h1} ${h2}" fill="${c}"/><text x="${X(b) + 6}" y="${Y(b) - 6}" fill="${c}" font-size="14" font-style="italic">${et}</text>`;
  };
  let malla = "";
  for (let k = 1; k <= 5; k++) {
    let d = "";
    for (let i = 0; i <= 40; i++) {
      const a = (i / 40) * Math.PI / 2;
      d += `${i ? "L" : "M"}${X([k * Math.cos(a), 0])},${Y([0, k * Math.sin(a)])} `;
    }
    malla += `<path d="${d}" fill="none" stroke="${MALLA}"/>`;
  }
  for (let i = 0; i <= 6; i++) {
    const a = (i / 6) * Math.PI / 2;
    malla += `<line x1="${X([0, 0])}" y1="${Y([0, 0])}" x2="${X([5.5 * Math.cos(a), 0])}" y2="${Y([0, 5.5 * Math.sin(a)])}" stroke="${MALLA}"/>`;
  }
  const g2n = [g2[0] / r, g2[1] / r];
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${ancho} ${alto}" role="img" aria-label="Malla polar con la base natural y un vector en un punto" style="max-width:100%;height:auto">
${malla}${flecha(P, [P[0] + g1[0], P[1] + g1[1]], AZUL, 2.6, "g₁")}${flecha(P, [P[0] + g2n[0], P[1] + g2n[1]], AZUL, 2.6, "g₂/r")}${flecha(P, [P[0] + V[0], P[1] + V[1]], VIOLETA, 3, "V")}<circle cx="${X(P)}" cy="${Y(P)}" r="3.5" fill="#1f2937"/></svg>`;
}

/* ------------------------------------------------ Curvaturas y paraboloide (C3, C5) */

/** Curvaturas principales y direcciones a partir de aαβ y bαβ (matrices 2×2 simétricas). */
export function curvaturasPrincipales(a, b) {
  const det = a[0][0] * a[1][1] - a[0][1] * a[1][0];
  const ainv = [[a[1][1] / det, -a[0][1] / det], [-a[1][0] / det, a[0][0] / det]];
  // bᵅᵦ = aᵅᵞ bᵞᵦ
  const m = [
    [ainv[0][0] * b[0][0] + ainv[0][1] * b[1][0], ainv[0][0] * b[0][1] + ainv[0][1] * b[1][1]],
    [ainv[1][0] * b[0][0] + ainv[1][1] * b[1][0], ainv[1][0] * b[0][1] + ainv[1][1] * b[1][1]],
  ];
  const tr = m[0][0] + m[1][1], dt = m[0][0] * m[1][1] - m[0][1] * m[1][0];
  const disc = Math.sqrt(Math.max(tr * tr / 4 - dt, 0));
  const k1 = tr / 2 - disc, k2 = tr / 2 + disc;
  return { k: [k1, k2], K: dt, H: tr / 2, mixto: m };
}

/** Tensores del paraboloide z = −½(x²/Rx + y²/Ry) en (x, y), con normal hacia +z. */
export function hypar(Rx, Ry, x, y) {
  const w2 = 1 + (x / Rx) ** 2 + (y / Ry) ** 2, w = Math.sqrt(w2);
  const a = [[1 + (x / Rx) ** 2, (x * y) / (Rx * Ry)], [(x * y) / (Rx * Ry), 1 + (y / Ry) ** 2]];
  const b = [[-1 / (Rx * w), 0], [0, -1 / (Ry * w)]];
  return { a, b, a_det: w2, ...curvaturasPrincipales(a, b) };
}

/** Curvatura normal en la dirección que forma el ángulo φ con la primera dirección principal (Euler). */
export function euler(k1, k2, phi) {
  return k1 * Math.cos(phi) ** 2 + k2 * Math.sin(phi) ** 2;
}

/** Figura SVG de κ(φ) (lóbulos: azul positivo, naranja negativo). */
export function dibujarEuler(k1, k2, ancho = 360, alto = 360) {
  const c = ancho / 2, kmax = Math.max(Math.abs(k1), Math.abs(k2), 1e-9), esc = (c - 40) / kmax;
  let azul = "", naranja = "";
  for (let i = 0; i < 720; i++) {
    const a0 = (i / 720) * 2 * Math.PI, a1 = ((i + 1) / 720) * 2 * Math.PI;
    const k = euler(k1, k2, (a0 + a1) / 2);
    const p = (a) => `${c + esc * Math.abs(euler(k1, k2, a)) * Math.cos(a)},${c - esc * Math.abs(euler(k1, k2, a)) * Math.sin(a)}`;
    const tri = `<polygon points="${c},${c} ${p(a0)} ${p(a1)}" fill="${k >= 0 ? AZUL : NARANJA}" fill-opacity="0.4"/>`;
    if (k >= 0) azul += tri; else naranja += tri;
  }
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${ancho} ${alto}" role="img" aria-label="Curvatura normal en función del ángulo (lóbulos azules positivos y naranjas negativos)" style="max-width:100%;height:auto">
<line x1="10" y1="${c}" x2="${ancho - 10}" y2="${c}" stroke="${GRIS}"/><line x1="${c}" y1="10" x2="${c}" y2="${alto - 10}" stroke="${GRIS}"/>${azul}${naranja}
<text x="${ancho - 30}" y="${c - 8}" fill="${GRIS}" font-size="13" font-style="italic">λ₁</text><text x="${c + 8}" y="22" fill="${GRIS}" font-size="13" font-style="italic">λ₂</text></svg>`;
}

/** Texto de resultados con 3 decimales. */
export const fmt = f2;
