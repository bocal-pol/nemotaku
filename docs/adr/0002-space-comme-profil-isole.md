# ADR 0002 — Un Space est un profil CEF isolé, pas un simple groupe visuel

- **Statut** : accepté
- **Contexte** : Arc popularise les Spaces comme regroupement visuel d'onglets. Deux lectures étaient possibles pour Nemotaku : un Space comme simple étiquette/couleur sur des onglets partageant une session unique, ou un Space comme profil CEF complet (cookies, stockage, sessions séparés).
- **Décision** : un Space correspond à un profil CEF isolé — chaque Space a ses propres cookies/sessions, en plus de ses propres onglets et favoris.
- **Conséquences** :
  - Positif : séparation réelle entre contextes (ex. compte pro/perso sur le même site) sans extension tierce ni navigation privée manuelle ; cohérent avec la décharge de Space en bloc (ADR implicite dans le périmètre MVP), qui devient une opération propre sur un profil entier.
  - Négatif : complexité d'implémentation plus élevée qu'un simple groupe visuel — chaque Space multiplie potentiellement les processus CEF et le stockage disque associé au profil, ce qui doit être arbitré avec la priorité économie de ressources lors de l'implémentation (ex. ne matérialiser le profil disque qu'à la première utilisation réelle du Space).
- **Alternatives écartées** : Space comme groupe visuel sur session unique — écarté car il ne permet pas une séparation réelle pro/perso, qui est la valeur centrale du modèle Arc que Nemotaku reprend.
