import {Easing, interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {INK, INK_2} from './OgVideo';

// Midnight Oil's session card: Claude Code keeps working past the point the Mac would have gone to sleep,
// the session timer counts up to 3h 12m, the verdict lands, then the run rewinds to where it starts, so the loop has no seam.
const W = 372;
const H = 150;
const SESSION_MIN = 192;
const SLEEP = 30 / SESSION_MIN;
const PITCH = 13;
const BAR = 8;
const TOP = 30;
const BARS = Math.floor((W - BAR) / PITCH) + 1;
// Agent activity per slice: busy, uneven, never idle.
const activity = (i: number) => 0.6 + 0.22 * Math.sin(i * 0.75) + 0.14 * Math.sin(i * 1.9 + 1);

const STANDARD = Easing.bezier(0.4, 0, 0.2, 1);
const IN_OUT = Easing.bezier(0.65, 0, 0.35, 1);
const OUT_EASE = Easing.bezier(0, 0, 0.2, 1);

const elapsed = (min: number) => `${Math.floor(min / 60)}h ${String(Math.floor(min % 60)).padStart(2, '0')}m`;

export const ForecastCard = ({accentInk, accentFill, tint}: {accentInk: string; accentFill: string; tint: string}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const t = frame / fps;
  const ease = (input: number[], output: number[], easing: (n: number) => number) =>
    interpolate(t, input, output, {extrapolateLeft: 'clamp', extrapolateRight: 'clamp', easing});

  // 0–2.6s run · 2.6s finish mark · 2.75–2.95s verdict in · hold to 4.5s · 4.5–4.8s verdict out · 4.6–5.8s rewind
  const run = ease([0, 2.6], [0, 1], STANDARD);
  const rewind = ease([4.6, 5.8], [0, 1], IN_OUT);
  const progress = run * (1 - rewind);
  // Text swaps overlap only briefly, so the two lines never sit on top of each other at half opacity.
  const verdictIn = ease([2.75, 2.95], [0, 1], OUT_EASE);
  const shown = verdictIn * ease([4.5, 4.68], [1, 0], STANDARD);
  const working = 1 - ease([2.62, 2.8], [0, 1], STANDARD) + ease([4.68, 4.88], [0, 1], STANDARD);
  const fadeOut = ease([4.5, 4.8], [1, 0], STANDARD);
  const done = spring({frame: frame - Math.round(2.55 * fps), fps, config: {damping: 14, stiffness: 160}}) * fadeOut;

  const head = interpolate(progress, [0, 1], [0.03, 1]);
  const headX = head * (W - BAR);
  const passed = Math.min(1, Math.max(0, (head - SLEEP) / 0.06));

  return (
    <div
      style={{width: '100%', height: '100%', boxSizing: 'border-box', padding: '30px 32px', borderRadius: 30, background: 'rgba(251,251,253,0.9)',
        boxShadow: `0 0 0 1px rgba(0,0,0,0.06), 0 2px 6px rgba(0,0,0,0.05), 0 16px 36px rgba(${tint},0.12)`, fontVariantNumeric: 'tabular-nums'}}
    >
      <div style={{display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start'}}>
        <div>
          <div style={{fontSize: 28, fontWeight: 600, letterSpacing: '-0.02em', color: INK}}>Claude Code</div>
          <div style={{fontSize: 21, color: INK_2, marginTop: 2}}>Keeping Mac awake</div>
        </div>
        <div style={{fontSize: 44, fontWeight: 700, letterSpacing: '-0.04em', color: accentInk, lineHeight: 1.1, whiteSpace: 'nowrap'}}>
          {elapsed(head * SESSION_MIN)}
        </div>
      </div>
      <svg width={W} height={H} viewBox={`0 0 ${W} ${H}`} style={{display: 'block', overflow: 'visible', marginTop: 26}}>
        <line x1={0} y1={H - 4} x2={W} y2={H - 4} stroke="rgba(0,0,0,0.12)" strokeWidth={2} />
        {Array.from({length: BARS}, (_, i) => {
          const x = i * PITCH;
          const grow = Math.min(1, Math.max(0, (headX - x) / PITCH));
          if (grow <= 0) return null;
          const h = (H - 4 - TOP) * activity(i) * grow;
          return <rect key={i} x={x} y={H - 6 - h} width={BAR} height={h} rx={4} fill={accentFill} opacity={x / W < SLEEP ? 0.45 : 0.9} />;
        })}
        <line x1={SLEEP * W} y1={TOP - 8} x2={SLEEP * W} y2={H - 4} stroke="#6e6e73" strokeWidth={2} strokeDasharray="4 5" />
        <text x={SLEEP * W + 8} y={TOP - 12} fontSize={18} fill={INK_2} opacity={0.4 + 0.6 * passed}>
          Would sleep at 11:32p
        </text>
        {done > 0.01 && (
          <g transform={`translate(${W - 10} ${TOP - 16}) scale(${done})`}>
            <circle r={13} fill={accentInk} stroke="#fff" strokeWidth={3} />
            <path d="M-5.5 0.5 L-1.5 4.5 L5.5 -3.5" fill="none" stroke="#fff" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" />
          </g>
        )}
      </svg>
      <div style={{position: 'relative', height: 28, marginTop: 8, fontSize: 20, color: INK_2, whiteSpace: 'nowrap'}}>
        <span style={{position: 'absolute', left: 0}}>11:02p</span>
        <span style={{position: 'absolute', right: 0}}>2:14a</span>
      </div>
      <div style={{position: 'absolute', marginTop: 18, fontSize: 30, fontWeight: 600, letterSpacing: '-0.02em', color: '#8e8e93', opacity: working}}>
        Agent working…
      </div>
      <div style={{marginTop: 18, opacity: shown, transform: `translateY(${(1 - verdictIn) * 8}px)`}}>
        <div style={{fontSize: 38, fontWeight: 700, letterSpacing: '-0.03em', color: accentInk}}>Still awake</div>
        <div style={{fontSize: 22, color: INK_2, marginTop: 4}}>Task finished at 2:14a</div>
      </div>
    </div>
  );
};
