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

const { captions } = toCaptions({ whisperCppOutput });
fs.writeFileSync(
  path.join(process.cwd(), "public", "captions.json"),
  JSON.stringify(captions, null, 2)
);
console.log("WROTE", captions.length, "captions");
console.log("first words:", captions.slice(0, 6).map((c) => `${c.text}@${c.startMs}`).join(" "));
