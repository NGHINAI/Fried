import {
  AbsoluteFill,
  Sequence,
  OffthreadVideo,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
  interpolate,
  spring,
  Easing,
} from "remotion";
import { C, FONT, tabular, Egg, Embers, shakeAt, flashAt, Mood } from "./brand";

const W = 1080;
const H = 1920;
const MODEL_H = 720;
const APP_TOP = 860;
const IMPACTS = [135, 216, 240, 264, 288, 312]; // brain-age land + 5 issue stamps

// Position content inside the bottom "app" zone.
const Zone: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <AbsoluteFill
    style={{
      top: APP_TOP, height: H - APP_TOP,
      justifyContent: "center", alignItems: "center", textAlign: "center",
      padding: "0 50px", fontFamily: FONT,
    }}
  >
    {children}
  </AbsoluteFill>
);

// ── Top: the "creator" selfie cam (drop a real clip at public/model.mp4) ────────
const ModelCam: React.FC<{ modelSrc?: string; frame: number }> = ({ modelSrc, frame }) => {
  const mood: Mood = frame < 88 ? "curious" : frame < 210 ? "shocked" : "worried";
  const zoom = 1 + interpolate(frame, [0, 410], [0, 0.08], { extrapolateRight: "clamp" });
  const bob = Math.sin(frame / 22) * 6;
  const recOn = Math.floor(frame / 15) % 2 === 0;
  return (
    <div
      style={{
        position: "absolute", top: 0, left: 0, width: W, height: MODEL_H, overflow: "hidden",
        borderBottomLeftRadius: 44, borderBottomRightRadius: 44,
      }}
    >
      {modelSrc ? (
        <OffthreadVideo src={staticFile(modelSrc)} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
      ) : (
        <AbsoluteFill style={{ background: `radial-gradient(58% 58% at 50% 40%, #241b16, ${C.void})` }}>
          <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
            <div style={{ transform: `scale(${zoom}) translateY(${bob}px)` }}>
              <Egg size={320} fried={0.5} mood={mood} />
            </div>
          </AbsoluteFill>
        </AbsoluteFill>
      )}
      {/* webcam UI */}
      <div style={{ position: "absolute", top: 30, left: 36, display: "flex", alignItems: "center", gap: 10 }}>
        <div style={{ width: 16, height: 16, borderRadius: "50%", background: C.danger, opacity: recOn ? 1 : 0.25 }} />
        <span style={{ color: C.text, fontWeight: 700, fontSize: 26, fontFamily: FONT, opacity: 0.85 }}>REC</span>
      </div>
      <div style={{ position: "absolute", top: 30, right: 36, color: C.text, fontWeight: 600, fontSize: 26, fontFamily: FONT, opacity: 0.7, ...tabular }}>
        0:{String(Math.min(15, Math.floor(frame / 30))).padStart(2, "0")}
      </div>
      <div style={{ position: "absolute", top: 76, left: 0, right: 0, textAlign: "center", color: C.text, fontSize: 28, fontWeight: 700, fontFamily: FONT, opacity: 0.5 }}>
        POV: checking how fried my brain is
      </div>
      <AbsoluteFill style={{ boxShadow: "inset 0 0 120px rgba(0,0,0,0.55)", pointerEvents: "none" }} />
    </div>
  );
};

