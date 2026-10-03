# ADR 0003 — Windows et Linux ciblés dès le premier incrément

- **Statut** : accepté
- **Contexte** : CEF supporte nativement Windows, Linux et macOS. Cibler une seule plateforme au départ (Windows, poste de développement actuel) aurait réduit la charge de build/test du MVP, au prix d'une dette de portage à rembourser plus tard.
- **Décision** : Nemotaku cible Windows et Linux dès le premier incrément fonctionnel (macOS explicitement hors périmètre pour l'instant, faute de machine/CI dédiée).
- **Conséquences** :
  - Positif : évite une dette de portage différée sur des choix structurants (chemins fichiers, IPC CEF, intégration Qt) qui auraient été coûteux à corriger après coup.
  - Négatif : double la charge de build et de test dès le MVP ; toute CI mise en place doit couvrir les deux OS dès le début plutôt qu'en ajouter un second plus tard.
- **Alternatives écartées** : Windows seul — écarté malgré la simplicité initiale, le risque de dette de portage jugé plus coûteux à terme que le double build immédiat.
