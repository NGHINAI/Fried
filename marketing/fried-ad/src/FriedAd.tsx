import {
  AbsoluteFill,
  Sequence,
  useCurrentFrame,
  useVideoConfig,
  interpolate,
  spring,
  Easing,
} from "remotion";

// Fried brand palette (matches the app)
const C = {
  void: "#0A0A0C",
  amber: "#D98C5C",
  ember: "#C26B4A",
  glow: "#E6A074",
  danger: "#E5564F",
  mint: "#6FBFB0",
  text: "#EDEDF1",
  dim: "#8F8F99",
};
const FONT = '-apple-system, "SF Pro Display", "Helvetica Neue", Arial, sans-serif';

// ── The Yolkie egg mascot (cloud-white blob + copper yolk + eyes) ──────────────
const Egg: React.FC<{ size?: number; fried?: number; shocked?: boolean }> = ({
  size = 220,
  fried = 0,
  shocked = false,
}) => {
  const white = fried > 0.6 ? "#9a7e64" : fried > 0.3 ? "#d8c8b4" : "#f0e8db";
  const yolk = fried > 0.6 ? "#5e3c26" : fried > 0.33 ? "#7a4a30" : "#b5763f";
  const blobs: [number, number, number][] = [
    [42, 48, 30], [78, 50, 28], [60, 38, 30], [48, 74, 26], [74, 74, 24], [60, 60, 34],
  ];
  const pupil = shocked ? 2.5 : 2;
  return (
    <svg width={size} height={size} viewBox="0 0 120 120">
      {blobs.map(([cx, cy, r], i) => (
        <circle key={i} cx={cx} cy={cy} r={r} fill={white} />
      ))}
      <circle cx="60" cy="58" r="24" fill={yolk} />
      <circle cx="52" cy="55" r="4" fill="#fff" />
      <circle cx="52" cy="55" r={pupil} fill="#1a1410" />
      <circle cx="68" cy="55" r="4" fill="#fff" />
      <circle cx="68" cy="55" r={pupil} fill="#1a1410" />
      {shocked && <ellipse cx="60" cy="67" rx="3" ry="4.5" fill="#1a1410" />}
    </svg>
  );
};

// ── Drifting ambient background (behind every scene) ───────────────────────────
const Background: React.FC = () => {
  const frame = useCurrentFrame();
  const drift = Math.sin(frame / 70) * 26;
  return (
    <AbsoluteFill style={{ backgroundColor: C.void }}>
      <div
        style={{
          position: "absolute", width: 760, height: 760, borderRadius: "50%",
          left: `${8 + drift / 4}%`, top: "-12%",
          background: `radial-gradient(circle, ${C.amber}33, transparent 62%)`, filter: "blur(50px)",
        }}
      />
      <div
        style={{
          position: "absolute", width: 680, height: 680, borderRadius: "50%",
          right: `${2 - drift / 4}%`, bottom: "-6%",
          background: `radial-gradient(circle, ${C.ember}26, transparent 62%)`, filter: "blur(50px)",
        }}
      />
    </AbsoluteFill>
  );
};

const center: React.CSSProperties = {
  justifyContent: "center", alignItems: "center", textAlign: "center", fontFamily: FONT,
};
const tabular: React.CSSProperties = { fontVariantNumeric: "tabular-nums" };

// fade in→hold→out across a sequence's local frames
const useFade = (inEnd: number, outStart: number, outEnd: number) => {
  const f = useCurrentFrame();
  return interpolate(f, [0, inEnd, outStart, outEnd], [0, 1, 1, 0], {
    extrapolateLeft: "clamp", extrapolateRight: "clamp",
  });
};

// 1 ── HOOK ────────────────────────────────────────────────────────────────────
const Hook: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const op = useFade(10, 62, 80);
  const rise = spring({ frame, fps, config: { damping: 13 } });
  return (
    <AbsoluteFill style={{ ...center, gap: 56 }}>
      <div style={{ opacity: op, transform: `scale(${0.82 + rise * 0.18})` }}>
        <Egg size={300} fried={0.35} />
      </div>
      <div
        style={{
          opacity: op, transform: `translateY(${(1 - rise) * 34}px)`,
          color: C.text, fontSize: 80, fontWeight: 800, lineHeight: 1.12, padding: "0 70px",
        }}
      >
        Your brain rot<br />finally has a score.
      </div>
    </AbsoluteFill>
  );
};

// 2 ── ANALYZING ────────────────────────────────────────────────────────────────
const Analyzing: React.FC = () => {
  const frame = useCurrentFrame();
  const op = useFade(8, 52, 70);
  const ring = interpolate(frame, [0, 60], [0, 1], { extrapolateRight: "clamp", easing: Easing.inOut(Easing.cubic) });
  const R = 130, CIRC = 2 * Math.PI * R;
  const lines = ["Reading your habits…", "Measuring your scroll pull…", "Comparing to 40,000 brains…"];
  const idx = Math.min(lines.length - 1, Math.floor(frame / 22));
  return (
    <AbsoluteFill style={{ ...center, gap: 60, opacity: op }}>
      <div style={{ position: "relative", width: 320, height: 320, ...center }}>
        <svg width={320} height={320} style={{ position: "absolute", transform: "rotate(-90deg)" }}>
          <circle cx={160} cy={160} r={R} stroke={`${C.amber}22`} strokeWidth={9} fill="none" />
          <circle
            cx={160} cy={160} r={R} stroke={C.amber} strokeWidth={9} fill="none" strokeLinecap="round"
            strokeDasharray={CIRC} strokeDashoffset={CIRC * (1 - ring)}
          />
        </svg>
        <Egg size={150} fried={0.4} />
      </div>
      <div style={{ color: C.dim, fontSize: 40, fontWeight: 500, fontFamily: FONT }}>{lines[idx]}</div>
    </AbsoluteFill>
  );
};

