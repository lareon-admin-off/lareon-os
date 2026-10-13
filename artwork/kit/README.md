# Lareon wallpaper kit

This is the real Lareon mountain scene from the Lareon desktop app, so Lareon OS can match it exactly.

- `lareon-scene.js` is the original scene code. It draws three layers of flat, angular mountains (SVG paths on a 1440-wide grid), snow caps on the two tallest peaks, a field of small stars, a soft glow at the base and a faint veil. The mountain layers drift slowly and shift a little with the pointer.
- `palettes.css` has four palettes as CSS variables.
  - `p-night` and `p-dawn` are the real ones from the app (its dark and light themes).
  - `p-day` and `p-dusk` are new, proposed in the same style so the wallpaper can cover a full day.
- `lareon-wallpaper-night.png`, `-dawn.png`, `-day.png`, `-dusk.png` are 3840x2160 renders of each phase.
- `build.js` renders the PNGs (Playwright).

## Rules for Lareon OS
- Use this scene, not a new drawing of mountains. Keep the shapes, snow caps and layering exactly.
- Time of day should blend between the four palettes (interpolate the variables) using the computer's clock: roughly night 21:00-05:00, dawn 05:00-08:00, day 08:00-17:00, dusk 17:00-21:00. Stars fade in at dusk and are strongest at night.
- Colors are flat gradients, no textures or photos. Brand colors: orange #ff7c1f to violet #a35cf5.
