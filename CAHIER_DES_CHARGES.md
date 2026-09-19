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
3. un catalogue de huit modèles de CV intégrés, dont un modèle classique par
   défaut, accompagné de deux réglages : la couleur d'accent, choisie
   librement, et l'affichage de la photo ;
4. des sections personnalisées créées par l'utilisateur, de trois types ;
5. l'ajout, la modification, la suppression et la réorganisation des éléments
   répétables ;
6. l'annulation et le rétablissement des modifications (undo/redo) ;
7. la sauvegarde automatique des données en local, à l'exception de la photo ;
8. l'export du CV au format PDF A4 ;
9. la création, le renommage, la duplication et la suppression de plusieurs CV.

## 5. Fonctionnalités

### 5.1 Gestion des CV

- Créer un CV vide.
- Afficher la liste des CV enregistrés.
- Renommer ou dupliquer un CV.
- Supprimer un CV après confirmation.
- Enregistrer automatiquement les modifications, à l'exception de la photo
  conservée uniquement pendant la session pour le MVP.
- Ouvrir l'application sur un tableau de bord qui liste les CV enregistrés,
  du plus récemment modifié au plus ancien, avec une recherche par nom (sans
  tenir compte de la casse ni des accents), un tri par nom et la création
  d'un nouveau CV. Sans CV enregistré, le tableau de bord invite à créer le
  premier.

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

L'utilisateur peut en outre créer ses propres sections, décrites en section
5.13. Elles se placent après les sections standard et disposent du même
interrupteur de visibilité.

### 5.9 Catalogue de modèles

- Un catalogue affiche les huit modèles intégrés sous forme de vignettes
  accompagnées d'un libellé et d'une courte description.
- Les vignettes sont rendues à partir du PDF réel du CV en cours, et non d'un
  visuel statique : l'utilisateur voit ses propres données dans chaque modèle.
- Le catalogue fonctionne hors ligne, comme le reste de l'application.
- Le choix d'un modèle change uniquement la mise en forme : le contenu saisi,
  l'ordre et la visibilité des sections sont conservés à l'identique. Un modèle
  qui n'a pas de place pour la photo l'ignore sans la supprimer.
- Deux réglages accompagnent le choix du modèle :
  - la **couleur d'accent**, choisie dans un sélecteur de couleur : teinte,
    saturation et luminosité, ou saisie directe d'un code hexadécimal. Cinq
    couleurs sont proposées en raccourci. Un modèle sans couleur ignore ce
    réglage ;
  - l'**affichage de la photo**, indisponible tant qu'aucune photo n'est
    chargée dans la session.
- Changer un réglage ne régénère que l'aperçu du modèle sélectionné : les
  vignettes des autres modèles restent telles qu'elles étaient à l'ouverture du
  catalogue.
- Le modèle, la couleur d'accent et l'affichage de la photo sont enregistrés
  avec le CV, et non globalement, puis retrouvés à la réouverture.
- Le catalogue propose d'annuler sans rien appliquer, ou d'appliquer les trois
  valeurs d'un coup. L'application déclenche la régénération du PDF, entre dans
  l'historique undo/redo et affiche une notification de confirmation.

Les huit modèles intégrés sont :

| Modèle           | Description                                | Structure |
| ---------------- | ------------------------------------------ | --------- |
| Classique        | Une colonne, filet d'accent                | 1 colonne |
| Sobre            | Noir et blanc, sans accent                 | 1 colonne |
| Bandeau latéral  | Colonne colorée à gauche                   | latérale  |
| Latéral clair    | Colonne grise à droite                     | latérale  |
| En-tête coloré   | Bandeau pleine largeur                     | 1 colonne |
| Compact          | Interlignes serrés, plus de contenu        | 1 colonne |
| Académique       | En-tête centré, formations en premier      | 1 colonne |
| Contraste        | Capitales, titres de section en marge      | marge     |

Le modèle classique sert de référence commune : marges, styles typographiques
et règles de pagination sont partagés par les huit modèles ; seules la mise en
page et la place de la couleur changent.

Un modèle est décrit par quatre groupes de propriétés, indépendants les uns des
autres :

1. **structure** : nombre de colonnes et, le cas échéant, position de la colonne
   latérale et sections qui y sont placées ;
2. **en-tête** : bandeau pleine largeur ou non, alignement, présence et forme de
   la photo ;
3. **jetons visuels** : couleur d'accent, couleurs de texte, police, échelle
   typographique, interlignes et marges ;
4. **décorations de section** : style des titres, filets de séparation, style
   des puces et rendu des compétences.

Tous les modèles restent compatibles avec les systèmes ATS, qui lisent le PDF
de façon linéaire. La contrainte porte donc sur l'ordre d'émission et non sur
l'apparence : les widgets du PDF sont toujours émis dans l'ordre de lecture
attendu par un humain, un bandeau latéral est émis comme un bloc distinct placé
après le corps dans l'ordre du document, aucune mise en page ne passe par un
tableau, et le texte n'est jamais placé dans un en-tête de page ni rendu sous
forme d'image.

