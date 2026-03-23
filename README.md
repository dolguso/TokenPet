# TokenPet

TokenPet is a macOS menu bar companion that turns OpenAI API usage into a small, glanceable pet.

## Why this exists

OpenAI's official dashboard is the most accurate place to inspect detailed billing and usage. TokenPet is for the layer above that: a lightweight everyday companion that answers three quick questions without opening a browser tab.

- Did I use OpenAI a lot today?
- How does this week compare to my normal rhythm?
- Should I care right now?

## MVP shape

- Menu bar first, no main window
- Demo mode available immediately after clone
- Secure API key storage in macOS Keychain
- Local cache of recent usage snapshots
- Tiny mood engine that maps usage intensity to a pet state
- Small popover showing:
  - today usage
  - this week usage
  - top model
  - 7-day mini chart

## Current repository status

This starter repo ships a working macOS menu bar shell plus a demo-data flow.

- `DemoUsageProvider` is fully usable now.
- `OpenAIUsageClient` is intentionally isolated and currently returns a clear "live API unavailable" error until the final endpoint contract is wired.

That keeps the repo pushable and useful today, while preserving a clean path for live integration next.

## Project structure

```text
Sources/TokenPet
├─ App/
├─ Models/
├─ Persistence/
├─ Services/
└─ UI/
```

## Local run

This repo is packaged as a Swift executable starter because this machine currently has Command Line Tools but not the full Xcode app bundle.

```bash
cd TokenPet
swift run
```

If you later install full Xcode, you can open the package in Xcode and continue building it as a native macOS app.

## Roadmap

### v1
- Finish live OpenAI usage endpoint wiring
- Add launch-at-login
- Improve pet animation states

### v1.1
- Budget threshold warnings
- Manual dashboard shortcut
- Optional compact text mode

### v2
- Anthropic API provider
- Multi-provider mood engine
- historical drill-down view
