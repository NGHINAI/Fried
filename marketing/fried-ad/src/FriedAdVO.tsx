import { useCallback, useEffect, useState } from "react";
import {
  AbsoluteFill,
  Sequence,
  Audio,
  OffthreadVideo,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
  useDelayRender,
  interpolate,
  spring,
  Easing,
} from "remotion";
import { createTikTokStyleCaptions, type Caption } from "@remotion/captions";
import { C, FONT, tabular, Egg, Embers, shakeAt, flashAt, Mood } from "./brand";

const W = 1080;
const H = 1920;
const MODEL_H = 640;
const APP_TOP = 700;
const APP_BOTTOM = 1470; // app reveal lives between APP_TOP and here; captions below
// frames synced to the voiceover word timings (Zoe Premium VO)
const F = { brainStart: 225, ageLand: 268, issuesStart: 338, addicted: 396, cta: 433 };
const IMPACTS = [268, 343, 352, 361, 370, 379];

const Zone: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <AbsoluteFill
    style={{
      top: APP_TOP, height: APP_BOTTOM - APP_TOP,
      justifyContent: "center", alignItems: "center", textAlign: "center",
      padding: "0 50px", fontFamily: FONT,
    }}
  >
    {children}
  </AbsoluteFill>
);

const ModelCam: React.FC<{ modelSrc?: string; frame: number }> = ({ modelSrc, frame }) => {
  const mood: Mood = frame < F.brainStart ? "curious" : frame < F.issuesStart ? "shocked" : frame < F.cta ? "worried" : "fried";
  const zoom = 1 + interpolate(frame, [0, F.cta], [0, 0.08], { extrapolateRight: "clamp" });
  const bob = Math.sin(frame / 22) * 6;
  const recOn = Math.floor(frame / 15) % 2 === 0;
  return (
    <div style={{ position: "absolute", top: 0, left: 0, width: W, height: MODEL_H, overflow: "hidden", borderBottomLeftRadius: 44, borderBottomRightRadius: 44 }}>
      {modelSrc ? (
        <OffthreadVideo src={staticFile(modelSrc)} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
      ) : (
        <AbsoluteFill style={{ background: `radial-gradient(58% 60% at 50% 42%, #241b16, ${C.void})` }}>
          <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
            <div style={{ transform: `scale(${zoom}) translateY(${bob}px)` }}>
              <Egg size={300} fried={0.5} mood={mood} />
            </div>
          </AbsoluteFill>
        </AbsoluteFill>
      )}
      <div style={{ position: "absolute", top: 28, left: 34, display: "flex", alignItems: "center", gap: 10 }}>
        <div style={{ width: 15, height: 15, borderRadius: "50%", background: C.danger, opacity: recOn ? 1 : 0.25 }} />
        <span style={{ color: C.text, fontWeight: 700, fontSize: 25, fontFamily: FONT, opacity: 0.85 }}>REC</span>
      </div>
      <div style={{ position: "absolute", top: 28, right: 34, color: C.text, fontWeight: 600, fontSize: 25, fontFamily: FONT, opacity: 0.7, ...tabular }}>
        0:{String(Math.min(19, Math.floor(frame / 30))).padStart(2, "0")}
      </div>
      <div style={{ position: "absolute", top: 70, left: 0, right: 0, textAlign: "center", color: C.text, fontSize: 27, fontWeight: 700, fontFamily: FONT, opacity: 0.5 }}>
        POV: checking how fried my brain is
      </div>
      <AbsoluteFill style={{ boxShadow: "inset 0 0 110px rgba(0,0,0,0.55)", pointerEvents: "none" }} />
    </div>
  );
};

// Word-by-word karaoke captions synced to the voiceover.
const Karaoke: React.FC<{ pages: ReturnType<typeof createTikTokStyleCaptions>["pages"] }> = ({ pages }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const ms = (frame / fps) * 1000;
  let page: (typeof pages)[number] | null = null;
  for (const p of pages) if (ms >= p.startMs - 120) page = p;
  if (!page) return null;
  return (
    <div style={{ position: "absolute", left: 60, right: 60, bottom: 250, textAlign: "center" }}>
      <div style={{ display: "flex", flexWrap: "wrap", justifyContent: "center", gap: "8px 16px" }}>
        {page.tokens.map((t, i) => {
          const active = ms >= t.fromMs && ms < t.toMs;
          const seen = ms >= t.fromMs - 40;
          return (
            <span
              key={i}
              style={{
                fontSize: 66, fontWeight: 800, fontFamily: FONT, lineHeight: 1.1,
                color: active ? C.amber : seen ? C.text : "rgba(242,237,233,0.45)",
                transform: active ? "translateY(-4px) scale(1.06)" : "none",
                display: "inline-block", textShadow: "0 3px 16px rgba(0,0,0,0.75)",
              }}
            >
              {t.text}
            </span>
          );
        })}
      </div>
    </div>
  );
};

