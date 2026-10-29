import {Composition} from 'remotion';
import {OgVideo, type OgVideoProps} from './OgVideo';

// 6 s at 60 fps. Frame 225 (3.75 s) is the resting frame, rendered as the og:image still.
export const RemotionRoot = () => (
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
        headline: 'Let your AI agents work while',
        headlineAccent: 'you sleep.',
        sub: 'Free for macOS · midnightoil.app',
        accent: '#ff8c42',
        accentInk: '#c95a12',
        accentFill: '#ff8c42',
        field: ['#ffa55c', '#8b84ff', '#ffd98a', '#ff8fb6'],
        tint: '20,22,48',
      } satisfies OgVideoProps
    }
  />
);
