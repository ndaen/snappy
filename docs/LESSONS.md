
- **Halo autour d'un panel transparent** : sur macOS 26, `glassEffect`, l'ombre système (`hasShadow`) et un `.shadow` SwiftUI avec marge débordent tous en halo visible. Mon premier diagnostic (ombre système seule) était incomplet → pour un « contour » signalé, retirer toutes les sources d'un coup plutôt qu'une par une.
- **Workflow de release qui bumpe depuis le dernier tag** : ne jamais faire `gh run rerun` après un échec postérieur à la création du tag — la relance calcule une nouvelle version et publie une release en double. Corriger le workflow et pousser plutôt.
- **Rulesets d'un dépôt personnel** : l'app GitHub Actions ne peut pas y être ajoutée en exception. Vérifier les règles de `main` (`gh api repos/<o>/<r>/rulesets`) avant de faire pousser la CI dessus.