const Scan: React.FC = () => {
  const f = useCurrentFrame();
  const prog = interpolate(f, [20, 250], [0, 0.96], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const glitch = Math.sin(f * 2.7) * Math.sin(f * 1.1) * 4;
  return (
    <Zone>
      <div style={{ transform: `translateX(${glitch}px)`, opacity: interpolate(f, [0, 18], [0, 1], { extrapolateRight: "clamp" }) }}>
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
  const age = Math.round(interpolate(f, [8, F.ageLand - F.brainStart], [19, 47], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.cubic) }));
  const red = interpolate(f, [8, F.ageLand - F.brainStart], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const gapOp = interpolate(f, [70, 84], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const pop = spring({ frame: f - (F.ageLand - F.brainStart), fps, config: { damping: 9 }, durationInFrames: 20 });
  const r = Math.round(217 + 12 * red), g = Math.round(140 - 54 * red), b = Math.round(92 - 13 * red);
  return (
    <Zone>
      <div style={{ color: C.dim, fontSize: 32, letterSpacing: 5, fontWeight: 700 }}>YOUR BRAIN AGE</div>
      <div style={{ ...tabular, fontSize: 290, fontWeight: 800, lineHeight: 1, marginTop: 4, color: `rgb(${r},${g},${b})`, transform: `scale(${1 + Math.max(0, pop) * 0.06})` }}>{age}</div>
      <div style={{ opacity: gapOp, marginTop: 6 }}>
        <span style={{ color: C.text, fontSize: 38, fontWeight: 600 }}>you're only 19. </span>
        <span style={{ color: C.danger, fontSize: 46, fontWeight: 800 }}>28 YEARS OLDER 💀</span>
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
      <div style={{ color: C.danger, fontSize: 46, fontWeight: 800, marginBottom: 24, transform: `scale(${0.85 + head * 0.15})` }}>5 CRITICAL ISSUES</div>
      <div style={{ display: "flex", flexDirection: "column", gap: 14, width: 640 }}>
        {ISSUES.map(([name, sev], i) => {
          const start = 5 + i * 9;
          const s = spring({ frame: f - start, fps, config: { damping: 8 }, durationInFrames: 14 });
          const op = interpolate(f, [start, start + 5], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
          return (
            <div key={i} style={{ opacity: op, transform: `scale(${0.62 + Math.min(1, s) * 0.38})`, display: "flex", alignItems: "center", justifyContent: "space-between", background: `${C.danger}1f`, border: `1px solid ${C.danger}66`, borderRadius: 16, padding: "15px 26px" }}>
              <span style={{ color: C.text, fontSize: 35, fontWeight: 600 }}>{name}</span>
              <span style={{ color: C.danger, fontSize: 29, fontWeight: 800, letterSpacing: 1 }}>✕ {sev}</span>
            </div>
          );
        })}
      </div>
    </Zone>
  );
};

const Addicted: React.FC = () => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const pop = spring({ frame: f, fps, config: { damping: 11 } });
  return (
    <Zone>
      <div style={{ transform: `scale(${0.8 + pop * 0.2})` }}>
        <div style={{ color: C.danger, fontSize: 40, fontWeight: 700 }}>More fried than</div>
        <div style={{ ...tabular, fontSize: 200, fontWeight: 800, lineHeight: 1, color: C.danger }}>92%</div>
        <div style={{ color: C.text, fontSize: 38, fontWeight: 600 }}>of people your age.</div>
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
      <div style={{ marginTop: 6, color: "#000", fontWeight: 800, fontSize: 42, padding: "24px 56px", borderRadius: 999, background: `linear-gradient(90deg, ${C.amber}, ${C.ember})`, transform: `scale(${pulse})`, boxShadow: `0 16px 50px ${C.ember}66` }}>Take the 60-second test →</div>
    </AbsoluteFill>
  );
};

export const FriedAdVO: React.FC<{ modelSrc?: string }> = ({ modelSrc }) => {
  const frame = useCurrentFrame();
  const { delayRender, continueRender, cancelRender } = useDelayRender();
  const [handle] = useState(() => delayRender("captions"));
  const [pages, setPages] = useState<ReturnType<typeof createTikTokStyleCaptions>["pages"] | null>(null);

  const load = useCallback(async () => {
    try {
      const res = await fetch(staticFile("captions.json"));
      const caps = (await res.json()) as Caption[];
      const { pages } = createTikTokStyleCaptions({ captions: caps, combineTokensWithinMilliseconds: 250 });
      setPages(pages);
      continueRender(handle);
    } catch (e) {
      cancelRender(e);
    }
  }, [continueRender, cancelRender, handle]);
  useEffect(() => { load(); }, [load]);

  const sh = shakeAt(frame, IMPACTS);
  const flash = flashAt(frame, IMPACTS);

  return (
    <AbsoluteFill style={{ backgroundColor: C.void, fontFamily: FONT }}>
      <Audio src={staticFile("vo.mp3")} />
      <Sequence from={F.brainStart - 6}><Audio src={staticFile("whoosh.wav")} volume={0.5} /></Sequence>
      {IMPACTS.map((f, i) => (
        <Sequence key={i} from={f - 1}><Audio src={staticFile("thud.wav")} volume={0.55} /></Sequence>
      ))}

      <AbsoluteFill style={{ transform: `scale(1.04) translate(${sh.x}px, ${sh.y}px)` }}>
        <AbsoluteFill style={{ top: APP_TOP }}>
          <div style={{ position: "absolute", inset: 0, background: `radial-gradient(60% 50% at 50% 36%, ${C.ember}1f, transparent 70%)` }} />
        </AbsoluteFill>
        <Embers frame={frame} />
        <ModelCam modelSrc={modelSrc} frame={frame} />

        <Sequence durationInFrames={F.brainStart} layout="none"><Scan /></Sequence>
        <Sequence from={F.brainStart} durationInFrames={F.issuesStart - F.brainStart} layout="none"><BrainAge /></Sequence>
        <Sequence from={F.issuesStart} durationInFrames={F.addicted - F.issuesStart} layout="none"><Issues /></Sequence>
        <Sequence from={F.addicted} durationInFrames={F.cta - F.addicted} layout="none"><Addicted /></Sequence>

        {pages && frame < F.cta && <Karaoke pages={pages} />}
        <Sequence from={F.cta}><CTA /></Sequence>
      </AbsoluteFill>
      <AbsoluteFill style={{ background: C.danger, opacity: flash, mixBlendMode: "overlay", pointerEvents: "none" }} />
    </AbsoluteFill>
  );
};
