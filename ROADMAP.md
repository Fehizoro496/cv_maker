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
| J5    | Persistance SQLite et gestion multi-CV      | JD        | À faire |
| J6    | Photo de session                            | J5        | Terminé |
| J7    | Export PDF                                  | J6        | Terminé |
| J8    | Catalogue de modèles                        | JD, J5    | Partiel |
| J9    | Finitions et validation du MVP              | J7, J8    | À faire |

## État au 17 septembre 2026

`fvm flutter analyze` ne signale aucun problème et les 182 tests passent.

Le jalon JD a résorbé les deux dettes structurelles qui bloquaient la fin du
J2 : `CvDocument` est désormais la seule représentation d'un CV dans
l'application, et le générateur PDF ne lit sa mise en forme que dans une
`CvDesignSpec`. Les jalons J2, J3, J4, J6 et J7 sont terminés.

Le **J5 reste entier** : `drift` et `drift_flutter` figurent dans
`pubspec.yaml` mais ne sont utilisés nulle part. Rien n'est persisté d'un
lancement à l'autre, ce qui laisse en suspens le dernier point du J8 —
retrouver le modèle choisi à la réouverture. `CvDocument.toJson` est prêt à
devenir la colonne document de la table drift.

Trois changements de comportement introduits par le JD, à connaître :

- toutes les sections facultatives sont visibles au départ, alors que les
  centres d'intérêt et les références étaient masqués par l'ancien état de
  visibilité provisoire ;
- le CV d'exemple du J1 remplit toutes les sections et occupe donc deux pages
  A4, contre une seule pour l'ancien jeu de données ;
- les projets exposent leur rôle et leur lien, et la date d'une certification
  s'affiche en regard de son intitulé plutôt que dans celui-ci.

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
- [ ] Vérifier la pagination de chaque section avec des contenus longs en
  réutilisant le moteur validé au J2. ⚠ Un seul test couvre les sections
  répétées ; les autres ne sont pas vérifiées individuellement.

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

- [ ] Initialiser la base drift (`drift_flutter`) dans le dossier de données de
  l'application.
- [ ] Créer la table drift des CV : identifiant, nom, dates, document JSON
  produit par `CvDocument.toJson` (voir JD.2), avec un schéma versionné et une
  stratégie de migration.
- [ ] Implémenter le repository : lister, lire, créer, mettre à jour,
  supprimer.
- [ ] Sauvegarde automatique après modification (debounce).
- [ ] Sauvegarder également les états restaurés par undo/redo.
- [ ] Garantir qu'une sauvegarde ancienne ne remplace pas une version récente.
- [ ] Finaliser les sauvegardes en attente lors d'un changement de CV et avant
  la fermeture normale de l'application ; signaler tout échec.
- [ ] Tester un changement de CV et une fermeture avec sauvegarde en attente,
  puis vérifier les données à la réouverture.
- [ ] Indicateur de l'état de sauvegarde (enregistré, en cours, erreur).
- [ ] Écran ou panneau de liste des CV : créer, renommer, dupliquer, supprimer
  avec confirmation.
- [ ] Rouvrir le dernier CV modifié au démarrage.
- [ ] Conserver un historique undo/redo distinct par CV pendant la session, et
  inclure le renommage dans l'historique.
- [ ] Démarrer chaque nouvelle session avec un historique vide.

**Terminé quand :** les CV et leurs modifications sont retrouvés après un
redémarrage, et changer de CV conserve l'historique de chacun pendant la
session.

---

## J6 — Photo de session

**Objectif :** ajouter une photo au CV sans la persister.

- [x] Sélectionner une image depuis le disque.
- [x] Conserver la photo en mémoire, associée au CV, pendant la session
  uniquement.
- [x] Exclure la photo du JSON sauvegardé. ⚠ Vérifié sur `CvDocument.toJson` ;
  à reconfirmer sur la base au J5.
- [x] Afficher la photo dans le PDF.
- [x] Retirer ou remplacer la photo.
- [x] Inclure les changements de photo dans l'historique undo/redo.

**Terminé quand :** la photo apparaît dans le PDF pendant la session et est
absente après un redémarrage, sans erreur.

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

## J8 — Catalogue de modèles

**Objectif :** offrir plusieurs modèles intégrés et permettre d'en changer sans
toucher au contenu.

Ce jalon ne dépend que du J5 (le modèle sélectionné doit être persisté) et peut
donc être mené en parallèle du J6 et du J7.

- [x] Décrire chaque modèle intégré par une `CvDesignSpec` : professionnel,
  moderne et minimaliste. Aucune branche conditionnelle sur l'identifiant du
  modèle ne subsiste dans le générateur PDF.
- [x] Conserver la structure en une seule colonne pour tous les modèles du MVP.
- [ ] Persister l'identifiant du modèle avec le CV et retomber sur le modèle
  professionnel si l'identifiant est inconnu. ⚠ `CvDesign.fromId` assure déjà le
  repli ; la persistance attend le J5.
- [x] Générer les vignettes du catalogue depuis les modèles PDF réels, sur un CV
  d'exemple, et les livrer dans les assets.
- [x] Afficher le catalogue : vignette, libellé, description, modèle courant
  identifié, sélection et fermeture.
- [x] Déclencher la régénération du PDF au changement de modèle et inclure ce
  changement dans l'historique undo/redo.
- [x] Tester qu'un changement de modèle ne modifie ni le contenu, ni l'ordre,
  ni la visibilité des sections.

**Terminé quand :** l'utilisateur choisit un modèle dans le catalogue, l'aperçu
et l'export le reflètent, le choix est retrouvé après un redémarrage et aucun
contenu n'est perdu au passage d'un modèle à l'autre.

---

## J9 — Finitions et validation du MVP

**Objectif :** vérifier tous les critères d'acceptation et stabiliser.

- [ ] Gestion des erreurs de sauvegarde, de lecture de base et de génération
  PDF.
- [ ] Présentation en onglets du formulaire et de l'aperçu sur une fenêtre
  étroite.
- [ ] Exécuter les scénarios de validation de bout en bout et vérifier
  l'absence de régressions entre les fonctionnalités des différents jalons.
- [ ] Vérifier un par un les critères d'acceptation de la section 12 du cahier
  des charges.
- [ ] Générer et tester le build Windows (`fvm flutter build windows`).
- [ ] Sur une machine Windows propre, sans réseau, vérifier dès le premier
  lancement : édition, photo locale, aperçu multipage, sauvegarde, réouverture
  et export PDF avec les polices embarquées.
- [ ] Mettre à jour le `README.md` (installation, lancement, tests).

**Terminé quand :** tous les critères d'acceptation sont validés et le build
Windows fonctionne sur une machine propre, entièrement hors ligne.

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
  Une colonne latérale fait entrelacer les compétences avec les intitulés de
  poste et dégrade fortement l'extraction des champs ; le texte placé dans un
  en-tête de page est souvent ignoré. D'où la structure en une seule colonne
  pour tous les modèles du MVP, et l'obligation d'émettre les widgets dans
  l'ordre de lecture attendu si des structures multi-colonnes sont ajoutées
  plus tard.
- **Extension du catalogue :** le format de description des modèles n'est pas
  figé tant que le moteur de zones n'existe pas. Exposer un manifeste chargé
  depuis un dossier utilisateur avant cela reviendrait à publier un format
  incapable de décrire autre chose que des variantes de couleur, qu'il faudrait
  ensuite migrer.
