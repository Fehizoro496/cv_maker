# Roadmap — CV Maker (MVP Windows)

Cette roadmap découpe le MVP décrit dans `CAHIER_DES_CHARGES.md` en jalons
livrables. Chaque jalon produit une application qui se lance sous Windows et
dont `fvm flutter analyze` et `fvm flutter test` réussissent.

Chaque jalon inclut les tests des comportements ajoutés ou modifiés et un
fichier de test correspondant à chaque nouveau fichier de `lib/`, en miroir
dans `test/`, conformément à `AGENTS.md`.

Le design de référence (maquettes, comportements et tokens) est décrit dans
`design_handoff_cv_maker/README.md` ; chaque jalon reproduit les écrans qui le
concernent.

L'utilisation de l'application est entièrement hors ligne : aucune connexion
ni aucun service distant ne sont nécessaires. Les polices et les ressources
nécessaires à l'édition, à l'aperçu et à l'export sont livrées avec l'application.
Aucune donnée personnelle n'est envoyée vers un service distant.

L'ordre privilégie une **tranche verticale précoce** : le parcours
formulaire → PDF paginé → aperçu est validé dès le jalon 2, avant de développer
tous les formulaires. La pagination est testée avec des données longues dès
ce jalon. Les autres sections viennent ensuite s'y greffer.

## Vue d'ensemble

| Jalon | Objectif                                   | Dépend de | État    |
| ----- | ------------------------------------------ | --------- | ------- |
| J0    | Fondations du projet                       | —         | Terminé |
| J1    | Modèle de données immuable                 | J0        | Terminé |
| J2    | Identité → PDF paginé → aperçu              | J1        | Terminé |
| J3    | Formulaires de toutes les sections          | J2        | Terminé |
| J4    | Undo / redo                                 | J3        | Terminé |
| JD    | Résorption des dettes structurelles         | J4        | Terminé |
| J6    | Photo de session                            | JD        | Terminé |
| J7    | Export PDF                                  | J6        | Terminé |
| JN    | Notifications                               | J7        | Terminé |
| J8    | Catalogue de modèles et réglages            | JD, JN    | Terminé |
| JS    | Sections personnalisées                     | JD        | Terminé |
| J5    | Persistance SQLite et gestion multi-CV      | JD        | Terminé |
| JZ    | Moteur de zones et modèles à deux zones     | J8        | Terminé |
| J9    | Finitions et validation du MVP              | J5, JZ, JS | Terminé, hors vérifications manuelles |
| JP    | Photo enregistrée avec le CV                | J9        | Terminé |

### Ordre conseillé pour les jalons restants

**JS → J5 → JZ → J9.** Les identifiants des jalons sont conservés pour ne pas
casser les références ; leur numéro ne définit pas l'ordre d'implémentation.
La colonne « Dépend de » indique les prérequis techniques, pas les priorités.

1. **JS — Sections personnalisées :** compléter le contenu de `CvDocument`,
   sa sérialisation, les formulaires, l'historique et le rendu PDF sur les cinq
   modèles existants. SQLite n'est pas nécessaire pour ces travaux. Faire JS
   avant J5 évite de modifier le format JSON juste après sa première mise sur
   disque ; cela ne supprime pas le besoin d'une stratégie de migration.
2. **J5 — Persistance et multi-CV :** rendre le travail durable avec le
   document ainsi complété. Valider ici la réouverture des sections
   personnalisées et des réglages du catalogue, ainsi que l'isolation des
   photos et des historiques entre CV. La sauvegarde est prioritaire sur
   l'ajout des trois modèles restants pour rendre l'application utilisable
   au quotidien.
3. **JZ — Moteur de zones :** compléter les huit modèles et éprouver leur
   pagination avec les sections standard et personnalisées. JZ ne dépend
   pas de SQLite et pourrait être réalisé avant J5 si le rendu devient la
   priorité ; son placement ici est un choix de livraison.
4. **J9 — Validation du MVP :** réunir persistance, sections personnalisées
   et huit modèles dans les scénarios de bout en bout.

J5 ne bloque donc ni J6, ni J7, ni J8, déjà livrés en session, ni le
développement de JS ou JZ. Il reste indispensable avant la validation du
MVP. Les contrôles après redémarrage de J6, J8 et JS sont regroupés au J5.

## État du projet

### JP livré, au 20 septembre 2026

`fvm flutter analyze` ne signale aucun problème et les 632 tests passent. La
photo est enregistrée avec le CV, ce que le MVP renvoyait après lui (section
13 du cahier des charges, mise à jour). Points à connaître :

- **la photo a sa propre colonne**, et non une place dans le document JSON :
  la sauvegarde automatique réécrit ce document à chaque salve de frappe, et
  une image y aurait été réécrite avec lui, à chaque fois. `CvRepository.save`
  ne touche jamais à la photo ; `readPhoto` et `savePhoto` s'en chargent, et
  la sauvegarde automatique leur tient une file distincte ;
- **le schéma passe en version 2.** Une base en version 1 gagne la colonne par
  `addColumn`, et ses CV la reçoivent vide, ce qui décrit bien leur état :
  la photo vivait alors le temps de la session ;
- **une image est ramenée à 600 pixels de côté** à la sélection
  (`lib/shared/images/photo_bytes.dart`). Une image déjà assez petite est
  gardée telle quelle : la ré-encoder la transformerait en PNG plus lourd,
  `dart:ui` ne sachant pas écrire de JPEG. C'est le prix de l'absence de
  dépendance supplémentaire ;
- **dupliquer un CV copie sa photo**, y compris lorsque celle du CV source
  n'est pas encore écrite : la copie la prend alors dans la session.

### J9 livré, au 20 septembre 2026

`fvm flutter analyze` ne signale aucun problème, les 607 tests passent et
`fvm flutter build windows` produit un binaire. Le MVP est complet, à deux
vérifications manuelles près, décrites plus bas. Points à connaître :

- **les scénarios de validation vivent dans `test/acceptance/`**, un critère
  de la section 12 par `test`. `mvp_acceptance_test.dart` rejoue l'application
  sur une vraie base SQLite, jusqu'au texte du PDF ;
  `export_acceptance_test.dart` pilote l'interface pour l'export et les
  notifications ;
