# Link preview video

Remotion source for `images/og.mp4` (the `og:video` iMessage and Discord autoplay), `images/og-video.png` (the `og:image` still, frame 225 of the 6-second, 60 fps loop), and `images/og.png` (the plain social card every other page uses, the `OgCard` composition). Needs Node and ffmpeg.

```sh
cd site/_og && npm install && npm run render
```

`npm run studio` opens a live preview. `OgVideo.tsx` is the Brushed family shell (brushed aluminium, Barlow Semi Condensed headline, a label plate whose LED is the app's only colour) and takes its text as props in `Root.tsx`; `ForecastCard.tsx` is the Midnight Oil animation, black anodised with readings lit amber, on a screwed mount at the right. The loop ends on its first frame, so keep the first and last frames identical when changing the timing.

This folder is in `.vercelignore`, so none of it is deployed.