Les modèles à colonne latérale et le modèle à titres en marge demandent un
moteur de zones dans le générateur PDF. Les cinq modèles en une seule colonne
n'en ont pas besoin et peuvent donc être livrés avant lui.

La distinction entre les groupes 1-2 et le groupe 3 est structurante : les
jetons visuels sont destinés à devenir personnalisables par l'utilisateur
indépendamment du modèle choisi, comme le proposent les éditeurs de CV en
ligne. Le générateur PDF doit donc lire ces propriétés depuis une description
de modèle, et non les coder en dur.

### 5.10 Aperçu PDF

- L'aperçu affiche directement le PDF généré à partir des données du CV : ce
  qui est affiché est exactement ce qui sera exporté.
- Le PDF est régénéré automatiquement après une courte pause dans la saisie.
- Un bouton « Rafraîchir » permet de forcer la régénération du PDF.
- Un indicateur signale qu'une génération est en cours.
- L'aperçu permet le zoom et le défilement entre les pages.

### 5.11 Annuler / Rétablir

- Annuler la dernière modification (`Ctrl+Z`).
- Rétablir une modification annulée (`Ctrl+Y` ou `Ctrl+Maj+Z`).
- Boutons « Annuler » et « Rétablir » visibles, désactivés lorsqu'aucune action
  n'est disponible.
- L'historique couvre toutes les modifications du CV effectuées pendant la
  session actuelle : saisie, renommage, ajout, suppression, réorganisation,
  affichage ou masquage des sections, changement de modèle et changements de
  photo.
- Les frappes successives dans un même champ sont regroupées en une seule
  étape d'historique.
- L'historique est propre à chaque CV et n'est pas conservé après la fermeture
  de l'application. Le passage d'un CV à un autre pendant la même session
  conserve leurs historiques respectifs. Une nouvelle session démarre avec
  un historique vide.

### 5.12 Export PDF

- Exporter toutes les pages dans un unique fichier PDF.
- Si les dernières modifications ne sont pas encore reflétées dans le PDF,
  déclencher ou attendre la régénération correspondante avant l'export.
- Mettre à jour l'aperçu avec le PDF régénéré et exporter ce même PDF ; une
  génération plus ancienne ne doit pas remplacer la version à jour.
- Utiliser exclusivement le format A4 portrait.
- Produire un texte sélectionnable, et non une image.
- Permettre à l'utilisateur de choisir le nom et l'emplacement du fichier.
- Intégrer les polices nécessaires afin de préserver le rendu.

### 5.13 Sections personnalisées

L'utilisateur peut créer ses propres sections lorsque les sections standard ne
couvrent pas son parcours : publications, enseignement, distinctions, bénévolat.

- La création demande un nom, obligatoire, limité à 40 caractères et unique
  parmi les sections du CV, puis un type de contenu.
- Trois types de contenu sont proposés, chacun rendu par les mêmes composants
  PDF que la section standard correspondante :
  - **texte libre** : un paragraphe unique, rendu comme le profil professionnel ;
  - **liste datée** : titre, sous-titre, dates de début et de fin, description,
    rendue comme les expériences ;
  - **liste simple** : titre et description courte, rendue comme les
    certifications.
- Le type est figé à la création ; le nom reste modifiable.
- Une section créée est ajoutée à la fin du CV, visible, et devient la section
  sélectionnée dans le formulaire.
- Une section personnalisée se masque, se renomme et se supprime. La
  suppression est confirmée, rappelle le nombre d'éléments perdus et propose le
  masquage comme alternative.
- Création, renommage, suppression, masquage et saisie entrent tous dans
  l'historique undo/redo.
- Les sections personnalisées sont enregistrées avec le CV, dans leur ordre de
  création, et respectent la règle de pagination commune : un titre de section
  n'est jamais séparé de son premier élément.

## 6. Interface utilisateur

### 6.1 Organisation desktop

L'application s'ouvre sur le tableau de bord des CV (section 5.1). Ouvrir ou
créer un CV mène à l'écran d'édition, qui comporte trois zones :

```text
┌──────────────┬────────────────────────┬────────────────────────┐
│ Navigation   │ Formulaire d'édition   │ Aperçu PDF   [↻] [⤓]   │
│ des sections │                        │                        │
│              │  [↶ Annuler] [↷ Rétab.]│                        │
└──────────────┴────────────────────────┴────────────────────────┘
```

- La navigation donne accès aux différentes sections du CV. Elle porte aussi
  le nom du modèle courant, avec un accès direct au catalogue, et un bouton
  « Ajouter une section » sous la liste des sections.
- Le formulaire affiche les champs de la section sélectionnée. Le formulaire
  d'une section personnalisée signale son type et permet de la renommer ou de
  la supprimer.
