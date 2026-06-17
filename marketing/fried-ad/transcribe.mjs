import path from "path";
import fs from "fs";
import {
  downloadWhisperModel,
  installWhisperCpp,
  transcribe,
  toCaptions,
} from "@remotion/install-whisper-cpp";

const to = path.join(process.cwd(), "whisper.cpp");
const model = "base.en";

await installWhisperCpp({ to, version: "1.5.5" });
await downloadWhisperModel({ model, folder: to });

const whisperCppOutput = await transcribe({
  model,
  whisperPath: to,
  whisperCppVersion: "1.5.5",
  inputPath: path.join(process.cwd(), "public", "vo_16k.wav"),
  tokenLevelTimestamps: true,
});
const { captions: raw } = toCaptions({ whisperCppOutput });

// ── Align the CANONICAL script text to Whisper's timings ──────────────────────
// Whisper mishears TTS words; we only trust its timing, never its spelling.
const norm = (s) => s.toLowerCase().replace(/[^a-z0-9]/g, "");
const script = fs.readFileSync(path.join(process.cwd(), "script.txt"), "utf8").trim();
const scriptWords = script.split(/\s+/).filter((w) => norm(w).length > 0);
const toks = raw
  .map((c) => ({ n: norm(c.text), startMs: c.startMs, endMs: c.endMs }))
  .filter((t) => t.n.length > 0);

let ti = 0;
const aligned = [];
for (const sw of scriptWords) {
  const target = norm(sw);
  let acc = "", startMs = null, endMs = null;
  while (ti < toks.length && acc.length < target.length) {
    const t = toks[ti];
    if (startMs === null) startMs = t.startMs;
    acc += t.n;
    endMs = t.endMs;
    ti++;
  }
  if (startMs === null) {
    const last = aligned[aligned.length - 1];
    startMs = last ? last.endMs : 0;
    endMs = startMs + 220;
  }
  aligned.push({ text: sw, startMs, endMs, timestampMs: Math.round((startMs + endMs) / 2), confidence: 1 });
}

fs.writeFileSync(path.join(process.cwd(), "public", "captions.json"), JSON.stringify(aligned, null, 2));
console.log("RAW   :", raw.map((c) => c.text.trim()).join(" "));
console.log("ALIGNED:", aligned.map((a) => `${a.text}@${a.startMs}`).join(" "));
