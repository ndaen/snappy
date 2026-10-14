
- **Halo autour d'un panel transparent** : sur macOS 26, `glassEffect`, l'ombre système (`hasShadow`) et un `.shadow` SwiftUI avec marge débordent tous en halo visible. Mon premier diagnostic (ombre système seule) était incomplet → pour un « contour » signalé, retirer toutes les sources d'un coup plutôt qu'une par une.
