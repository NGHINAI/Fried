import "./index.css";
import { Composition } from "remotion";
import { FriedAd } from "./FriedAd";
import { FriedAdUGC } from "./FriedAdUGC";

export const RemotionRoot: React.FC = () => {
  return (
    <>
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
