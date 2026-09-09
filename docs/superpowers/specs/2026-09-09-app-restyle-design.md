# Snappy — restyle de l'app dans le style du site

Date : 2026-09-09. Statut : validé en brainstorming, à planifier.

## Objectif

Porter l'identité visuelle de la landing (https://ndaen.github.io/snappy/) dans l'app macOS :
overlay post-capture en priorité, puis éditeur d'annotation, réglages et HUD. Même palette,
mêmes composants, sans changer la logique métier ni le comportement des fenêtres.

## Décisions

- Périmètre : overlay, éditeur, réglages, HUD. Fichiers `AppDelegate.swift`,
  `CaptureService.swift`, `Shortcuts.swift` exclus (chantier vidéo non commité de Noah).
- Rendu : toujours sombre, quel que soit le mode système. Verre sombre teinté, jamais de
  variante claire.
- Police : SF Pro système, graisses semibold pour les titres, resserrement `-0.02em`
  (`tracking`) sur les titres, `-0.01em` sur les libellés de boutons.
- Toggle « Style Liquid Glass » renommé « Fond translucide » (clé `overlay.glass`
  conservée) : pilote uniquement le flou du panneau, jamais la couleur.

## Thème (`Theme.swift`, nouveau)

Palette, en `Color` statiques sous `enum Theme` :

| Nom | Valeur | Usage |
|---|---|---|
| `bg` | `#08080A` | fond des fenêtres éditeur et réglages |
| `panel` | `#1C1C20` à 72 % | fond des panneaux verre (overlay, HUD, cartes) |
| `ink` | `#F4F3F1` | texte principal |
| `muted` | `#9A9793` | texte secondaire |
| `faint` | `#6F6C68` | texte tertiaire, aides |
| `line` | blanc 8 % | séparateurs, liserés de cartes |
| `lineStrong` | blanc 14 % | liseré des panneaux verre |
| `blue` | `#5CA8FF` | accent, sélection, coins de viseur |
| `blueDeep` | `#1B62D0` | bas des dégradés |
| `onBlue` | `#06111F` | texte sur bouton primaire |
| `ink` annotation | `#FF453A` | inchangé, encre des annotations |

Composants :

- `DarkGlass(shape:translucent:)` : modificateur de fond. Si `translucent` et macOS 26+ :
  `glassEffect(.regular.tint(Theme.panel), in: shape)`. Si `translucent` avant macOS 26 :
  `shape.fill(.ultraThinMaterial)` recouvert de `Theme.panel`, environnement forcé en
  `.dark`. Sinon : `shape.fill(#1C1C20)` opaque. Dans tous les cas : liseré `lineStrong`
  1 pt, ombre noire 55 % rayon 24 décalée de 12 pt, surlignage interne blanc 12 % en haut.
- `ViewfinderCorners(size: 12, lineWidth: 2, inset: 6, color: Theme.blue)` : overlay de
  quatre coins, rayon 2, mêmes proportions que sur le site.
- `TileButtonStyle` : bouton vertical icône SF 16 pt + libellé 10,5 pt, padding 8/4,
  rayon 10, fond blanc 6 %, survol blanc 14 %, texte `ink` à 85 % puis 100 %. Variante
  `active` : fond bleu 22 %, liseré bleu 40 %, texte blanc.
- `PrimaryButtonStyle` : dégradé `#5CA8FF → #2B74E0`, texte `onBlue` semibold 13 pt,
  rayon 9, ombre bleue 25 %, survol luminosité +6 %.
- `GhostButtonStyle` : liseré blanc 14 %, fond blanc 3,5 %, texte `ink`, survol blanc 7 %.
- `ChipButtonStyle` : chip d'outil 11,5 pt, rayon 9, fond blanc 6 %, sélectionné bleu 22 %
  avec liseré bleu 40 %.
- `Kbd` : vue touche clavier, 13 pt, rayon 7, liseré blanc 14 %, fond blanc 5 %, ombre
  interne basse.
- `Eyebrow` : texte 11 pt semibold, majuscules, espacement 0,08 em, couleur `blue`.

## Overlay (`OverlayView.swift`)

Agencement identique à la démo du site :