// ── Reaction captions (the spoken "voice") ──────────────────────────────────────
const CAPS: [number, string][] = [
  [0, "ok let's see how fried my brain actually is 🍳"],
  [92, "wait— my brain age is WHAT 😳"],
  [205, "oooo 😦"],
  [240, "i never knew my brain had THIS many issues 💀"],
  [345, "ok i actually need to fix this 😭"],
];
const Caption: React.FC<{ frame: number }> = ({ frame }) => {
  let cur = CAPS[0];
  for (const c of CAPS) if (frame >= c[0]) cur = c;
  const since = frame - cur[0];
  const pop = interpolate(since, [0, 8], [0.82, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const op = interpolate(since, [0, 6], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  return (
    <div style={{ position: "absolute", left: 56, right: 56, top: 688, textAlign: "center" }}>
      <span
        style={{
          display: "inline-block", background: "rgba(0,0,0,0.6)", color: C.text,
          fontSize: 48, fontWeight: 800, lineHeight: 1.18, padding: "14px 26px", borderRadius: 22,
          transform: `scale(${pop})`, opacity: op, fontFamily: FONT, textTransform: "lowercase",
        }}
      >
        {cur[1]}
      </span>
    </div>
  );
};

// ── App scenes ──────────────────────────────────────────────────────────────────
const Scan: React.FC = () => {
  const f = useCurrentFrame();
  const prog = interpolate(f, [0, 80], [0, 1], { extrapolateRight: "clamp", easing: Easing.inOut(Easing.cubic) });
  const glitch = f < 72 ? Math.sin(f * 3.1) * Math.sin(f * 1.3) * 5 : 0;
  return (
    <Zone>
      <div style={{ transform: `translateX(${glitch}px)` }}>
        <div style={{ color: C.amber, fontSize: 34, letterSpacing: 5, fontWeight: 700 }}>SCANNING YOUR BRAIN…</div>
        <div style={{ width: 560, height: 14, borderRadius: 8, background: `${C.amber}22`, marginTop: 30, overflow: "hidden" }}>
          <div style={{ width: `${prog * 100}%`, height: "100%", background: `linear-gradient(90deg, ${C.amber}, ${C.ember})` }} />
        </div>
        <div style={{ ...tabular, color: C.dim, fontSize: 30, marginTop: 22 }}>{Math.round(prog * 100)}%</div>
      </div>
    </Zone>
  );
};

const BrainAge: React.FC = () => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const age = Math.round(interpolate(f, [6, 45], [19, 47], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.cubic) }));
  const red = interpolate(f, [6, 45], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const gapOp = interpolate(f, [50, 62], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const pop = spring({ frame: f - 44, fps, config: { damping: 9 }, durationInFrames: 20 });
  const r = Math.round(217 + 12 * red), g = Math.round(140 - 54 * red), b = Math.round(92 - 13 * red);
  return (
    <Zone>
      <div style={{ color: C.dim, fontSize: 32, letterSpacing: 5, fontWeight: 700 }}>YOUR BRAIN AGE</div>
      <div
        style={{
          ...tabular, fontSize: 300, fontWeight: 800, lineHeight: 1, marginTop: 4,
          color: `rgb(${r},${g},${b})`, transform: `scale(${1 + Math.max(0, pop) * 0.06})`,
        }}
      >
        {age}
      </div>
      <div style={{ opacity: gapOp, marginTop: 8 }}>
        <span style={{ color: C.text, fontSize: 40, fontWeight: 600 }}>you're only 19. </span>
        <span style={{ color: C.danger, fontSize: 48, fontWeight: 800 }}>28 YEARS OLDER 💀</span>
      </div>
    </Zone>
  );
};

const ISSUES: [string, string][] = [
  ["Focus hold", "CRITICAL"], ["Scroll pull", "SEVERE"], ["Sleep & mornings", "WRECKED"],
  ["Reflex speed", "SLOW"], ["Consistency", "GONE"],
];
const Issues: React.FC = () => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const head = spring({ frame: f, fps, config: { damping: 12 } });
  return (
    <Zone>
      <div style={{ color: C.danger, fontSize: 46, fontWeight: 800, marginBottom: 26, transform: `scale(${0.85 + head * 0.15})` }}>
        5 CRITICAL ISSUES
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 15, width: 640 }}>
        {ISSUES.map(([name, sev], i) => {
          const start = 16 + i * 24;
          const s = spring({ frame: f - start, fps, config: { damping: 8 }, durationInFrames: 18 });
          const op = interpolate(f, [start, start + 6], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
          return (
            <div
              key={i}
              style={{
                opacity: op, transform: `scale(${0.62 + Math.min(1, s) * 0.38})`,
                display: "flex", alignItems: "center", justifyContent: "space-between",
                background: `${C.danger}1f`, border: `1px solid ${C.danger}66`, borderRadius: 16, padding: "16px 26px",
              }}
            >
              <span style={{ color: C.text, fontSize: 36, fontWeight: 600 }}>{name}</span>
              <span style={{ color: C.danger, fontSize: 30, fontWeight: 800, letterSpacing: 1 }}>✕ {sev}</span>
            </div>
          );
        })}
      </div>
    </Zone>
  );
};

