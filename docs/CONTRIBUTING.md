# Contributing to ARIA

## How to Contribute

1. **Open an issue first** to discuss proposed changes
2. Fork the repository
3. Create a feature branch
4. Submit a pull request

## Code Style

- Shell scripts: `set -euo pipefail`
- JSON: 2-space indentation
- Markdown: ATX headers, fenced code blocks

## Screenshot Guide

When contributing screenshots:
- **Format**: PNG
- **Terminal theme**: Dark background recommended
- **Font**: Monospace
- **Resolution**: At least 1200px wide
- **Location**: `docs/screenshots/`

### What to capture:
1. `aria status` — system health
2. `aria nyx list` — agent listing
3. `aria nyx archetypes` — archetype listing
4. `aria nyx teams` — team presets
5. `aria-review --team <preset> --target "..."` — review demo

## Testing

```bash
# After changes, verify:
aria status
aria nyx list
aria nyx archetypes
aria nyx teams
aria khala list
```

## Architecture Decisions

When proposing architectural changes, please reference:
- `~/.aria/docs/ecosystem-integration.md` for system overview
- `~/.aria/nyx/README.md` for Nyx agent design
- `~/.aria/skills/aria-review/SKILL.md` for review system design
