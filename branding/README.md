## Branding overrides (no source changes)

### Login logo

LibreChat's login page loads `assets/logo.svg`.

To override it without editing LibreChat source, create `docker-compose.override.yml` (from `docker-compose.override.yml.example`) and mount your logo SVG over the built-in one:

- **host**: `./branding/logo.svg`
- **container**: `/app/client/public/assets/logo.svg`

