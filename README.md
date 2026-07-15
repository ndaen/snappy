<p align="center">
  <img src="Logo/icon-1024.png" width="160" alt="Snappy">
</p>

<h1 align="center">Snappy</h1>

<p align="center">Capture d'écran macOS façon CleanShot X — perso, légère, sans licence.</p>

## Fonctionnalités

- **Capture** zone / fenêtre / écran entier (raccourcis globaux, sélection native macOS)
- **Overlay flottant** Liquid Glass après capture : copier **sans sauvegarder**, sauver sur le bureau, annoter, épingler, drag & drop direct vers Finder/apps
- **OCR** : sélectionne une zone, le texte est copié au presse-papier (Vision, FR/EN)
- **Éditeur d'annotation** : flèche, rectangle, surlignage, texte, flou par pixellisation, export à la résolution d'origine
- **Réglages** : raccourcis personnalisables + bouton « Par défaut » qui remplace les raccourcis capture de macOS (⌘⇧3/4)

## Raccourcis (par défaut)

| Action | Raccourci |
|---|---|
| Capturer une zone / fenêtre | ⌘⇧1 |
| Capturer l'écran | ⌘⇧2 |
| Copier le texte (OCR) | ⌘⇧0 |

## Installation

1. Télécharger le DMG de la [dernière release](../../releases/latest)
2. Glisser `Snappy.app` dans `/Applications`
3. Clic droit → **Ouvrir** la première fois (app non signée)
4. Autoriser **Enregistrement de l'écran** quand macOS le demande, puis **relancer l'app**

## Build depuis les sources

```bash
bash scripts/build-app.sh          # build + install dans /Applications
bash scripts/package.sh 0.2.0     # .app + DMG dans dist/ (sans installer)
```

macOS 14+, Apple Silicon. App non signée : après chaque rebuild local, re-cocher Snappy dans Réglages Système → Confidentialité → Enregistrement de l'écran.
