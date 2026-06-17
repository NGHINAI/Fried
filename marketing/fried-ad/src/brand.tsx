import React from "react";

export const C = {
  void: "#0A0A0C",
  panel: "#141318",
  amber: "#D98C5C",
  ember: "#C26B4A",
  glow: "#E6A074",
  danger: "#E5564F",
  deepRed: "#B82F28",
  mint: "#6FBFB0",
  text: "#F2EDE9",
  dim: "#8F8F99",
};
export const FONT = '-apple-system, "SF Pro Display", "Helvetica Neue", Arial, sans-serif';
export const tabular: React.CSSProperties = { fontVariantNumeric: "tabular-nums" };

export type Mood = "curious" | "shocked" | "worried" | "fried" | "proud";

// The Yolkie egg — cloud-white blob + copper yolk + expressive face.
export const Egg: React.FC<{ size?: number; fried?: number; mood?: Mood }> = ({
  size = 220,
  fried = 0.4,
  mood = "curious",
}) => {
  const white = fried > 0.6 ? "#9a7e64" : fried > 0.3 ? "#d8c8b4" : "#f0e8db";
  const yolk = fried > 0.6 ? "#5e3c26" : fried > 0.33 ? "#7a4a30" : "#b5763f";
  const blobs: [number, number, number][] = [
    [42, 48, 30], [78, 50, 28], [60, 38, 30], [48, 74, 26], [74, 74, 24], [60, 60, 34],
  ];
  const eyeR = mood === "shocked" ? 6 : 4;
  const pupil = mood === "shocked" ? 3 : 2;
  return (
    <svg width={size} height={size} viewBox="0 0 120 120">
      {blobs.map(([cx, cy, r], i) => (
        <circle key={i} cx={cx} cy={cy} r={r} fill={white} />
      ))}
      <circle cx="60" cy="58" r="24" fill={yolk} />
      {mood === "worried" && (
        <>
          <line x1="46" y1="49" x2="56" y2="52" stroke="#1a1410" strokeWidth="2.2" strokeLinecap="round" />
          <line x1="74" y1="49" x2="64" y2="52" stroke="#1a1410" strokeWidth="2.2" strokeLinecap="round" />
        </>
      )}
      <circle cx="52" cy="56" r={eyeR} fill="#fff" />
      <circle cx="52" cy="56" r={pupil} fill="#1a1410" />
      <circle cx="68" cy="56" r={eyeR} fill="#fff" />
      <circle cx="68" cy="56" r={pupil} fill="#1a1410" />
      {mood === "shocked" && <ellipse cx="60" cy="69" rx="3.6" ry="5" fill="#1a1410" />}
      {mood === "worried" && <path d="M54 71 Q60 67 66 71" stroke="#1a1410" strokeWidth="2.3" fill="none" strokeLinecap="round" />}
      {mood === "fried" && <line x1="55" y1="69" x2="65" y2="69" stroke="#1a1410" strokeWidth="2.3" strokeLinecap="round" />}
      {mood === "proud" && <path d="M54 67 Q60 72 66 67" stroke="#1a1410" strokeWidth="2.3" fill="none" strokeLinecap="round" />}
      {mood === "curious" && <circle cx="60" cy="68" r="1.7" fill="#1a1410" />}
    </svg>
  );
};

// Floating ember particles (deterministic — same every render).
export const Embers: React.FC<{ frame: number; count?: number }> = ({ frame, count = 22 }) => (
  <>
    {Array.from({ length: count }).map((_, i) => {
      const seed = i * 137.5;
      const x = (Math.sin(seed) * 0.5 + 0.5) * 1080;
      const speed = 0.4 + ((i % 5) * 0.18);
      const y = 1920 - ((frame * speed + i * 90) % 2050);
      const sway = Math.sin(frame / 30 + i) * 18;
      const op = 0.05 + ((i % 4) * 0.04);
      const s = 3 + (i % 4);
      return (
        <div
          key={i}
          style={{
            position: "absolute", left: x + sway, top: y, width: s, height: s,
            borderRadius: "50%", background: C.glow, opacity: op, filter: "blur(0.5px)",
          }}
        />
      );
    })}
  </>
);

// Screen-shake offset that decays after each impact frame.
export const shakeAt = (frame: number, impacts: number[], amp = 16) => {
  let x = 0, y = 0;
  for (const t of impacts) {
    const d = frame - t;
    if (d >= 0 && d < 11) {
      const k = 1 - d / 11;
      x += Math.sin(d * 2.1) * amp * k;
      y += Math.cos(d * 1.6) * amp * 0.55 * k;
    }
  }
  return { x, y };
};

// Sum of short red flashes at impact frames.
export const flashAt = (frame: number, impacts: number[], peak = 0.5) => {
  let o = 0;
  for (const t of impacts) {
    const d = frame - t;
    if (d >= 0 && d < 8) o += peak * (1 - d / 8);
  }
  return Math.min(0.7, o);
};