const Arch: React.FC = () => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const op = interpolate(f, [0, 12], [0, 1], { extrapolateRight: "clamp" });
  const pop = spring({ frame: f, fps, config: { damping: 12 } });
  return (
    <Zone>
      <div style={{ opacity: op }}>
        <div style={{ color: C.danger, fontSize: 36, fontWeight: 700, padding: "0 30px" }}>More fried than 92% of people your age.</div>
        <div style={{ color: C.dim, fontSize: 30, letterSpacing: 5, fontWeight: 700, marginTop: 34 }}>YOUR BRAIN TYPE</div>
        <div
          style={{
            fontSize: 90, fontWeight: 800, marginTop: 6, transform: `translateY(${(1 - pop) * 20}px)`,
            background: `linear-gradient(180deg, ${C.glow}, ${C.ember})`,
            WebkitBackgroundClip: "text", backgroundClip: "text", color: "transparent",
          }}
        >
          THE FEED GOBLIN
        </div>
      </div>
    </Zone>
  );
};

const CTA: React.FC = () => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const op = interpolate(f, [0, 12], [0, 1], { extrapolateRight: "clamp" });
  const pop = spring({ frame: f, fps, config: { damping: 12 } });
  const pulse = 1 + Math.sin(f / 7) * 0.025;
  return (
    <AbsoluteFill style={{ background: C.void, justifyContent: "center", alignItems: "center", textAlign: "center", gap: 40, opacity: op, fontFamily: FONT }}>
      <div style={{ display: "flex", alignItems: "center", gap: 14, transform: `scale(${0.85 + pop * 0.15})` }}>
        <span style={{ fontSize: 92 }}>🍳</span>
        <span style={{ fontSize: 124, fontWeight: 800, background: `linear-gradient(90deg, ${C.glow}, ${C.ember})`, WebkitBackgroundClip: "text", backgroundClip: "text", color: "transparent" }}>fried</span>
      </div>
      <div style={{ color: C.text, fontSize: 64, fontWeight: 800, lineHeight: 1.15, padding: "0 80px" }}>How fried is<br />YOUR brain?</div>
      <div style={{ marginTop: 6, color: "#000", fontWeight: 800, fontSize: 42, padding: "24px 56px", borderRadius: 999, background: `linear-gradient(90deg, ${C.amber}, ${C.ember})`, transform: `scale(${pulse})`, boxShadow: `0 16px 50px ${C.ember}66` }}>
        Take the 60-second test →
      </div>
    </AbsoluteFill>
  );
};

export const FriedAdUGC: React.FC<{ modelSrc?: string }> = ({ modelSrc }) => {
  const frame = useCurrentFrame();
  const sh = shakeAt(frame, IMPACTS);
  const flash = flashAt(frame, IMPACTS);
  return (
    <AbsoluteFill style={{ backgroundColor: C.void, fontFamily: FONT }}>
      <AbsoluteFill style={{ transform: `scale(1.04) translate(${sh.x}px, ${sh.y}px)` }}>
        <AbsoluteFill style={{ top: APP_TOP }}>
          <div style={{ position: "absolute", inset: 0, background: `radial-gradient(60% 50% at 50% 38%, ${C.ember}1f, transparent 70%)` }} />
        </AbsoluteFill>
        <Embers frame={frame} />
        <ModelCam modelSrc={modelSrc} frame={frame} />
        <Sequence durationInFrames={90} layout="none"><Scan /></Sequence>
        <Sequence from={90} durationInFrames={110} layout="none"><BrainAge /></Sequence>
        <Sequence from={200} durationInFrames={140} layout="none"><Issues /></Sequence>
        <Sequence from={340} durationInFrames={70} layout="none"><Arch /></Sequence>
        {frame < 410 && <Caption frame={frame} />}
        <Sequence from={410} durationInFrames={70}><CTA /></Sequence>
      </AbsoluteFill>
      <AbsoluteFill style={{ background: C.danger, opacity: flash, mixBlendMode: "overlay", pointerEvents: "none" }} />
    </AbsoluteFill>
  );
};