- L'aperçu PDF est affiché sur le côté droit, avec les boutons « Rafraîchir »
  et « Exporter ».

Sur un écran étroit, le formulaire et l'aperçu peuvent être présentés dans des
onglets séparés.

### 6.2 Principes ergonomiques

- Interface simple et claire.
- Confirmation avant toute suppression importante.
- Indication visible de l'état de sauvegarde.

### 6.3 Notifications

Les messages ponctuels apparaissent sous forme de notifications empilées en bas
à droite de la fenêtre, et non dans une barre en bas d'écran.

- Trois notifications au maximum sont visibles, la plus récente en bas.
- Chaque notification porte un titre, un texte secondaire facultatif, une
  couleur selon sa nature et une croix de fermeture toujours disponible.
- Elles disparaissent d'elles-mêmes après quelques secondes, un peu plus
  longtemps lorsqu'elles portent une action.
- Une notification peut proposer une action : ouvrir le dossier d'export,
  réessayer un export échoué.
- Les cas couverts sont : régénération du PDF avant un export, export réussi,
  export échoué et modèle appliqué.

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
├── sections personnalisées[] (nom, type figé, visibilité, ordre, contenu)
└── préférences de présentation (modèle sélectionné, couleur d'accent,
    affichage de la photo, ordre et visibilité des sections)
```

Chaque élément répétable possède un identifiant stable et un ordre d'affichage.
Les données métier restent indépendantes du modèle visuel afin de pouvoir
ajouter d'autres thèmes ultérieurement. Le CV enregistre uniquement
l'identifiant du modèle sélectionné, jamais sa description : celle-ci est
fournie par le catalogue, ce qui permet de faire évoluer un modèle sans migrer
les CV existants. Un identifiant inconnu à la lecture retombe sur le modèle
classique par défaut.

Les deux réglages du catalogue sont enregistrés à côté de cet identifiant : la
couleur d'accent, enregistrée telle quelle puisqu'elle est libre, et
l'affichage de la photo. Ils surchargent les valeurs correspondantes de la
description du modèle ; le reste de la mise en forme vient de la description.
Une couleur enregistrée sans opacité est rendue opaque à la lecture : le PDF ne
restitue pas la transparence.

Le type d'une section personnalisée est figé à la création : il détermine la
forme de son contenu, qu'un changement ultérieur rendrait invalide.

Le modèle est immuable : chaque modification produit un nouvel état du CV, ce
qui permet de construire l'historique undo/redo.

## 9. Architecture technique

### 9.1 Technologies

- Framework : Flutter et Dart.
- Gestion du SDK : FVM, selon la version définie dans `.fvmrc`.
- Gestion d'état : Riverpod (`flutter_riverpod`).
- Stockage : SQLite local via `drift` ; chaque CV est enregistré sous forme de
  document JSON dans une table dédiée. La photo n'est pas persistée pour le MVP.
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
- le catalogue permet de changer de modèle et le PDF reflète ce choix sans
  perte de contenu ;
- la couleur d'accent et l'affichage de la photo choisis dans le catalogue sont
  appliqués au PDF et retrouvés après un redémarrage ;
- l'utilisateur peut créer une section personnalisée de chacun des trois types,
  la remplir, la renommer, la masquer et la supprimer, et la retrouver après un
  redémarrage ;
- les notifications signalent un export réussi, un export échoué et un modèle
  appliqué, et proposent l'action correspondante ;
- un CV long est réparti sur plusieurs pages A4 ;
- le PDF exporté est identique à celui affiché ;
- un export demandé avant la mise à jour du PDF attend la régénération
  correspondant aux dernières modifications ;
- l'analyse statique et l'ensemble des tests réussissent.

## 13. Hors périmètre initial

Les fonctions suivantes pourront être étudiées après le MVP :

- prise en charge de plateformes autres que Windows ;
- stockage persistant des photos avec les CV ;
- ajout de modèles par l'utilisateur sans recompilation, via un manifeste
  déposé dans un dossier local ;
- personnalisation des polices, et couleurs personnalisables au-delà de la
  seule couleur d'accent ;
- changement du type d'une section personnalisée après sa création ;
- réorganisation des sections standard entre elles par l'utilisateur ;
- rendus enrichis des compétences (points, étoiles, barres de niveau) et icônes
  de section ;
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
4. Construire le générateur PDF piloté par une description de modèle, le modèle
   professionnel par défaut et l'aperçu sur le côté droit.
5. Ajouter le système undo/redo.
6. Ajouter la sauvegarde locale SQLite et la gestion de plusieurs CV.
7. Implémenter la pagination et l'export PDF.
8. Ajouter le catalogue de sélection, ses réglages et les modèles en une seule
   colonne.
9. Ajouter le moteur de zones du générateur PDF, puis les modèles à colonne
   latérale et à titres en marge.
10. Ajouter les sections personnalisées.
11. Renforcer les tests et la gestion des erreurs.
