import "./index.css";
import { Composition } from "remotion";
import { FriedAd } from "./FriedAd";
import { FriedAdUGC } from "./FriedAdUGC";
import { FriedAdVO } from "./FriedAdVO";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="FriedAdVO"
        component={FriedAdVO}
        durationInFrames={620}
        fps={30}
        width={1080}
        height={1920}
        defaultProps={{ modelSrc: undefined as string | undefined }}
      />
      <Composition
        id="FriedAdVO-S1"
        component={FriedAdVO}
        durationInFrames={360}
        fps={30}
        width={1080}
        height={1920}
        defaultProps={{
          modelSrc: undefined as string | undefined,
          voSrc: "s1.mp3",
          captionsSrc: "s1.captions.json",
          pov: "this app said my brain is 47. i'm 19.",
          F: { brainStart: 58, ageLand: 111, issuesStart: 155, addicted: 240, cta: 300 },
          impacts: [111, 160, 169, 178, 187, 196, 240],
        }}
      />
      <Composition
        id="FriedAdUGC"
        component={FriedAdUGC}
        durationInFrames={480}
        fps={30}
        width={1080}
        height={1920}
        defaultProps={{ modelSrc: undefined as string | undefined }}
      />
      <Composition
        id="FriedAd"
        component={FriedAd}
        durationInFrames={400}
        fps={30}
        width={1080}
        height={1920}
      />
    </>
  );
};
