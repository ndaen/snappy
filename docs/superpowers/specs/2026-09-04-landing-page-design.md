# Snappy — landing page GitHub Pages

Date : 2026-09-04. Statut : validé en brainstorming, à planifier.

## Objectif

Donner à Snappy une page publique qui montre le principe de l'app en quelques secondes,
dans la même famille visuelle que la landing de Cubby (https://ndaen.github.io/cubby-mac/),
en vue d'un futur portfolio regroupant les outils open source.

## Hébergement

- Dossier `docs/` à la racine du repo `ndaen/snappy`, servi par GitHub Pages en mode
  branche `main /docs`. URL : `https://ndaen.github.io/snappy/`.
- Contenu du dossier : `index.html` (anglais), `fr/index.html` (français), `icon.png`
  (export 512 px de `Logo/icon-1024.png`). Rien d'autre. Les specs restent dans
  `docs/superpowers/specs/` mais ne sont pas liées depuis le site.
- Zéro étape de build : HTML, CSS et JS inline. Seule dépendance externe : la police
  Instrument Sans via Google Fonts, avec repli `ui-sans-serif, system-ui`.
- L'activation de Pages et le champ Homepage du repo sont faits par Noah via `!`
  (le mode auto bloque ces opérations).
- Pas de workflow de release dans le repo, donc pas de garde-fou `paths-ignore` à
  ajouter. Si une CI de release est ajoutée plus tard, reprendre celui de Cubby.

## Identité visuelle

- Ossature, typo et fond repris de Cubby : Instrument Sans, fond `#08080A`, encre
  `#F4F3F1`, gris `#9A9793` / `#6F6C68`, style « Linear » sombre, halo ambiant en haut.
- Accent propre à Snappy : bleu `#5CA8FF` (clair) → `#1B62D0` (profond), tiré de l'icône.
  Remplace le miel partout : eyebrow, liens, boutons, halo, focus.
- Motif graphique : le viseur à quatre coins de l'icône. Utilisé en coins de sélection
  sur les cartes de features (au survol), autour de la miniature dans l'overlay, et
  comme curseur croix sur la démo.
- Ton : mêmes accroches courtes que Cubby, une phrase par idée, pas de superlatifs.

## Structure de la page

1. **Nav** : icône + « Snappy », liens Features / Install / Shortcuts, bouton GitHub,
   bascule EN/FR.
2. **Hero** : eyebrow « Free & open source · macOS 14+ », titre, accroche, bouton
   principal « Download DMG » (lien vers `releases/latest`), lien secondaire « View on
   GitHub ».
3. **Démo interactive** (voir ci-dessous), pleine largeur sous le hero.
4. **Features**, trois cartes :
   - Capture zone / fenêtre / écran, overlay flottant : copier sans sauvegarder,
     sauver, épingler, glisser vers une app.
   - OCR : sélectionner une zone, le texte est dans le presse-papier (FR/EN, Vision).
   - Éditeur d'annotation : flèche, rectangle, surlignage, texte, flou par
     pixellisation, export à la résolution d'origine.
5. **Install**, trois étapes : télécharger le DMG et glisser dans `/Applications` ;
   premier lancement d'une app non signée via Réglages Système › Confidentialité et
   sécurité › « Ouvrir quand même » (macOS 15 a retiré le clic droit › Ouvrir) ;
   autoriser Enregistrement de l'écran puis relancer l'app. Encart « Build from
   source » avec `bash scripts/build-app.sh`.
6. **Shortcuts** : tableau des trois raccourcis par défaut (⌘⇧1 zone / fenêtre,
   ⌘⇧2 écran, ⌘⇧0 OCR) et mention du bouton « Par défaut » qui remplace ⌘⇧3/4.
7. **Closing** : phrase de rappel + bouton Download + lien GitHub.
8. **Footer** : MIT, lien repo, lien Cubby (« from the same shelf »).

Pas de section roadmap : Snappy n'a pas de TODO public.

## Démo interactive

Un faux bureau macOS rendu en HTML/CSS dans un cadre 16:10 :

- Barre de menus, fond d'écran en dégradé, une fenêtre « Notes » avec un paragraphe
  de texte réel (sert à l'OCR) et un petit graphique en barres CSS.
- Par défaut, une invite discrète : « Drag anywhere to capture ».

Flux capture :

1. Survol du bureau : curseur croix (CSS `cursor: crosshair` + réticule dessiné).
2. Pointer down + move : rectangle de sélection avec marquise pointillée, voile sombre
   autour, étiquette de dimensions en px qui suit le coin, comme dans macOS.
3. Pointer up (zone > 24×24 px) : flash blanc 120 ms, puis l'overlay flottant apparaît
   en bas à droite du bureau, en verre translucide : miniature de la zone capturée
   (clonage visuel via `element.toDataURL` impossible sans canvas ; on découpe le DOM
   du bureau par `clip-path` dans une copie positionnée, ce qui reste 100 % DOM) et
   quatre actions : Copy, Save, Annotate, Pin.
4. Copy / Save / Pin : toast « Copied », « Saved to Desktop », « Pinned » et fermeture de
   l'overlay après 1,2 s. Pin laisse la miniature épinglée au coin du bureau jusqu'à la
   prochaine capture.
5. Annotate : la miniature s'agrandit en mini éditeur avec trois outils cliquables,
   flèche, rectangle, flou. Chaque clic sur l'outil puis glisser sur la miniature
   dessine l'annotation (SVG pour flèche et rectangle, `backdrop-filter` pixelisé
   simulé par un `filter: blur` sur un fragment cloné pour le flou). Bouton Done ferme
   avec un toast « Exported at original resolution ».

Mode OCR :

- Bouton « Try OCR » sous le cadre, ou raccourci affiché « ⌘⇧0 ». Le curseur devient une
  croix avec un badge « T ». La sélection sur la fenêtre Notes surligne les lignes de
  texte réellement couvertes (calcul par `Range.getClientRects()` sur le paragraphe) et
  un toast affiche le texte copié, tronqué à deux lignes.

Contraintes :

- JS vanilla, aucun réseau, rien n'est envoyé ni lu hors de la page.
- Pointer events pour souris et tactile. Sur écran < 640 px, la démo passe en mode
  démonstration automatique en boucle (sélection, overlay, fermeture) sans
  interaction, pour éviter le conflit avec le scroll tactile.
- Sans JS : le bureau est rendu avec une sélection figée et l'overlay ouvert, en
  statique, avec la légende explicative.
- `prefers-reduced-motion` : pas de flash, transitions instantanées.

## Bilingue

- Deux fichiers séparés, comme Cubby : `index.html` en anglais, `fr/index.html` en
  français. Toute modification de contenu se fait deux fois.
- `hreflang` en / fr / x-default, balises OG avec `icon.png`, `lang` correct.
- Le JS de la démo est identique dans les deux fichiers ; seuls les libellés (boutons,
  toasts, invite) sont traduits via un petit objet de chaînes en tête de script.

## À-côtés du repo

- `README.md` traduit en anglais, avec l'icône, un lien vers le site en haut, et les
  mêmes trois étapes d'installation que la page. Le français ne reste que dans les
  commentaires du code.
- Description GitHub du repo et champ Homepage renseignés (via `!` par Noah).
- Aucune modification du code Swift, des scripts ni des releases.

## Vérification

- Playwright : captures de la page EN et FR à 1280 px et 390 px dans
  `.claude/screenshots/playwright/`, parcours complet de la démo (sélection, overlay,
  Copy, Annotate avec une flèche, OCR) vérifié par assertions sur le DOM.
- Page servie en local avec `python3 -m http.server` depuis `docs/` pour tester les
  chemins relatifs tels que Pages les résoudra (`/snappy/` et `/snappy/fr/`).
- Validation HTML sans erreur bloquante, aucune requête réseau autre que Google Fonts.
- Après push et activation de Pages : ouverture des deux URL publiques.

## Hors périmètre

- Pages pour Snuggy, Hubby, Wally : fournées suivantes, sur le même modèle.
- Portfolio regroupant les projets : projet séparé, une fois deux ou trois landings en
  ligne.
- Notarisation, CI de release, captures d'écran réelles de l'app.