- Panneau 240 pt de large, rayon 16, padding 10, espacement vertical 10, `DarkGlass`.
- Vignette en haut : largeur pleine, ratio de la capture, hauteur plafonnée à 150 pt
  (au-delà, recadrage centré comme aujourd'hui via `DraggableThumbnail`), rayon 10,
  liseré blanc 12 %, `ViewfinderCorners` par-dessus. Bouton fermer (xmark 10 pt bold)
  circulaire 20 pt, fond noir 55 %, en haut à droite de la vignette, marge 6.
- Grille de quatre tuiles `TileButtonStyle` sous la vignette, espacement 6 : Copier
  (`doc.on.doc`), Sauver (`arrow.down.to.line`), Annoter (`pencil`), Épingler (`pin`).
  Épingler passe en variante `active` avec `pin.fill` quand épinglé.
- Comportements inchangés : Copier copie puis supprime le temp et ferme ; Sauver enregistre
  et ferme ; Annoter ouvre l'éditeur et ferme ; Épingler bascule `setPinned` ; glisser la
  vignette dépose le PNG ; auto-fermeture 6 s et attente si la souris est dessus.
- Animation : apparition `scale 0.85 → 1` + opacité, 220 ms, courbe `spring(response:
  0.28, dampingFraction: 0.75)`, origine en bas à droite ; disparition fondu 150 ms.
  Implémentée dans la vue via `onAppear` et un état `shown`, pas dans le panel.
- La taille du panel est recalculée depuis `fittingSize` comme aujourd'hui.

## Éditeur (`EditorCanvas.swift` toolbar, `EditorWindow.swift` chrome)

- Fenêtre : `titlebarAppearsTransparent = true`, `titleVisibility = .hidden`,
  `backgroundColor = Theme.bg`, `appearance = NSAppearance(named: .darkAqua)`,
  `styleMask` ajoute `.fullSizeContentView`. Le titre reste « Snappy — Annotation ».
- Barre d'outils, hauteur 52, fond `bg`, séparateur `line` en bas, padding horizontal 14 :
  à gauche cinq `ChipButtonStyle` (Flèche, Cadre, Surligner, Flou, Texte) avec icône SF et
  libellé, sélection bleue ; à droite Annuler (ghost, icône `arrow.uturn.backward`,
  désactivé à 40 % si rien à annuler), Copier (ghost), Sauver (primaire).
- Un décalage haut de 28 pt (zone de la barre de titre transparente) au-dessus de la barre
  d'outils pour laisser les feux de signalisation.
- Canevas, gestes, pixellisation, export : inchangés.

## Réglages (`SettingsView.swift`, `ShortcutRecorder.swift`)

- Fenêtre 460 pt, chrome comme l'éditeur, fond `bg`, apparence forcée sombre.
- Abandon de `Form` : `VStack` de trois cartes (liseré `line`, rayon 14, fond blanc 3,5 %,
  padding 18), chacune précédée d'un `Eyebrow` : « Raccourcis », « Overlay », « macOS ».
- Raccourcis : une ligne par action, libellé `ink` à gauche, `ShortcutRecorderView` à
  droite rendu comme une suite de `Kbd` (une touche par symbole du libellé, ex. ⌘ ⇧ 1) ;
  en enregistrement, un seul `Kbd` « Tapez… » avec liseré bleu. Logique du monitor inchangée.
- Overlay : segments Gauche / Centre / Droite en chips (un seul actif), toggle « Fond
  translucide » stylé avec teinte `blue`.
- macOS : bouton « Par défaut » en primaire, texte d'aide en `faint` 12 pt.

## HUD (`OCRService.swift`, `enum HUD`)

Même panneau `DarkGlass` rayon 12, icône SF en `blue`, texte `ink` 13 pt medium.
Durées et positions inchangées.

## Hors périmètre

- Mode clair, réglage de couleur d'accent, police embarquée.
- Toute modification de `AppDelegate`, `CaptureService`, `Shortcuts`, `HotKeyManager`.
- Refonte du canevas ou de nouveaux outils d'annotation.

## Vérification

- `swift build` sans avertissement nouveau, puis `bash scripts/build-app.sh`.
- Captures réelles avec `screencapture -x` en ligne de commande, enregistrées dans
  `.claude/screenshots/app/` : overlay après une capture (via le raccourci ou l'action
  du menu), éditeur ouvert, fenêtre de réglages, HUD. Chaque capture est relue et comparée
  à la démo du site (`.claude/screenshots/playwright/final-en-desktop.png`).
- Vérifier au clavier que Copier / Sauver / Annoter / Épingler / fermer font toujours la
  même chose, et que le glisser-déposer de la vignette fonctionne.
- Après rebuild, Noah re-coche Enregistrement de l'écran (contrainte TCC connue).
