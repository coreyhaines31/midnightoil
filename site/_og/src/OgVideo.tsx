import {loadFont as loadBarlow} from '@remotion/google-fonts/Barlow';
import {loadFont as loadCondensed} from '@remotion/google-fonts/BarlowSemiCondensed';
import {AbsoluteFill, Img, staticFile} from 'remotion';
import {ForecastCard} from './ForecastCard';

loadBarlow('normal', {weights: ['400', '500', '600'], subsets: ['latin']});
loadCondensed('normal', {weights: ['300', '600', '700'], subsets: ['latin']});

export type OgVideoProps = {
  name: string;
  icon: string;
  headline: string;
  headlineAccent: string;
  sub: string;
  // The app's pilot light: the only place its colour appears.
  accent: string;
  badge: string;
  // 'video' puts the live session card on a mount at the right; 'card' is the plain social card.
  variant: 'video' | 'card';
};

export const BODY = 'Barlow, "Helvetica Neue", system-ui, sans-serif';
export const DISPLAY = '"Barlow Semi Condensed", "Helvetica Neue", system-ui, sans-serif';
export const INK = '#161616';
export const INK_2 = '#3d3f41';

// Brushed aluminium, as in the site kit's --bx-brush.
const BRUSH = [
  'repeating-linear-gradient(0deg, rgba(255,255,255,.22) 0 1px, rgba(0,0,0,.035) 1px 2px, transparent 2px 3px)',
  'repeating-linear-gradient(0deg, rgba(0,0,0,.035) 0 1px, transparent 1px 7px)',
  'linear-gradient(100deg, rgba(255,255,255,0) 18%, rgba(255,255,255,.5) 40%, rgba(255,255,255,0) 64%)',
  'linear-gradient(180deg, #e7e8e9, #c3c5c7)',
].join(', ');

const Screw = ({x, y}: {x: number; y: number}) => (
  <div style={{position: 'absolute', left: x, top: y, width: 12, height: 12, borderRadius: '50%',
    background: 'radial-gradient(circle at 40% 35%, #fff, #b9bbbd 45%, #77797b 80%)'}} />
);

export const OgVideo = (props: OgVideoProps) => {
  const card = props.variant === 'card';
  return (
    <AbsoluteFill style={{background: BRUSH, color: INK, fontFamily: BODY, WebkitFontSmoothing: 'antialiased'}}>
      <div style={{position: 'absolute', left: 80, top: 70, width: card ? 1040 : 560, height: 490, display: 'flex', flexDirection: 'column', justifyContent: 'space-between'}}>
        <div style={{display: 'flex', alignItems: 'center', gap: 18, fontFamily: DISPLAY, fontSize: 38, fontWeight: 700}}>
          <Img src={staticFile(props.icon)} style={{width: 80, height: 80}} />
          {props.name}
        </div>
        <div>
          <div style={{display: 'inline-flex', alignItems: 'center', gap: 12, background: '#1b1b1b', color: '#d8d9da', fontFamily: DISPLAY,
            fontWeight: 600, fontSize: 18, letterSpacing: '0.26em', textTransform: 'uppercase', padding: '10px 16px 10px 14px', borderRadius: 3}}>
            <span style={{width: 10, height: 10, borderRadius: '50%', background: props.accent, boxShadow: `0 0 8px ${props.accent}`}} />
            {props.badge}
          </div>
          <div style={{fontFamily: DISPLAY, fontSize: card ? 104 : 64, lineHeight: 0.97, fontWeight: 600, marginTop: 22}}>
            {props.headline} <span style={{fontWeight: 300, whiteSpace: card ? 'nowrap' : 'normal'}}>{props.headlineAccent}</span>
          </div>
        </div>
        <div style={{fontSize: 26, color: INK_2}}>{props.sub}</div>
      </div>
      {!card && (
        <div style={{position: 'absolute', left: 680, top: 56, width: 464, height: 518, borderRadius: 16, background: '#1b1b1b',
          backgroundImage: 'radial-gradient(rgba(255,255,255,.045) 1px, transparent 1.3px)', backgroundSize: '5px 5px',
          boxShadow: '0 0 0 1px rgba(0,0,0,.5)'}}>
          <Screw x={14} y={14} /><Screw x={438} y={14} /><Screw x={14} y={492} /><Screw x={438} y={492} />
          <div style={{position: 'absolute', left: 30, top: 34, width: 404, height: 450}}>
            <ForecastCard />
          </div>
        </div>
      )}
    </AbsoluteFill>
  );
};
