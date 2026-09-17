# Cahier des charges — CV Maker

## 1. Présentation du projet

CV Maker est une application Flutter permettant de créer un curriculum vitae à
partir de données saisies dans des formulaires, de visualiser le PDF généré à
côté de l'éditeur et de l'exporter au format A4.

Le MVP cible exclusivement Windows. La prise en charge des autres plateformes
est hors du périmètre initial.

## 2. Objectifs

- Simplifier la création d'un CV professionnel.
- Séparer la saisie du contenu de sa mise en page.
- Afficher le PDF réel du CV pendant l'édition.
- Garantir un document final au format A4.
- Permettre la sauvegarde locale et la reprise d'un CV.
- Produire un PDF prêt à être imprimé ou envoyé à un recruteur.

## 3. Public cible

- Étudiants et jeunes diplômés.
- Candidats en recherche d'emploi.
- Professionnels souhaitant mettre leur CV à jour rapidement.
- Utilisateurs ne maîtrisant pas les logiciels de mise en page.

## 4. Périmètre du MVP

Le produit minimum viable comprend :

1. un éditeur de CV organisé en sections ;
2. un aperçu affichant directement le PDF généré, avec un bouton de
   rafraîchissement ;
3. un modèle de CV professionnel ;
4. l'ajout, la modification, la suppression et la réorganisation des éléments
   répétables ;
5. l'annulation et le rétablissement des modifications (undo/redo) ;
6. la sauvegarde automatique des données en local, à l'exception de la photo ;
7. l'export du CV au format PDF A4 ;
8. la création, le renommage, la duplication et la suppression de plusieurs CV.

## 5. Fonctionnalités

### 5.1 Gestion des CV

- Créer un CV vide.
- Afficher la liste des CV enregistrés.
- Renommer ou dupliquer un CV.
- Supprimer un CV après confirmation.
- Enregistrer automatiquement les modifications, à l'exception de la photo
  conservée uniquement pendant la session pour le MVP.
- Rouvrir le dernier CV modifié au démarrage.

### 5.2 Informations personnelles

Le formulaire permet de renseigner :

- prénom et nom ;
- titre professionnel ;
- photographie facultative ;
- adresse ou localisation ;
- numéro de téléphone ;
- adresse e-mail ;
- site personnel ou portfolio ;
- profil LinkedIn et autres liens pertinents.

Pour le MVP, la photo est conservée uniquement en mémoire pendant la session
actuelle. Elle peut apparaître dans l'aperçu et être intégrée au PDF exporté,
mais elle n'est pas sauvegardée avec le CV. Après fermeture de l'application,
l'utilisateur doit la sélectionner à nouveau. Son stockage persistant est
prévu après le MVP.

### 5.3 Profil professionnel

- Saisir une présentation courte du candidat.

### 5.4 Expériences professionnelles

Pour chaque expérience :

- intitulé du poste ;
- entreprise ;
- lieu ;
- date de début ;
- date de fin ou option « En cours » ;
- description et réalisations principales.

L'utilisateur peut ajouter, supprimer et réordonner les expériences.

### 5.5 Formations

Pour chaque formation :

- diplôme ou intitulé ;
- établissement ;
- lieu ;
- dates de début et de fin ;
- description facultative.

L'utilisateur peut ajouter, supprimer et réordonner les formations.

### 5.6 Compétences

- Ajouter des compétences.
- Regrouper éventuellement les compétences par catégorie.
- Indiquer un niveau facultatif.
- Réordonner ou supprimer une compétence.

### 5.7 Langues

- Ajouter une langue.
- Choisir ou saisir le niveau de maîtrise.
- Réordonner ou supprimer une langue.

### 5.8 Sections complémentaires

- Certifications.
- Projets.
- Centres d'intérêt.
- Références ou informations complémentaires.

Chaque section facultative peut être affichée ou masquée dans le CV.

### 5.9 Aperçu PDF

- L'aperçu affiche directement le PDF généré à partir des données du CV : ce
  qui est affiché est exactement ce qui sera exporté.
- Le PDF est régénéré automatiquement après une courte pause dans la saisie.
- Un bouton « Rafraîchir » permet de forcer la régénération du PDF.
- Un indicateur signale qu'une génération est en cours.
- L'aperçu permet le zoom et le défilement entre les pages.

### 5.10 Annuler / Rétablir

- Annuler la dernière modification (`Ctrl+Z`).
- Rétablir une modification annulée (`Ctrl+Y` ou `Ctrl+Maj+Z`).
- Boutons « Annuler » et « Rétablir » visibles, désactivés lorsqu'aucune action
  n'est disponible.
- L'historique couvre toutes les modifications du CV effectuées pendant la
  session actuelle : saisie, renommage, ajout, suppression, réorganisation,
  affichage ou masquage des sections et changements de photo.
- Les frappes successives dans un même champ sont regroupées en une seule
  étape d'historique.
- L'historique est propre à chaque CV et n'est pas conservé après la fermeture
  de l'application. Le passage d'un CV à un autre pendant la même session
  conserve leurs historiques respectifs. Une nouvelle session démarre avec
  un historique vide.

### 5.11 Export PDF

- Exporter toutes les pages dans un unique fichier PDF.
- Si les dernières modifications ne sont pas encore reflétées dans le PDF,
  déclencher ou attendre la régénération correspondante avant l'export.
- Mettre à jour l'aperçu avec le PDF régénéré et exporter ce même PDF ; une
  génération plus ancienne ne doit pas remplacer la version à jour.
