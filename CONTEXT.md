# CONTEXT — Vocabulaire de domaine

| Terme | Définition | Synonymes à éviter |
|-------|-----------|--------------------|
| Space | Ensemble isolé d'onglets avec son propre profil (cookies/sessions séparés). Unité de contexte principale de Nemotaku (ex. « Space Pro », « Space Perso ») ; un seul Space est visible à la fois dans une fenêtre. | workspace, profil, contexte, groupe |
| Onglet suspendu | Onglet dont le processus de rendu CEF a été libéré après inactivité prolongée, sans fermer l'onglet lui-même. Rechargé à la demande au retour dessus. | onglet déchargé, onglet endormi, tab sleep |
| Décharge de Space | Suspension en bloc de tous les onglets d'un Space resté inactif, plutôt qu'onglet par onglet. | déchargement global, space sleep |
| Processus de rendu | Processus CEF (Chromium) responsable du rendu d'une page web. Peut être partagé entre plusieurs onglets pour réduire l'empreinte mémoire. | renderer, processus onglet |
| Chrome (de l'application) | L'interface propre à Nemotaku autour de la zone de rendu web : barre d'adresse, sidebar de Spaces, barre d'onglets. À ne pas confondre avec le navigateur Google Chrome. | UI navigateur, coquille |
| Throttling | Ralentissement volontaire de l'exécution JS/animations d'un onglet en arrière-plan pour réduire la charge CPU, sans suspendre le processus. | bridage, limitation CPU |
