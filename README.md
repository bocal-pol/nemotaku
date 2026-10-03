# Nemotaku

Navigateur basé sur Chromium (via CEF), inspiré d'Arc. Priorités : économie de ressources,
système d'onglets vertical/horizontal, système de Spaces.

Voir [CONTEXT.md](CONTEXT.md) pour le vocabulaire de domaine et [docs/adr/](docs/adr/) pour les
décisions d'architecture.

## Stack

- Moteur : CEF (Chromium Embedded Framework)
- UI applicative : C++ natif + Qt
- Plateformes cibles : Windows, Linux
- Build : CMake

## Structure

```
src/
  core/        # Logique métier : Spaces, onglets, suspension, throttling
  cef-client/  # Intégration CEF : processus de rendu, profils, cycle de vie des onglets
  ui/          # Chrome Qt : sidebar Spaces, barre d'onglets, barre d'adresse
docs/adr/      # Décisions d'architecture
```