- Utiliser exclusivement le format A4 portrait.
- Produire un texte sélectionnable, et non une image.
- Permettre à l'utilisateur de choisir le nom et l'emplacement du fichier.
- Intégrer les polices nécessaires afin de préserver le rendu.

## 6. Interface utilisateur

### 6.1 Organisation desktop

L'écran principal comporte trois zones :

```text
┌──────────────┬────────────────────────┬────────────────────────┐
│ Navigation   │ Formulaire d'édition   │ Aperçu PDF   [↻] [⤓]   │
│ des sections │                        │                        │
│              │  [↶ Annuler] [↷ Rétab.]│                        │
└──────────────┴────────────────────────┴────────────────────────┘
```

- La navigation donne accès aux différentes sections du CV.
- Le formulaire affiche les champs de la section sélectionnée.
- L'aperçu PDF est affiché sur le côté droit, avec les boutons « Rafraîchir »
  et « Exporter ».

Sur un écran étroit, le formulaire et l'aperçu peuvent être présentés dans des
onglets séparés.

### 6.2 Principes ergonomiques

- Interface simple et claire.
- Confirmation avant toute suppression importante.
- Indication visible de l'état de sauvegarde.

## 7. Contraintes du document A4

- Format : A4 portrait (210 × 297 mm).
- Le document peut contenir une ou plusieurs pages.
- Les coupures de page ne doivent pas séparer un titre de section de son
  premier contenu.

## 8. Modèle de données indicatif

Un CV contient au minimum :

```text
CvDocument
├── id, nom, date de création, date de modification
├── informations personnelles
├── profil professionnel
├── expériences[]
├── formations[]
├── compétences[]
├── langues[]
├── certifications[]
├── projets[]
├── centres d'intérêt[]
└── préférences de présentation (ordre et visibilité des sections)
```

Chaque élément répétable possède un identifiant stable et un ordre d'affichage.
Les données métier restent indépendantes du modèle visuel afin de pouvoir
ajouter d'autres thèmes ultérieurement.

Le modèle est immuable : chaque modification produit un nouvel état du CV, ce
qui permet de construire l'historique undo/redo.

## 9. Architecture technique

### 9.1 Technologies

- Framework : Flutter et Dart.
- Gestion du SDK : FVM, selon la version définie dans `.fvmrc`.
- Gestion d'état : Riverpod (`flutter_riverpod`).
- Stockage : SQLite local ; chaque CV est enregistré sous forme de document
  JSON dans une table dédiée. La photo n'est pas persistée pour le MVP.
- Génération du PDF : package `pdf`.
- Affichage du PDF : package `printing` ou visionneuse PDF équivalente.
- Sélection du fichier : dialogue natif Windows.

### 9.2 Organisation proposée

```text
lib/
├── app/
├── core/
├── features/
│   └── cv/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
```

La logique métier, le stockage, l'interface d'édition et la génération du PDF
doivent rester séparés pour faciliter les tests et l'évolution du produit.

## 10. Exigences non fonctionnelles

- Fonctionnement hors ligne ; aucune donnée personnelle envoyée vers un service
  distant.
- Gestion correcte des caractères accentués.
- Messages clairs en cas d'échec de sauvegarde ou d'export.

## 11. Tests et qualité

- Chaque fichier ajouté dans `lib/` possède un test correspondant dans `test/`,
  conformément à `AGENTS.md`.
- Avant la livraison d'une tâche, les commandes suivantes doivent réussir :

```shell
fvm flutter analyze
fvm flutter test
```

## 12. Critères d'acceptation du MVP

Le MVP est considéré comme terminé lorsque :

- l'application fonctionne sous Windows ;
- un utilisateur peut renseigner toutes les sections principales ;
- le PDF affiché à droite reflète les données après régénération automatique
  ou après un clic sur « Rafraîchir » ;
- toutes les modifications du CV de la session actuelle peuvent être annulées
  et rétablies, y compris après un changement de CV ;
- l'historique est vide au redémarrage de l'application ;
- les données sont retrouvées après le redémarrage de l'application, à
  l'exception de la photo qui doit être sélectionnée à nouveau ;
- la photo sélectionnée pendant la session apparaît dans l'aperçu et le PDF
  exporté ;
- les listes d'expériences et de formations peuvent être réorganisées ;
- les sections facultatives peuvent être masquées ;
- un CV long est réparti sur plusieurs pages A4 ;
- le PDF exporté est identique à celui affiché ;
- un export demandé avant la mise à jour du PDF attend la régénération
  correspondant aux dernières modifications ;
- l'analyse statique et l'ensemble des tests réussissent.

## 13. Hors périmètre initial

Les fonctions suivantes pourront être étudiées après le MVP :

- prise en charge de plateformes autres que Windows ;
- stockage persistant des photos avec les CV ;
- modèles graphiques supplémentaires ;
- personnalisation avancée des couleurs et des polices ;
- import depuis LinkedIn ou depuis un CV existant ;
- suggestions de rédaction assistées par intelligence artificielle ;
- traduction automatique ;
- synchronisation dans le cloud et partage par lien ;
- comptes utilisateurs ;
- export au format Word ;
- analyse automatique de compatibilité avec les systèmes ATS.

## 14. Découpage prévisionnel

1. Mettre en place l'architecture, le thème et la navigation.
2. Créer les modèles de données immuables.
3. Développer les formulaires des sections principales.
4. Construire le premier modèle de CV en PDF et l'aperçu sur le côté droit.
5. Ajouter le système undo/redo.
6. Ajouter la sauvegarde locale SQLite et la gestion de plusieurs CV.
7. Implémenter la pagination et l'export PDF.
8. Renforcer les tests et la gestion des erreurs.
