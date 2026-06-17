import "./index.css";
import { Composition } from "remotion";
import { FriedAd } from "./FriedAd";

export const RemotionRoot: React.FC = () => {
  return (
    <>
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
