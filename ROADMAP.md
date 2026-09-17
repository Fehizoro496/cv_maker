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

| Jalon | Objectif                                   | Dépend de |
| ----- | ------------------------------------------ | --------- |
| J0    | Fondations du projet                       | —         |
| J1    | Modèle de données immuable                 | J0        |
| J2    | Identité → PDF paginé → aperçu              | J1        |
| J3    | Formulaires de toutes les sections          | J2        |
| J4    | Undo / redo                                 | J3        |
| J5    | Persistance SQLite et gestion multi-CV      | J4        |
| J6    | Photo de session                            | J5        |
| J7    | Export PDF                                  | J6        |
| J8    | Finitions et validation du MVP              | J7        |

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

- [ ] Définir `CvDocument` et ses sous-modèles : informations personnelles,
  profil, expériences, formations, compétences, langues, certifications,
  projets, centres d'intérêt, références ou informations complémentaires,
  préférences de présentation.
- [ ] Distinguer les données persistées du CV de son état de session, qui
  accueillera la photo non persistée au J6. Prévoir un historique capable de
  restaurer les deux ensemble.
- [ ] Donner à chaque élément répétable un identifiant stable et un ordre.
- [ ] Modéliser l'ordre et la visibilité des sections.
- [ ] Implémenter la sérialisation JSON (aller-retour sans perte).
- [ ] Écrire les opérations métier pures : ajouter, modifier, supprimer et
  réordonner un élément ; afficher ou masquer une section.
- [ ] Créer un `CvDocument` d'exemple réutilisable dans les tests.

**Terminé quand :** toutes les opérations et la sérialisation sont couvertes par
des tests unitaires.

---

## J2 — Tranche verticale : identité → PDF paginé → aperçu

**Objectif :** valider tôt le cœur du produit, de la saisie à l'affichage du PDF
réel, avec pagination et fonctionnement hors ligne.

- [ ] Créer le provider du CV en cours d'édition.
- [ ] Développer le formulaire des informations personnelles (sans photo).
- [ ] Créer le générateur PDF du modèle professionnel : une fonction pure
  `CvDocument → bytes PDF`, au format A4 portrait, avec texte sélectionnable.
- [ ] Implémenter la pagination automatique sur plusieurs pages A4 avant
  l'ajout des formulaires de toutes les sections.
- [ ] Ne jamais séparer un titre de section de son premier contenu.
- [ ] Tester le moteur de mise en page avec des données d'exemple longues :
  plusieurs sections, éléments répétés et description dépassant une page,
  sans perte de contenu ni débordement.
- [ ] Afficher le PDF dans la zone de droite.
- [ ] Régénérer automatiquement le PDF après une courte pause dans la saisie
  (debounce).
- [ ] Ajouter le bouton « Rafraîchir » qui force la régénération.
- [ ] Afficher un indicateur pendant la génération.
- [ ] Garantir qu'une génération plus ancienne ne remplace jamais une plus
  récente (numéro de version de génération).
- [ ] Permettre le zoom et le défilement dans l'aperçu.

**Terminé quand :** une saisie dans le formulaire apparaît dans le PDF à droite,
automatiquement ou via « Rafraîchir », accents compris, sans connexion réseau.
Les données d'exemple longues produisent plusieurs pages A4 consultables dans
l'aperçu, sans titre isolé ni contenu tronqué.

---

## J3 — Formulaires de toutes les sections

**Objectif :** pouvoir renseigner l'intégralité d'un CV.

- [ ] Profil professionnel.
- [ ] Expériences : champs, option « En cours », ajout, suppression,
  réorganisation.
- [ ] Formations : champs, ajout, suppression, réorganisation.
- [ ] Compétences : catégorie et niveau facultatifs, réorganisation,
  suppression.
- [ ] Langues : niveau choisi ou saisi, réorganisation, suppression.
- [ ] Sections complémentaires : certifications, projets, centres d'intérêt,
  références ou informations complémentaires.
- [ ] Afficher ou masquer chaque section facultative.
- [ ] Confirmation avant les suppressions importantes.
- [ ] Rendre toutes ces sections dans le modèle PDF.
- [ ] Vérifier la pagination de chaque section avec des contenus longs en
  réutilisant le moteur validé au J2.

**Terminé quand :** chaque section est éditable et visible dans le PDF, et les
sections masquées n'y apparaissent plus.

---

## J4 — Undo / redo

**Objectif :** annuler et rétablir toute modification du CV pendant la session.

- [ ] Implémenter un historique basé sur les états immuables du CV (piles
  « passé » et « futur »), incluant l'état de session prévu au J1.
- [ ] Regrouper les frappes successives dans un même champ en une seule étape.
- [ ] Brancher toutes les modifications existantes sur l'historique : saisie,
  ajout, suppression, réorganisation, visibilité des sections.
- [ ] Raccourcis `Ctrl+Z`, `Ctrl+Y` et `Ctrl+Maj+Z`.
- [ ] Boutons « Annuler » et « Rétablir », désactivés lorsqu'aucune action n'est
  disponible.
- [ ] Synchroniser les champs de formulaire avec l'état restauré.
- [ ] Déclencher la régénération du PDF après une annulation ou un
  rétablissement.

**Terminé quand :** toute modification des jalons précédents peut être annulée
puis rétablie, et le formulaire comme le PDF reflètent l'état restauré.

---

## J5 — Persistance SQLite et gestion multi-CV

**Objectif :** retrouver ses CV après un redémarrage et en gérer plusieurs.

- [ ] Initialiser la base drift (`drift_flutter`) dans le dossier de données de
  l'application.
- [ ] Créer la table drift des CV : identifiant, nom, dates, document JSON,
  avec un schéma versionné et une stratégie de migration.
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

- [ ] Sélectionner une image depuis le disque.
- [ ] Conserver la photo en mémoire, associée au CV, pendant la session
  uniquement.
- [ ] Exclure la photo du JSON sauvegardé.
- [ ] Afficher la photo dans le PDF.
- [ ] Retirer ou remplacer la photo.
- [ ] Inclure les changements de photo dans l'historique undo/redo.

**Terminé quand :** la photo apparaît dans le PDF pendant la session et est
absente après un redémarrage, sans erreur.

---

## J7 — Export PDF

**Objectif :** enregistrer localement le PDF paginé déjà validé dans l'aperçu.

- [ ] Bouton « Exporter » avec dialogue d'enregistrement Windows (nom et
  emplacement).
- [ ] Si le PDF affiché n'est pas à jour, déclencher ou attendre la
  régénération avant l'export.
- [ ] Mettre à jour l'aperçu avec ce PDF et exporter exactement les mêmes
  octets.
- [ ] Message clair en cas d'échec de l'export.

**Terminé quand :** un CV long est exporté sur plusieurs pages, identique à
l'aperçu, même si l'export est demandé juste après une modification.

---

## J8 — Finitions et validation du MVP

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
