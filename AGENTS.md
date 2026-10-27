# Dotfiles maintenance

Use this repository as the source of truth for managed configuration.
Edit tracked source files instead of replacing installed symlinks.
Run ./install.sh after configuration layout changes.
Run dotfiles check to verify installed links.
Support macOS and Linux development containers.
Keep Nushell behavior consistent in Codespaces.
Keep platform-specific paths conditional.
Never read or import credential stores, .env files, private keys, Docker auth, cloud identities, shell history, or database contents.
Never commit credentials, tokens, machine caches, container volumes, or generated binaries.
Do not replace a complete Docker configuration file because it can contain authentication.
Keep application service configuration in the application repositories.
Validate configuration before committing and pushing requested changes.
Record task results in docs/briefs/DOTFILES-LOCAL-CODESPACES/result.md.
