// Bases covariantes y contravariantes en el plano.
// Mismo convenio que julia/src/Geometria.jl: g1, g2 son los vectores de la base
// covariante, dados por sus componentes cartesianas ortonormales.
// Se verifica contra web/datos/bases_ref.json (generado por Julia).

const dot = (a, b) => a[0] * b[0] + a[1] * b[1];

/** Analiza la base {g1,g2} y el vector V (cartesiano). */
export function analizar(g1, g2, V) {
  const g = [
    [dot(g1, g1), dot(g1, g2)],
    [dot(g2, g1), dot(g2, g2)],
  ];
  const det = g[0][0] * g[1][1] - g[0][1] * g[1][0];
  if (Math.abs(det) < 1e-12) throw new Error("Base degenerada: det(g_ij) ≈ 0");
  const ginv = [
    [g[1][1] / det, -g[0][1] / det],
    [-g[1][0] / det, g[0][0] / det],
  ];
  // g^i = g^{ij} g_j
  const d1 = [ginv[0][0] * g1[0] + ginv[0][1] * g2[0], ginv[0][0] * g1[1] + ginv[0][1] * g2[1]];
  const d2 = [ginv[1][0] * g1[0] + ginv[1][1] * g2[0], ginv[1][0] * g1[1] + ginv[1][1] * g2[1]];
  return {
    g,
    ginv,
    d1,
    d2,
    reciprocidad: [
      [dot(d1, g1), dot(d1, g2)],
      [dot(d2, g1), dot(d2, g2)],
    ],
    contra: [dot(V, d1), dot(V, d2)], // V^i = V·g^i
    co: [dot(V, g1), dot(V, g2)],     // V_i = V·g_i
  };
}

/** Construye g1, g2 a partir de longitudes y ángulo (grados) entre ellos. */
export function baseDesdeAngulo(l1, l2, anguloGrados) {
  const t = (anguloGrados * Math.PI) / 180;
  return { g1: [l1, 0], g2: [l2 * Math.cos(t), l2 * Math.sin(t)] };
}

const f = (x) => (Math.abs(x) < 5e-10 ? 0 : x).toFixed(3);

/** Devuelve el marcado SVG de la figura (sin dependencias; se puede probar en Node). */
export function dibujarSVG(g1, g2, V, res, opciones = {}) {
  const { ancho = 520, alto = 420, escala = 70 } = opciones;
  const ox = ancho / 2 - 40;
  const oy = alto / 2 + 30;
  const X = (p) => ox + escala * p[0];
  const Y = (p) => oy - escala * p[1];
  const flecha = (v, color, etiqueta, grosor = 2.5, dash = "") => {
    const ang = Math.atan2(-(Y(v) - oy), X(v) - ox);
    const hx = X(v) - 10 * Math.cos(ang - 0.4);
    const hy = Y(v) + 10 * Math.sin(ang - 0.4);
    const kx = X(v) - 10 * Math.cos(ang + 0.4);
    const ky = Y(v) + 10 * Math.sin(ang + 0.4);
    return `<line x1="${ox}" y1="${oy}" x2="${X(v)}" y2="${Y(v)}" stroke="${color}" stroke-width="${grosor}" ${dash && `stroke-dasharray="${dash}"`}/>
<polygon points="${X(v)},${Y(v)} ${hx},${hy} ${kx},${ky}" fill="${color}"/>
<text x="${X(v) + 6}" y="${Y(v) - 6}" fill="${color}" font-size="15" font-style="italic">${etiqueta}</text>`;
  };
  // Descomposición V = V^1 g1 + V^2 g2 (paralelogramo)
  const a = [res.contra[0] * g1[0], res.contra[0] * g1[1]];
  const b = [res.contra[1] * g2[0], res.contra[1] * g2[1]];
  const punto = (p) => `${X(p)},${Y(p)}`;
  const paralelogramo = `<polyline points="${punto([0, 0])} ${punto(a)} ${punto(V)} ${punto(b)} ${punto([0, 0])}" fill="none" stroke="#6b7280" stroke-width="1" stroke-dasharray="4 4"/>`;
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${ancho} ${alto}" role="img" aria-label="Bases covariante y contravariante y vector V" style="max-width:100%;height:auto">
<rect width="${ancho}" height="${alto}" fill="none"/>
<line x1="0" y1="${oy}" x2="${ancho}" y2="${oy}" stroke="#d1d5db"/><line x1="${ox}" y1="0" x2="${ox}" y2="${alto}" stroke="#d1d5db"/>
${paralelogramo}
${flecha(g1, "#1d4ed8", "g₁")}${flecha(g2, "#1d4ed8", "g₂")}
${flecha(res.d1, "#b45309", "g¹", 2.5, "6 3")}${flecha(res.d2, "#b45309", "g²", 2.5, "6 3")}
${flecha(V, "#111827", "V", 3)}
<circle cx="${ox}" cy="${oy}" r="3" fill="#111827"/>
</svg>`;
}

/** Texto de resultados con 3 decimales. */
export function resumen(res) {
  return {
    g: res.g.map((r) => r.map(f)),
    contra: res.contra.map(f),
    co: res.co.map(f),
    reciprocidad: res.reciprocidad.map((r) => r.map(f)),
  };
}