- **une entrée-sortie réelle ne se termine jamais sous le temps simulé d'un
  test de widgets.** L'export attendait `XFile.saveTo` : le fichier était bien
  écrit par le système, mais la suite du code ne reprenait pas, et la
  notification n'apparaissait jamais. Le dialogue d'enregistrement, l'écriture
  du fichier et l'ouverture du dossier passent donc par des providers
  (`lib/shared/system/`), remplacés dans les tests. C'est aussi ce qui rend le
  chemin d'échec de l'export vérifiable ;
- **l'ancien trou de la gestion d'erreurs était le démarrage.** Tout le reste
  était couvert depuis le J5 ; mais une base verrouillée par une autre
  instance faisait échouer la lecture de la liste, et l'application
  disparaissait sans rien afficher. `bootstrap` rattrape désormais cet échec ;
- **le nom d'éditeur est `Fehizoro`.** Le changer de nouveau déplacerait
  `%APPDATA%\Fehizoro\cv_maker\` et perdrait les CV déjà enregistrés ;
- **l'action « Ouvrir le dossier »**, laissée en suspens au JN, est branchée
  sur `url_launcher`, ajouté pour l'occasion. Elle ouvre le dossier, pas le
  PDF : lancer le lecteur associé n'est pas ce que la notification promet.

Restent deux vérifications qu'aucun test ne peut faire, faute de fenêtre :
fermer la fenêtre pendant une saisie, et le premier lancement sur une machine
Windows propre et sans réseau.

### JZ livré, au 19 septembre 2026

`fvm flutter analyze` ne signale aucun problème et les 530 tests passent. Le
catalogue propose les huit modèles du handoff : bandeau latéral, latéral clair
et contraste rejoignent les cinq modèles en une colonne. Points à connaître :

- **la colonne latérale est émise après le corps page par page**, et non après
  tout le document : un fichier PDF porte un flux de contenu par page, et une
  colonne qui s'affiche en page 1 ne peut pas être lue après la page 2. Un ATS
  lit donc le corps de la page 1, la colonne, puis le corps de la page 2. La
  colonne reste un bloc d'un seul tenant, jamais entrelacé ligne à ligne avec
  le corps ;
- **un titre pouvait rester seul en bas de page** dans les cinq modèles
  existants, contrairement à ce qu'annonçait le J2 : `MultiPage` coupe une
  `Column` entre ses enfants, y compris entre le titre et son premier élément.
  Le bloc titre et premier élément est désormais insécable (`KeepTogether`),
  et un test balaie les positions de coupure sur les huit modèles ;
- les tests lisent enfin le **texte** du PDF, dans l'ordre d'émission, grâce à
  un extracteur propre aux PDF du paquet `pdf` (`test/helpers/pdf_text.dart`) :
  l'ordre de lecture, l'absence de perte et l'absence de répétition en tête de
  page sont vérifiés sur le texte, et non plus sur la taille du fichier ;
- les trois nouveaux modèles ont été affinés visuellement : panneaux latéraux
  en retrait et arrondis, titres sur fond léger, dates sous les intitulés et
  couleurs de texte adoucies. Contraste utilise désormais un nom en 30 pt et
  un filet de 48 pt, ajustements voulus par rapport au handoff initial.

### J5 livré, au 18 septembre 2026

`fvm flutter analyze` ne signale aucun problème et les 480 tests passent. Les
CV sont enregistrés dans une base SQLite locale et retrouvés au redémarrage ;
l'application en gère plusieurs, chacun avec son historique de session. Points
à connaître :

- la base est créée dans `%APPDATA%\com.example\cv_maker\cv_maker.sqlite` :
  le nom d'éditeur `com.example` vient du gabarit du projet Windows et reste à
  remplacer au J9, avant toute diffusion : le changer ensuite déplacerait le
  dossier, et les CV déjà enregistrés ne seraient plus retrouvés ;
- la date d'un CV en base est celle de son **écriture**, et non celle de la
  modification restaurée : un état remis par une annulation remplace donc bien
  la version enregistrée, malgré la garde contre les écritures périmées ;
- l'application s'ouvre sur un **tableau de bord** des CV, et non plus sur le
  dernier CV modifié : c'est un écart voulu au handoff, reporté dans le cahier
  des charges. Il remplace aussi le dialogue « Mes CV » : le bouton de l'en-tête
  de l'éditeur ramène au tableau de bord. Le CV d'exemple ne sert plus
  qu'aux tests ;
- la sauvegarde avant fermeture repose sur `AppLifecycleListener`. Elle est
  couverte par les tests, mais la fermeture réelle de la fenêtre avec une
  saisie en attente reste à vérifier à la main au J9.

### Avant le J5

`fvm flutter analyze` ne signalait aucun problème et les 253 tests passaient.

Le jalon JD a résorbé les deux dettes structurelles qui bloquaient la fin du
J2 : `CvDocument` est désormais la seule représentation d'un CV dans
l'application, et le générateur PDF ne lit sa mise en forme que dans une
`CvDesignSpec`. Les jalons J2, J3, J4, J6 et J7 sont terminés.

Le **J5 reste entier** : `drift` et `drift_flutter` figurent dans
`pubspec.yaml` mais ne sont utilisés nulle part. Rien n'est persisté d'un
lancement à l'autre : retrouver le modèle choisi au J8 à la réouverture
reste une validation d'intégration à réaliser au J5. `CvDocument.toJson` est prêt à
devenir la colonne document de la table drift.

Trois changements de comportement introduits par le JD, à connaître :

- toutes les sections facultatives sont visibles au départ, alors que les
  centres d'intérêt et les références étaient masqués par l'ancien état de
  visibilité provisoire ;
- le CV d'exemple du J1 remplit toutes les sections et occupe donc deux pages
  A4, contre une seule pour l'ancien jeu de données ;
- les projets exposent leur rôle et leur lien, et la date d'une certification
  s'affiche en regard de son intitulé plutôt que dans celui-ci.

### Élargissement du périmètre au 18 septembre 2026

La mise à jour de `design_handoff_cv_maker/` élargit le MVP sur trois points,
reportés dans le cahier des charges :

1. **Le catalogue passe de trois à huit modèles** et gagne deux réglages
   enregistrés par CV : la couleur d'accent, dans une palette fermée de cinq
   valeurs, et l'affichage de la photo. Le J8 est réécrit en conséquence.
2. **Trois des huit modèles ne tiennent pas en une seule colonne** — bandeau
   latéral, latéral clair et titres en marge. Ils demandent un moteur de zones
   dans le générateur PDF, qui était jusqu'ici hors périmètre pour des raisons
   de compatibilité ATS. Le handoff lève cette réserve en imposant que le
   bandeau soit émis comme un bloc distinct placé après le corps dans l'ordre
   du document. Ces trois modèles forment donc le jalon **JZ**, séparé du J8 :
   les cinq modèles en une colonne se livrent sans lui.
3. **Les sections personnalisées** apparaissent, avec leurs trois types de
   contenu. Elles touchent le modèle de données, les formulaires, le générateur
   PDF et la persistance : elles forment le jalon **JS**.

Les notifications décrites par le handoff, communes à l'export et au catalogue,
forment le jalon **JN**, prérequis du J8.

Les jalons **JN** et **J8** sont livrés. Trois points à connaître :

- les identifiants des modèles ont changé : `professional`, `modern` et
  `minimal` sont devenus `classic`, `banner` et `academic`, rejoints par
  `plain` et `compact`. Aucun CV n'étant encore enregistré, il n'y a rien à
  migrer, et `CvDesign.fromId` couvre le cas d'un identifiant inconnu ;
- le générateur PDF n'est pas déterministe : le paquet `pdf` termine chaque
  document par un identifiant aléatoire. Les tests comparent donc une empreinte
  qui l'ignore (`test/helpers/pdf_bytes.dart`). Sans cela, un test d'égalité
  d'octets échouerait toujours et un test de différence réussirait toujours —
  deux assertions antérieures étaient dans ce second cas ;
- le JZ reste à faire : le catalogue ne propose que cinq des huit modèles du
  handoff.

Le dernier point du **J3** est levé, et sa vérification a mis au jour deux
défauts du générateur, tous deux corrigés :

1. **Un paragraphe plus haut qu'une page faisait échouer la génération**, et
   donc l'aperçu comme l'export. `MultiPage` ne coupe un texte que si celui-ci
   l'autorise explicitement ; ce n'était pas le cas. Une description fleuve
   d'environ mille mots suffisait à bloquer l'application.
2. **Une liste de compétences ou de langues dépassant une page échouait
   également**, pour une raison voisine : `MultiPage` scinde une colonne entre
   ses enfants, jamais à l'intérieur de l'un d'eux. Le texte long devait donc
   sortir de la colonne qui porte le titre de section. Seul un fragment borné
   accompagne désormais le titre, ce qui préserve la règle du titre solidaire
   sans rendre le bloc indivisible.

Les CV de taille ordinaire ne sont pas affectés par ces corrections : le
découpage ne se déclenche qu'au-delà d'environ sept lignes de texte sous un
titre de section.

---

## J0 — Fondations du projet

**Objectif :** un squelette d'application structuré et prêt à accueillir les
fonctionnalités.

- [x] Ajouter les dépendances de base :
  - `flutter_riverpod` (gestion d'état) ;
  - `freezed`, `freezed_annotation`, `json_serializable`, `build_runner`
    (modèles immuables et sérialisation JSON) ;
  - `pdf` et `printing` (génération et affichage du PDF) ;
  - `drift`, `drift_flutter`, `drift_dev` et `path_provider` (base SQLite
    typée sous Windows) ;
  - `file_selector` (dialogue d'enregistrement natif) ;
  - `uuid` (identifiants stables).
- [x] Créer l'arborescence `lib/app`, `lib/core`, `lib/features/cv/{data,domain,presentation}`, `lib/shared`.
- [x] Mettre en place `ProviderScope`, le thème de l'application et l'écran
  principal.
- [x] Construire la mise en page en trois zones : navigation des sections,
  formulaire, aperçu PDF (contenus factices).
- [x] Intégrer une police gérant les accents (par exemple Noto Sans ou Inter)
  dans les assets pour le PDF.
- [x] Prévoir toutes les ressources nécessaires au fonctionnement hors ligne,
  sans téléchargement à l'exécution, et les inclure dans le build Windows.
- [x] Remplacer le test par défaut par des tests de l'écran principal.

**Terminé quand :** l'application affiche les trois zones sous Windows et la
navigation change la section sélectionnée.

---

## J1 — Modèle de données immuable

**Objectif :** représenter un CV complet, indépendamment de l'interface et du
PDF.

- [x] Définir `CvDocument` et ses sous-modèles : informations personnelles,
  profil, expériences, formations, compétences, langues, certifications,
  projets, centres d'intérêt, références ou informations complémentaires,
  préférences de présentation.
- [x] Distinguer les données persistées du CV de son état de session, qui
  accueillera la photo non persistée au J6. Prévoir un historique capable de
  restaurer les deux ensemble.
- [x] Donner à chaque élément répétable un identifiant stable et un ordre.
- [x] Modéliser l'ordre et la visibilité des sections.
- [x] Implémenter la sérialisation JSON (aller-retour sans perte).
- [x] Écrire les opérations métier pures : ajouter, modifier, supprimer et
  réordonner un élément ; afficher ou masquer une section.
- [x] Créer un `CvDocument` d'exemple réutilisable dans les tests.

**Terminé quand :** toutes les opérations et la sérialisation sont couvertes par
des tests unitaires.

---

## J2 — Tranche verticale : identité → PDF paginé → aperçu

**Objectif :** valider tôt le cœur du produit, de la saisie à l'affichage du PDF
réel, avec pagination et fonctionnement hors ligne.

- [x] Créer le provider du CV en cours d'édition.
- [x] Développer le formulaire des informations personnelles (sans photo).
- [x] Définir la description de modèle (`CvDesignSpec`) avec ses quatre groupes
  de propriétés décrits en section 5.9 du cahier des charges : structure,
  en-tête, jetons visuels, décorations de section.
- [x] Créer le générateur PDF : une fonction pure
  `(CvDocument, CvDesignSpec) → bytes PDF`, au format A4 portrait, avec texte
  sélectionnable. Le générateur lit toutes ses décisions de mise en forme dans
  la description ; aucune couleur, taille ni variante ne doit être codée en dur
  ni dépendre d'un test sur l'identité du modèle. ⚠ La photo du J6 se passe en
  paramètre nommé facultatif : elle n'est pas persistée et n'appartient donc pas
  au document.
- [x] Fournir la description du modèle professionnel par défaut, en une seule
  colonne.
- [x] Implémenter la pagination automatique sur plusieurs pages A4 avant
  l'ajout des formulaires de toutes les sections.
- [x] Ne jamais séparer un titre de section de son premier contenu.
- [x] Tester le moteur de mise en page avec des données d'exemple longues :
  plusieurs sections, éléments répétés et description dépassant une page,
  sans perte de contenu ni débordement.
- [x] Afficher le PDF dans la zone de droite.
- [x] Régénérer automatiquement le PDF après une courte pause dans la saisie
  (debounce).
- [x] Ajouter le bouton « Rafraîchir » qui force la régénération.
- [x] Afficher un indicateur pendant la génération.
- [x] Garantir qu'une génération plus ancienne ne remplace jamais une plus
  récente. ⚠ Obtenu par l'invalidation du provider d'aperçu plutôt que par un
  numéro de version explicite ; l'export compare les futures avant d'écrire.
- [x] Permettre le zoom et le défilement dans l'aperçu.

**Terminé quand :** une saisie dans le formulaire apparaît dans le PDF à droite,
automatiquement ou via « Rafraîchir », accents compris, sans connexion réseau.
Les données d'exemple longues produisent plusieurs pages A4 consultables dans
l'aperçu, sans titre isolé ni contenu tronqué.

---

## J3 — Formulaires de toutes les sections

**Objectif :** pouvoir renseigner l'intégralité d'un CV.

- [x] Profil professionnel.
- [x] Expériences : champs, option « En cours », ajout, suppression,
  réorganisation.
- [x] Formations : champs, ajout, suppression, réorganisation.
- [x] Compétences : catégorie et niveau facultatifs, réorganisation,
  suppression.
- [x] Langues : niveau choisi ou saisi, réorganisation, suppression.
- [x] Sections complémentaires : certifications, projets, centres d'intérêt,
  références ou informations complémentaires.
- [x] Afficher ou masquer chaque section facultative.
- [x] Confirmation avant les suppressions importantes.
- [x] Rendre toutes ces sections dans le modèle PDF.
- [x] Vérifier la pagination de chaque section avec des contenus longs en
  réutilisant le moteur validé au J2. Chaque section est éprouvée
  individuellement, sur les cinq modèles, avec vérification du format A4 et de
  la croissance du document. Ce travail a révélé deux défauts du générateur,
  corrigés : voir ci-dessous.

**Terminé quand :** chaque section est éditable et visible dans le PDF, et les
sections masquées n'y apparaissent plus.

---

## J4 — Undo / redo

**Objectif :** annuler et rétablir toute modification du CV pendant la session.

- [x] Implémenter un historique basé sur les états immuables du CV (piles
  « passé » et « futur »), incluant l'état de session prévu au J1.
- [x] Regrouper les frappes successives dans un même champ en une seule étape.
- [x] Brancher toutes les modifications existantes sur l'historique : saisie,
  ajout, suppression, réorganisation, visibilité des sections.
- [x] Raccourcis `Ctrl+Z`, `Ctrl+Y` et `Ctrl+Maj+Z`.
- [x] Boutons « Annuler » et « Rétablir », désactivés lorsqu'aucune action n'est
  disponible.
- [x] Synchroniser les champs de formulaire avec l'état restauré.
- [x] Déclencher la régénération du PDF après une annulation ou un
  rétablissement.

**Terminé quand :** toute modification des jalons précédents peut être annulée
puis rétablie, et le formulaire comme le PDF reflètent l'état restauré.

---

## JD — Résorption des dettes structurelles

**Objectif :** ramener le code sur les fondations posées au J1 et prévues au J2,
avant que la persistance ne fige la représentation actuelle.

Ce jalon n'ajoute aucune fonctionnalité visible. Il ferme les points restants du
J2 et du J8, et doit précéder le J5 : `CvDocument.toJson` est destiné à devenir
la colonne document de la table drift ; enregistrer la structure actuelle
imposerait une migration de schéma pour en sortir.

Les deux étapes convergent sur la signature du générateur PDF, aujourd'hui
`(EditorDraft, Map<CvSection, bool>) → bytes` et attendue en
`(CvDocument, CvDesignSpec) → bytes` : chacune en change une moitié. JD.1 vient
en premier parce qu'elle est isolée et ne dépend pas de la structure qui porte
le contenu.

### JD.1 — Décrire les modèles par des données

- [x] Créer `CvDesignSpec` dans le domaine, avec les quatre groupes de
  propriétés de la section 5.9 du cahier des charges : structure, en-tête,
  jetons visuels, décorations de section.
- [x] Décrire les trois modèles intégrés par une constante `CvDesignSpec`, le
  modèle professionnel servant de repli.
- [x] Exposer `CvDesign.spec` comme unique correspondance entre l'identifiant du
  modèle et sa description.
- [x] Remplacer dans le générateur PDF chaque test sur `CvDesign` par une
  lecture dans la description : couleur d'accent, taille et casse des titres,
  interlettrage, cadre des en-têtes de section.
- [x] Vérifier par un test que le générateur ne référence plus `CvDesign`.
- [x] Couvrir le rendu de chacune des trois descriptions.

**Terminé quand :** le générateur PDF ne connaît plus que `CvDesignSpec`, et
ajouter un modèle ne demande qu'une nouvelle constante.

### JD.2 — Brancher le modèle du J1

- [x] Remplacer `EditorDraft` par `CvSession` dans le provider d'édition,
  historique compris.
- [x] Introduire, par section, des descripteurs reliant le libellé affiché d'un
  champ à sa lecture et à son écriture typées, afin de conserver le formulaire
  générique et ses tests.
- [x] Rendre au sélecteur de mois son type : `CvMonthYear` plutôt qu'une chaîne
  formatée. Un effacement se distingue désormais d'une annulation.
- [x] Traiter « En cours » comme le booléen `CvDateRange.isCurrent`.
- [x] Faire lire au générateur PDF un `CvDocument`, et la visibilité des
  sections depuis `CvPresentationPreferences`. L'état de visibilité provisoire
  a disparu.
- [x] Supprimer `EditorDraft` et les accès par libellé français
  (`fields['Prénom']`).
- [x] Mettre à jour les tests concernés et couvrir l'aller-retour JSON du
  document tenu par l'éditeur.

**Terminé quand :** `CvDocument` est la seule représentation d'un CV dans
l'application, l'aperçu et l'export sont inchangés à contenu égal, et
`fvm flutter analyze` comme `fvm flutter test` réussissent.

---

## J5 — Persistance SQLite et gestion multi-CV

**Objectif :** retrouver ses CV après un redémarrage et en gérer plusieurs.

- [x] Initialiser la base drift (`drift_flutter`) dans le dossier de données de
  l'application. ⚠ Les dates sont stockées en texte ISO-8601
  (`store_date_time_values_as_text`) : en secondes Unix, le réglage par
  défaut, deux écritures rapprochées deviendraient indiscernables.
- [x] Créer la table drift des CV : identifiant, nom, dates, document JSON
  produit par `CvDocument.toJson` (voir JD.2), avec un schéma versionné et une
  stratégie de migration. ⚠ Deux versions distinctes : celle du schéma SQL
  (`schemaVersion`) et celle du format JSON, enregistrée sur chaque ligne
  (`formatVersion`). Un document écrit par une version plus récente est
  refusé plutôt que relu de travers.
- [x] Implémenter le repository : lister, lire, créer, mettre à jour,
  supprimer. ⚠ `CvRepository` est une interface : les tests d'interface
  utilisent un stockage en mémoire capable de simuler des échecs.
- [x] Sauvegarde automatique après modification (debounce de 600 ms, comme le
  prévoit le handoff).
- [x] Sauvegarder également les états restaurés par undo/redo.
- [x] Garantir qu'une sauvegarde ancienne ne remplace pas une version récente.
  ⚠ Deux protections : les écritures passent par une file unique, et la base
  ignore une version plus ancienne que celle enregistrée.
- [x] Finaliser les sauvegardes en attente lors d'un changement de CV et avant
  la fermeture normale de l'application ; signaler tout échec. ⚠ Un échec
  retient la fermeture une fois, avec une notification ; fermer de nouveau
  quitte sans enregistrer. Un échec au changement de CV n'empêche pas de
  changer : les modifications restent en attente et l'indicateur passe en
  erreur.
- [x] Tester un changement de CV et une fermeture avec sauvegarde en attente,
  puis vérifier les données à la réouverture. Les tests relancent
  l'application sur le même fichier SQLite.
- [x] Indicateur de l'état de sauvegarde (enregistré, en cours, erreur), avec
  « Réessayer ». ⚠ L'icône d'attente ne tourne pas, pour la même raison que
  celle des notifications.
- [x] Écran ou panneau de liste des CV : créer, renommer, dupliquer, supprimer
  avec confirmation. ⚠ D'abord livré comme le dialogue « Mes CV » du
  handoff, puis remplacé par un tableau de bord plein écran : grille de
  cartes, recherche insensible à la casse et aux accents (Ctrl+F), tri par
  date ou par nom, création par un bouton, une tuile ou Ctrl+N, actions de
  chaque CV dans un menu. Sans CV, il affiche l'accueil du premier lancement.
- [x] ~~Rouvrir le dernier CV modifié au démarrage.~~ Remplacé par le tableau
  de bord, où le dernier CV modifié apparaît en premier. Le démarrage ne lit
  plus que la liste des CV : un document illisible ne peut pas le bloquer, et
  son ouverture est signalée comme un échec.
- [x] Conserver un historique undo/redo distinct par CV pendant la session, et
  inclure le renommage dans l'historique. ⚠ Renommer un CV fermé l'inscrit
  dans l'historique de ce CV : l'annulation est disponible une fois le CV
  ouvert.
- [x] Démarrer chaque nouvelle session avec un historique vide.
- [x] Vérifier après réouverture les sections personnalisées du JS (si JS
  est livré, comme prévu dans l'ordre conseillé), leur contenu, leur ordre
  et leur visibilité, ainsi que le modèle et les réglages du J8.
- [x] Vérifier que les photos du J6 restent propres à chaque CV pendant la
  session, ne sont jamais écrites en base et disparaissent au redémarrage.
  ⚠ Dépassé par le JP : la photo est désormais enregistrée, et dupliquer un
  CV la copie. Ce qui reste vrai : elle est propre à chaque CV, et le
  document JSON ne la contient pas.

**Terminé quand :** les CV et leurs modifications sont retrouvés après un
redémarrage, et changer de CV conserve l'historique de chacun pendant la
session.

---

## J6 — Photo de session

**Objectif :** ajouter une photo au CV sans la persister.

⚠ Le **JP** lève la restriction : la photo est enregistrée avec le CV. Ce
jalon reste décrit tel qu'il a été livré ; ce qui en survit est signalé ligne
à ligne.

- [x] Sélectionner une image depuis le disque.
- [x] ~~Conserver la photo en mémoire, associée au CV, pendant la session
  uniquement.~~ Remplacé par le JP.
- [x] Exclure la photo du JSON sauvegardé. Vérifié sur `CvDocument.toJson`,
  puis sur la base au J5. ⚠ Toujours vrai : le JP lui donne sa propre
  colonne, il ne la met pas dans le document.
- [x] Afficher la photo dans le PDF.
- [x] Retirer ou remplacer la photo.
- [x] Inclure les changements de photo dans l'historique undo/redo.

**Terminé quand :** la photo apparaît dans le PDF pendant la session et est
exclue du JSON du document.

---

## J7 — Export PDF

**Objectif :** enregistrer localement le PDF paginé déjà validé dans l'aperçu.

- [x] Bouton « Exporter » avec dialogue d'enregistrement Windows (nom et
  emplacement).
- [x] Si le PDF affiché n'est pas à jour, déclencher ou attendre la
  régénération avant l'export.
- [x] Mettre à jour l'aperçu avec ce PDF et exporter exactement les mêmes
  octets.
- [x] Message clair en cas d'échec de l'export.

**Terminé quand :** un CV long est exporté sur plusieurs pages, identique à
l'aperçu, même si l'export est demandé juste après une modification.

---

## JN — Notifications

**Objectif :** remplacer les messages posés dans l'aperçu par les notifications
décrites par le handoff, communes à l'export et au catalogue.

- [x] Créer le contrôleur de notifications : file de trois au maximum, la plus
  récente en bas à droite, disparition automatique après quelques secondes,
  un peu plus longtemps avec une action, croix de fermeture toujours présente.
- [x] Passer par un `Overlay` plutôt que par `ScaffoldMessenger`, afin que les
  notifications survivent au changement d'onglet en fenêtre étroite. La couche
  est posée au-dessus du `Navigator` et enveloppée dans son propre `Overlay`,
  sans lequel un tooltip ou un menu ne pourrait pas s'y afficher.
- [x] Décrire chaque notification par une donnée : nature, titre, texte
  secondaire facultatif, action facultative.
- [x] Couvrir trois des quatre cas du handoff : régénération du PDF avant un
  export, export réussi, export échoué avec « Réessayer », modèle appliqué.
  ⚠ L'action « Ouvrir le dossier » de l'export réussi n'est pas branchée : le
  chemin est affiché, mais l'ouverture de l'explorateur demande une dépendance
  supplémentaire. À traiter au J9.
- [x] Retirer du panneau d'aperçu les messages qu'elles remplacent.
- [x] Tester l'empilement, la limite de trois, la fermeture manuelle et la
  disparition automatique sans faire échouer les temporisations des tests.
  ⚠ L'icône d'attente ne tourne pas : une animation infinie bloquerait
  `pumpAndSettle` dans tous les tests qui traversent un export.

**Terminé quand :** un export réussi, un export échoué et l'application d'un
modèle produisent chacun leur notification, actionnable et refermable.

---

## J8 — Catalogue de modèles et réglages

**Objectif :** offrir les modèles intégrés et leurs deux réglages, et permettre
d'en changer sans toucher au contenu.

Le périmètre de ce jalon couvre les **cinq modèles en une seule colonne** :
classique, sobre, en-tête coloré, compact et académique. Les trois modèles à
deux zones relèvent du JZ. L'interface du catalogue, elle, est livrée complète
dès ce jalon.

- [x] Décrire chaque modèle intégré par une `CvDesignSpec`. Aucune branche
  conditionnelle sur l'identifiant du modèle ne subsiste dans le générateur PDF.
- [x] Porter le catalogue sur la maquette du handoff : grille de vignettes à
  quatre colonnes, modèle courant identifié par une bordure et une pastille,
  panneau d'aperçu et de réglages à droite, pied rappelant la compatibilité
  ATS, actions « Annuler » et « Appliquer le modèle ».
- [x] Rendre les vignettes et le grand aperçu depuis le PDF réel du CV en
  cours, et non depuis une image livrée dans les assets. Les trois vignettes
  PNG livrées dans les assets ont été retirées.
- [x] Ne régénérer que l'aperçu du modèle sélectionné quand un réglage change :
  les autres vignettes gardent les réglages d'ouverture du catalogue.
- [x] Ajouter les cinq modèles en une seule colonne, chacun décrit par une
  constante, le modèle classique servant de repli.
- [x] Permettre au modèle académique d'imposer son ordre de sections
  (formations avant expériences) sans modifier l'ordre enregistré dans le CV.
- [x] Ajouter le réglage de couleur d'accent : sélecteur de couleur libre —
  teinte, saturation, luminosité et saisie hexadécimale — avec la palette en
  raccourci, ignoré par un modèle sans couleur.
- [x] Ajouter le réglage d'affichage de la photo, indisponible tant qu'aucune
  photo n'est chargée dans la session.
- [x] Enregistrer le modèle, la couleur d'accent et l'affichage de la photo
  avec le CV, et retomber sur le modèle classique si l'identifiant est inconnu.
  Enregistrés sur disque depuis le J5.
- [x] Déclencher la régénération du PDF au changement de modèle et inclure ce
  changement dans l'historique undo/redo.
- [x] Afficher la notification « Modèle appliqué » à la validation.
- [x] Tester qu'un changement de modèle ne modifie ni le contenu, ni l'ordre,
  ni la visibilité des sections.
- [x] Tester que les deux réglages atteignent le PDF et qu'ils survivent à une
  annulation puis à un rétablissement.

**Terminé quand :** l'utilisateur choisit un modèle et ses deux réglages dans le
catalogue, l'aperçu et l'export les reflètent, et aucun contenu n'est perdu au
passage d'un modèle à l'autre. La conservation du choix après redémarrage
est validée au J5.

---

## JZ — Moteur de zones et modèles à deux zones

**Objectif :** livrer les trois modèles que la structure en une seule colonne ne
permet pas d'exprimer.

Ce jalon existe parce que le générateur actuel émet une suite de blocs sur toute
la largeur. Les modèles à bandeau latéral et à titres en marge demandent de
placer du contenu dans une zone secondaire, sur plusieurs pages, sans casser
l'ordre de lecture attendu par les systèmes ATS.

- [x] Étendre la description de modèle : position et largeur de la zone
  secondaire, sections qui y sont placées. ⚠ Les propriétés inertes
  `columns`, `sidebarPosition` et `sidebarSections` sont remplacées par
  `CvDesignStructure.sidebar` (`CvDesignSidebar` : côté, largeur en fraction
  de page, sections, coordonnées et photo) et par `titleMargin` pour les
  titres en marge. Les couleurs de la colonne rejoignent les jetons visuels.
- [x] Émettre la zone secondaire comme un bloc distinct placé après le corps
  dans l'ordre du document, afin que l'extraction linéaire reste correcte.
  ⚠ Après le corps **de chaque page** : voir ci-dessus.
- [x] Gérer la continuation de la zone secondaire sur plusieurs pages.
  ⚠ Assurée par `ZonedFlow` (`lib/core/pdf/pdf_zones.dart`) : chaque zone
  reprend sur la page suivante là où elle s'est arrêtée, y compris au milieu
  d'un paragraphe. Le fond arrondi de la colonne est peint en retrait sur chaque
  page, sans texte.
- [x] Ajouter les modèles bandeau latéral, latéral clair et contraste.
- [x] Vérifier par un test que l'ordre d'émission du texte reste celui de la
  lecture humaine, quel que soit le modèle.
- [x] Vérifier qu'aucun modèle ne place de texte dans un en-tête de page ni ne
  le rend sous forme d'image.
- [x] Si JS est livré, comme prévu dans l'ordre conseillé, vérifier le rendu
  et la pagination de ses trois types de contenu sur les huit modèles. Le
  test vérifie aussi, sur le texte extrait, qu'aucun élément n'est perdu.

**Terminé quand :** les huit modèles du catalogue sont disponibles, et le texte
d'un modèle à bandeau s'extrait dans l'ordre de lecture attendu.

---

## JS — Sections personnalisées

**Objectif :** permettre à l'utilisateur de créer les sections que les sections
standard ne couvrent pas.

- [x] Modéliser une section personnalisée : identifiant, nom unique de 40
  caractères au plus, type figé, visibilité, ordre, contenu. L'ordre est la
  position dans `CvDocument.customSections`, la visibilité est portée par la
  section elle-même.
- [x] Modéliser les trois types de contenu : texte libre, liste datée, liste
  simple. Les deux listes partagent `CvCustomItem` ; une liste simple n'en
  utilise que le titre et la description.
- [x] Sérialiser ces sections avec le CV, sans perte à l'aller-retour. Un JSON
  sans la clé `customSections` se relit avec une liste vide.
- [x] Étendre l'ordre et la visibilité des sections à ces sections, qui se
  placent après les sections standard. ⚠ Une section est désignée par le type
  scellé `CvSectionRef`, que `CvSection` implémente : la navigation, la
  sélection, le formulaire et l'historique traitent les deux sortes de la même
  façon.
- [x] Ajouter le dialogue de création : nom, choix du type, mention que le type
  est définitif, refus des doublons et des noms vides. Les doublons sont
  cherchés aussi parmi les libellés des sections standard, sans tenir compte
  de la casse.
- [x] Ajouter le bouton « Ajouter une section » sous la liste des sections.
- [x] Sélectionner la nouvelle section dans le formulaire après sa création.
  Une section sélectionnée qui disparaît (suppression, annulation de la
  création) rend la main aux informations personnelles.
- [x] Réutiliser les formulaires génériques selon le type, et signaler dans
  l'en-tête qu'il s'agit d'une section personnalisée, avec son type et son
  nombre d'éléments. ⚠ Le bouton d'ajout reste « Ajouter un élément » : le
  singulier du nom (« Ajouter une publication ») demanderait d'en connaître le
  genre.
- [x] Permettre le renommage et la suppression, avec une confirmation qui
  rappelle le nombre d'éléments perdus et propose le masquage, par un bouton
  « Masquer » en plus du texte.
- [x] Rendre ces sections dans le PDF avec les composants des sections standard
  correspondantes, en respectant la règle du titre solidaire. Chaque type est
  éprouvé sous un contenu long sur les cinq modèles actuels.
- [x] Inclure création, renommage, suppression, masquage et saisie dans
  l'historique undo/redo.

**Terminé quand :** l'utilisateur crée une section de chaque type, la remplit,
la renomme, la masque et la supprime ; le PDF la reflète, l'historique restaure
ces opérations et la sérialisation JSON conserve toutes ses données. La
réouverture après redémarrage est validée au J5.

---

## J9 — Finitions et validation du MVP

**Objectif :** vérifier tous les critères d'acceptation et stabiliser.

- [x] Gestion des erreurs de sauvegarde, de lecture de base et de génération
  PDF. Le J5 couvrait déjà l'échec d'écriture (indicateur et « Réessayer »),
  l'échec à la fermeture et le document illisible au démarrage. Le dernier trou
  était le **démarrage lui-même** : une base verrouillée ou endommagée faisait
  échouer `repository.list()` et l'application disparaissait sans un mot. Elle
  affiche désormais un écran d'échec avec « Réessayer », qui relit les CV.
- [x] Remplacer le nom d'éditeur `com.example` du projet Windows, qui fixe le
  dossier de la base de données. ⚠ `CompanyName` vaut désormais `Fehizoro` :
  la base est dans `%APPDATA%\Fehizoro\cv_maker\cv_maker.sqlite`. Seul le
  projet Windows est concerné ; les autres plateformes sont hors périmètre.
- [ ] Vérifier à la main qu'une fermeture de la fenêtre pendant la saisie
  enregistre la dernière modification. ⚠ Le comportement est couvert par les
  tests (`handleRequestAppExit`), mais la fenêtre réelle reste à éprouver.
- [x] Présentation en onglets du formulaire et de l'aperçu sur une fenêtre
  étroite, notifications comprises. ⚠ Les onglets existaient depuis le J2 ;
  ce jalon ajoute la vérification qu'une notification émise dans l'onglet
  « Aperçu » reste visible après un passage à « Édition ».
- [x] Exécuter les scénarios de validation de bout en bout et vérifier
  l'absence de régressions entre les fonctionnalités des différents jalons.
- [x] Vérifier un par un les critères d'acceptation de la section 12 du cahier
  des charges. ⚠ Tous sauf ceux qui demandent une vraie fenêtre : ils sont
  regroupés dans les deux cases non cochées de ce jalon.
- [x] Générer et tester le build Windows (`fvm flutter build windows`).
- [ ] Sur une machine Windows propre, sans réseau, vérifier dès le premier
  lancement : édition, photo locale, aperçu multipage, sauvegarde, réouverture
  et export PDF avec les polices embarquées.
- [x] Mettre à jour le `README.md` (installation, lancement, tests).

**Terminé quand :** tous les critères d'acceptation sont validés et le build
Windows fonctionne sur une machine propre, entièrement hors ligne.

---

## JP — Photo enregistrée avec le CV

**Objectif :** retrouver sa photo à la réouverture d'un CV, ce que le J6
laissait à la session.

- [x] Ajouter la colonne `photo` à la table des CV, et la migration 1 → 2 qui
  la donne aux bases existantes.
- [x] Donner à la photo ses propres opérations de dépôt, `readPhoto` et
  `savePhoto`, et vérifier par un test que `save` ne l'écrit ni ne l'efface.
- [x] Tenir une file d'attente distincte dans la sauvegarde automatique : une
  photo s'écrit sans faire réécrire le document.
- [x] Relire la photo à l'ouverture d'un CV, et la copier à la duplication.
- [x] Ramener une image à 600 pixels de côté à la sélection, sans dépendance
  supplémentaire.
- [x] Enregistrer les photos restaurées par une annulation, comme le reste.
- [x] Reporter le changement dans le cahier des charges, qui le classait hors
  périmètre.

**Terminé quand :** une photo choisie, remplacée ou retirée se retrouve telle
quelle après un redémarrage, sans entrer dans le document JSON.

---

## Points d'attention

- **Performance de la génération PDF :** si la régénération devient lente sur un
  CV long, ajuster le délai de debounce ou générer le PDF dans un isolate.
- **Undo et champs texte :** le regroupement des frappes et la synchronisation
  des `TextEditingController` avec l'état restauré sont les parties les plus
  délicates du J4.
- **Cohérence aperçu / export :** l'export doit toujours s'appuyer sur la même
  génération que l'aperçu, grâce au numéro de version introduit au J2.
- **Choix des packages :** les packages listés au J0 sont des propositions à
  confirmer lors de la mise en place.
- **Ordre du JD :** JD.2 touche le provider d'édition, les formulaires, le
  générateur PDF et une bonne partie des tests. La faire passer par des
  descripteurs de champ plutôt que par des formulaires typés par section garde
  le diff proportionné ; des formulaires spécifiques n'apporteront quelque chose
  que le jour où les sections divergeront vraiment.
- **Compatibilité ATS :** les systèmes ATS lisent le PDF de façon linéaire.
  Une colonne latérale mal émise fait entrelacer les compétences avec les
  intitulés de poste et dégrade fortement l'extraction des champs ; le texte
  placé dans un en-tête de page est souvent ignoré. `ZonedFlow` peint donc ses
  zones dans l'ordre de sa liste, corps en premier, quelle que soit leur
  position sur la page. Tout nouveau modèle doit passer les tests d'ordre de
  lecture de `cv_pdf_test.dart`, qui bouclent sur `CvDesign.values`.
- **Extension du catalogue :** le moteur de zones existe désormais, mais le
  format de description n'a été éprouvé que sur les huit modèles intégrés.
  Avant d'exposer un manifeste chargé depuis un dossier utilisateur, décider
  quelles propriétés deviennent publiques : c'est ce format qu'il faudrait
  ensuite migrer.
- **Vignettes du catalogue :** les rendre depuis le PDF réel du CV en cours
  demande autant de générations que de modèles à l'ouverture du catalogue. Si
  cela devient perceptible, les produire en tâche de fond, du modèle courant
  vers les autres, et conserver le résultat le temps de la session. Les
  réglages, eux, ne régénèrent que la vignette du modèle sélectionné, qui
  partage sa clé avec le grand aperçu : une seule génération par changement.
- **Réglages contre description :** la couleur d'accent et l'affichage de la
  photo sont les deux seules propriétés qu'un CV peut surcharger. Elles se
  lisent donc en un seul endroit, `CvDocument.designSpec`, et non dispersées
  dans le générateur.
- **PDF non déterministe :** deux générations du même CV ne produisent jamais
  les mêmes octets, le paquet `pdf` y insérant un identifiant aléatoire. Tout
  test qui compare des PDF doit passer par `pdfFingerprint`, sous peine de ne
  rien vérifier du tout.
- **Animations infinies et tests :** un indicateur qui tourne sans fin fait
  expirer `pumpAndSettle`. Les notifications d'attente utilisent donc une icône
  fixe, et les vignettes du catalogue sont remplacées dans les tests d'interface
  plutôt que générées.
- **Widgets indivisibles dans le PDF :** `MultiPage` ne répartit sur plusieurs
  pages qu'un widget qui sait se couper, et ne scinde une colonne qu'entre ses
  enfants. Tout contenu de hauteur non bornée doit donc être émis comme frère
  du titre de section, avec `TextOverflow.span`, et jamais comme son enfant.
  C'est la contrainte à garder en tête en ajoutant une section au générateur,
  et notamment pour les sections personnalisées du JS.
- **Photo hors du document :** la photo est enregistrée, mais jamais dans
  `CvDocument`. Le document est réécrit à chaque salve de frappe ; une image
  qui y entrerait serait réécrite avec lui, et gonflerait le JSON d'un tiers
  en base64. Elle vit dans `CvSession`, sa propre colonne et ses propres
  opérations de dépôt.
- **Entrées-sorties réelles et tests de widgets :** un `await` sur une vraie
  entrée-sortie — écrire un fichier, créer un dossier temporaire — ne reprend
  jamais sous le temps simulé d'un `testWidgets` : le système fait le travail,
  mais la suite du code reste suspendue. Tout accès au disque déclenché par
  l'interface passe donc par un provider de `lib/shared/system/`, que le test
  remplace par une opération synchrone. Dans le corps d'un test, préférer les
  variantes `...Sync`.
- **Blocs insécables :** l'inverse est tout aussi vrai : une `Column` est
  coupée entre ses enfants dès qu'elle ne tient pas. Un groupe qui doit rester
  solidaire, comme un titre et son premier élément, passe par `KeepTogether`,
  et doit rester plus petit qu'une page.