// 3 ── THE REVEAL (the number IS the hook) ──────────────────────────────────────
const Reveal: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const score = Math.round(
    interpolate(frame, [6, 52], [0, 87], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.cubic) })
  );
  const bloom = interpolate(frame, [46, 70], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const pop = spring({ frame: frame - 50, fps, config: { damping: 9 }, durationInFrames: 22 });
  const tierOp = interpolate(frame, [58, 70], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const pctOp = interpolate(frame, [74, 88], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const labelOp = interpolate(frame, [0, 10], [0, 1], { extrapolateRight: "clamp" });
  return (
    <AbsoluteFill style={center}>
      <div
        style={{
          position: "absolute", width: 900, height: 900, borderRadius: "50%",
          background: `radial-gradient(circle, ${C.danger}55, transparent 60%)`,
          opacity: bloom, transform: `scale(${0.5 + bloom * 0.7})`, mixBlendMode: "plusLighter",
        }}
      />
      <div style={{ position: "relative", ...center, gap: 14 }}>
        <div style={{ opacity: labelOp, color: C.dim, fontSize: 34, fontWeight: 600, letterSpacing: 6, fontFamily: FONT }}>
          YOUR FRIED SCORE
        </div>
        <div
          style={{
            ...tabular, fontFamily: FONT, fontSize: 360, fontWeight: 800, lineHeight: 1,
            background: `linear-gradient(180deg, ${C.glow}, ${C.danger})`,
            WebkitBackgroundClip: "text", backgroundClip: "text", color: "transparent",
            transform: `scale(${1 + Math.max(0, pop) * 0.06})`,
          }}
        >
          {score}
        </div>
        <div style={{ color: C.dim, fontSize: 40, fontWeight: 600, marginTop: -18, fontFamily: FONT }}>/ 100</div>
        <div style={{ opacity: tierOp, color: C.text, fontSize: 70, fontWeight: 800, marginTop: 18, fontFamily: FONT }}>
          💀 DEEP FRIED
        </div>
        <div style={{ opacity: pctOp, color: C.danger, fontSize: 38, fontWeight: 600, marginTop: 16, fontFamily: FONT, padding: "0 60px" }}>
          More fried than 92% of people your age.
        </div>
      </div>
    </AbsoluteFill>
  );
};

// 4 ── ARCHETYPE (the shareable identity) ───────────────────────────────────────
const Archetype: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const op = useFade(10, 60, 80);
  const pop = spring({ frame, fps, config: { damping: 12 } });
  return (
    <AbsoluteFill style={{ ...center, gap: 30, opacity: op }}>
      <div style={{ transform: `scale(${0.8 + pop * 0.2})` }}>
        <Egg size={230} fried={0.85} shocked />
      </div>
      <div style={{ color: C.dim, fontSize: 34, fontWeight: 600, letterSpacing: 6, fontFamily: FONT }}>
        YOUR BRAIN TYPE
      </div>
      <div
        style={{
          fontSize: 96, fontWeight: 800, lineHeight: 1.05, padding: "0 50px", fontFamily: FONT,
          background: `linear-gradient(180deg, ${C.glow}, ${C.ember})`,
          WebkitBackgroundClip: "text", backgroundClip: "text", color: "transparent",
          transform: `translateY(${(1 - pop) * 24}px)`,
        }}
      >
        THE FEED GOBLIN
      </div>
    </AbsoluteFill>
  );
};

// 5 ── CTA ──────────────────────────────────────────────────────────────────────
const CTA: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const op = interpolate(frame, [0, 12], [0, 1], { extrapolateRight: "clamp" });
  const pop = spring({ frame, fps, config: { damping: 12 } });
  const pulse = 1 + Math.sin(frame / 7) * 0.02;
  return (
    <AbsoluteFill style={{ ...center, gap: 40, opacity: op }}>
      <div style={{ color: C.text, fontSize: 66, fontWeight: 800, lineHeight: 1.15, padding: "0 70px", fontFamily: FONT }}>
        How fried is<br />YOUR brain?
      </div>
      <div style={{ display: "flex", alignItems: "center", gap: 16, transform: `scale(${0.85 + pop * 0.15})` }}>
        <span style={{ fontSize: 76 }}>🍳</span>
        <span
          style={{
            fontSize: 96, fontWeight: 800, fontFamily: FONT,
            background: `linear-gradient(90deg, ${C.glow}, ${C.ember})`,
            WebkitBackgroundClip: "text", backgroundClip: "text", color: "transparent",
          }}
        >
          fried
        </span>
      </div>
      <div
        style={{
          marginTop: 14, color: "#000", fontWeight: 700, fontSize: 40, fontFamily: FONT,
          padding: "22px 54px", borderRadius: 999,
          background: `linear-gradient(90deg, ${C.amber}, ${C.ember})`,
          transform: `scale(${pulse})`, boxShadow: `0 12px 40px ${C.ember}55`,
        }}
      >
        Take the 60-second test
      </div>
    </AbsoluteFill>
  );
};

export const FriedAd: React.FC = () => {
  return (
    <AbsoluteFill>
      <Background />
      <Sequence durationInFrames={80}>
        <Hook />
      </Sequence>
      <Sequence from={80} durationInFrames={70}>
        <Analyzing />
      </Sequence>
      <Sequence from={150} durationInFrames={100}>
        <Reveal />
      </Sequence>
      <Sequence from={250} durationInFrames={80}>
        <Archetype />
      </Sequence>
      <Sequence from={330} durationInFrames={70}>
        <CTA />
      </Sequence>
    </AbsoluteFill>
  );
};
