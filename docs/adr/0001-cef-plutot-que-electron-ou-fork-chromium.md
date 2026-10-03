# ADR 0001 — CEF plutôt qu'Electron ou fork Chromium complet

- **Statut** : accepté
- **Contexte** : Nemotaku doit intégrer un moteur Chromium tout en gardant une empreinte mémoire minimale — l'économie de ressources est la priorité produit numéro un, avant même les Spaces et les onglets. Trois options existaient : Electron (Node.js + Chromium), un fork Chromium complet (façon Brave/Arc), ou CEF (Chromium Embedded Framework, C++ sans runtime Node).
- **Décision** : utiliser CEF avec une couche applicative C++ native (Qt pour l'UI), sur Windows et Linux dès le départ.
- **Conséquences** :
  - Positif : pas de runtime Node.js superposé (contrairement à Electron), donc moins de mémoire consommée par processus et par onglet ; contrôle direct en C++ sur le cycle de vie des processus de rendu, nécessaire pour la suspension d'onglets et le throttling CPU.
  - Négatif : développement plus lourd qu'Electron (C++ plutôt que JS/HTML pour toute la couche applicative) ; pas de mises à jour de sécurité Chromium aussi suivies qu'un fork dédié (mais bien moins coûteux en maintenance qu'un fork Chromium complet, qui exigerait de maintenir une chaîne de build Google entière).
- **Alternatives écartées** :
  - Electron — écarté car le runtime Node.js ajoute un surcoût mémoire structurel contraire à la priorité ressources.
  - Fork Chromium complet (façon Brave/Arc) — écarté pour ce projet : coût de développement et de maintenance (compilation de plusieurs heures, depot_tools, suivi manuel de chaque release Chromium) disproportionné par rapport à la taille de l'équipe.
  - Tauri + WebView système — écarté car il n'embarque pas Chromium mais le moteur déjà présent sur l'OS (WebView2/Edge), ce qui limite le contrôle sur les internals (profils, extensions CRX, protocoles) nécessaires aux Spaces et à la suspension fine.
