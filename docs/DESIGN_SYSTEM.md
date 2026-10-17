# Design system | HATUA

## Personality

Warm, respectful, calm, capable, never judgemental or infantilising. Avoid guilt language, exploitative urgency, misleading success claims or addictive streak mechanics.

## Palette

- Primary green: `#087F66`
- Trust navy: `#193B53`
- Warm accent: `#F4B860`
- Light canvas: `#F5F7F5`
- Material 3 tokens adapt these to accessible light and dark surfaces.

## Navigation

Five main tabs: Home, Explore, Support, My Plan, Profile/Settings. Home directs to one concrete next action. Support remains optional and cannot leak into employer-facing UX.

## Interaction and accessibility

- Minimum 48dp touch target where possible, test at 200% font scale.
- TalkBack semantic text for each icon; readable contrast in light/dark themes.
- Use concise status, source-verification details and actionable empty states.
- Clear disabled and loading states, safe Android back navigation.
- Offline banners on cached public information. Never claim stale data has been freshly verified.
- No auto play, loud sounds or motion-heavy success effects.
- English UI in current source; complete Kiswahili translation and language selector remain TODO prior to public release.

## Required screens and states

Home, Explore, Support, Plan, Settings. Each needs loading, empty, content, error/offline states. Explore includes text search and saved filter. Support has prominent NACADA 1192 dialer and reviewed directory only. Plan is private/local and supports add/complete/delete. Settings supports local-data deletion.
