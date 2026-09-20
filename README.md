# CV Maker

Éditeur de CV pour Windows : on saisit son contenu dans des formulaires, le
PDF A4 réel s'affiche à côté, et s'exporte tel quel.

L'application fonctionne **entièrement hors ligne**. Les polices et toutes les
ressources nécessaires à l'édition, à l'aperçu et à l'export sont livrées avec
le binaire ; aucune donnée personnelle ne quitte l'ordinateur.

- Huit modèles intégrés, avec couleur d'accent libre et affichage de la photo.
- Sections standard et sections personnalisées de trois types.
- Annulation et rétablissement de toute modification de la session.
- Plusieurs CV, enregistrés automatiquement dans une base SQLite locale.
- Export PDF A4 paginé, identique à l'aperçu.

La photo est enregistrée avec le CV et retrouvée à la réouverture. Elle est
ramenée à 600 pixels de côté : le PDF n'en imprime qu'une vignette, et une
photo d'appareil alourdirait la base comme le document exporté.

## Prérequis

- Windows 10 ou 11.
- [FVM](https://fvm.app) : le projet épingle la version du SDK Flutter dans
  `.fvmrc`. **Toutes les commandes passent par `fvm`** ; appeler `flutter` ou
  `dart` directement utiliserait une autre version.
- Pour compiler : Visual Studio avec la charge de travail « Développement
  Desktop en C++ ».

```shell
fvm install
fvm flutter pub get
```

## Lancer

```shell
fvm flutter run -d windows
```

Au premier lancement, l'application s'ouvre sur son tableau de bord, qui
invite à créer un premier CV. Les suivants y apparaissent du plus récemment
modifié au plus ancien.

## Construire

```shell
fvm flutter build windows
```

Le résultat se trouve dans `build\windows\x64\runner\Release\`. Le dossier
entier constitue l'application : l'exécutable a besoin des DLL et du dossier
`data` qui l'accompagnent.

## Où sont les données

Les CV sont enregistrés dans une base SQLite locale :

```text
%APPDATA%\Fehizoro\cv_maker\cv_maker.sqlite
```

Le chemin découle du nom d'éditeur inscrit dans `windows\runner\Runner.rc` :
le changer déplacerait le dossier, et les CV déjà enregistrés ne seraient plus
retrouvés. Supprimer ce fichier efface définitivement tous les CV.

## Tests et analyse

```shell
fvm flutter analyze
fvm flutter test
```

Les deux doivent réussir avant toute livraison. Chaque fichier de `lib/` a son
test miroir dans `test/` ; `test/acceptance/` réunit les scénarios de bout en
bout qui valident les critères d'acceptation du MVP.

## Code généré

Les modèles du domaine utilisent `freezed` et `json_serializable`, et la base
utilise `drift`. Après toute modification d'un fichier portant un
`part '<nom>.freezed.dart';` ou `part '<nom>.g.dart';` :

```shell
fvm dart run build_runner build --delete-conflicting-outputs
```

Les fichiers générés sont versionnés : les tests fonctionnent sans lancer la
génération au préalable.

## Documentation

- `CAHIER_DES_CHARGES.md` — le périmètre, les fonctionnalités et les critères
  d'acceptation.
- `ROADMAP.md` — les jalons, leur état et les points à connaître.
- `AGENTS.md` — les règles de contribution (FVM, tests, commits).
- `design_handoff_cv_maker/` — les maquettes et les tokens de référence.
