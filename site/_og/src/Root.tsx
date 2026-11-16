import {Composition} from 'remotion';
import {OgVideo, type OgVideoProps} from './OgVideo';

// 6 s at 60 fps. Frame 225 (3.75 s) is the resting frame, rendered as the og:image still.
export const RemotionRoot = () => (
  <>
  <Composition
    id="OgVideo"
    component={OgVideo}
    durationInFrames={360}
    fps={60}
    width={1200}
    height={630}
    defaultProps={
      {
        name: 'Midnight Oil',
        icon: 'icon-512.png',
        headline: 'Let your AI agents',
        headlineAccent: 'work while you sleep.',
        sub: 'Free for macOS · midnightoil.app',
        accent: '#7a74ff',
        badge: 'Awake · Free for Mac',
        variant: 'video',
      } satisfies OgVideoProps
    }
  />
  {/* The plain social card (images/og.png) for every other page. */}
  <Composition
    id="OgCard"
    component={OgVideo}
    durationInFrames={1}
    fps={60}
    width={1200}
    height={630}
    defaultProps={
      {
        name: 'Midnight Oil',
        icon: 'icon-512.png',
        headline: 'Let your AI agents',
        headlineAccent: 'work while you sleep.',
        sub: 'Free for macOS · midnightoil.app',
        accent: '#7a74ff',
        badge: 'Awake · Free for Mac',
        variant: 'card',
      } satisfies OgVideoProps
    }
  />
  </>
);
