# AGENTS.md

Instructions partagées par tous les agents de code (Claude Code, Codex, Cursor, Copilot, etc.) travaillant sur ce projet.

## Projet

`cv_maker` — application Flutter (Android, iOS, Web, Windows, macOS, Linux).

## FVM : ne jamais appeler `flutter` ou `dart` directement

Le projet utilise [FVM](https://fvm.app) pour épingler la version du SDK (voir `.fvmrc`).
Toutes les commandes doivent être préfixées par `fvm` :

| À faire                     | À ne pas faire         |
| --------------------------- | ---------------------- |
| `fvm flutter pub get`       | `flutter pub get`      |
| `fvm flutter run`           | `flutter run`          |
| `fvm flutter test`          | `flutter test`         |
| `fvm flutter analyze`       | `flutter analyze`      |
| `fvm dart format .`         | `dart format .`        |
| `fvm dart run build_runner` | `dart run build_runner`|

Ne pas modifier la version du SDK (`.fvmrc`) sans demande explicite.

## Code généré

Les modèles du domaine utilisent `freezed` et `json_serializable`. Après toute
modification d'un fichier contenant `part '<nom>.freezed.dart';` ou
`part '<nom>.g.dart';` :

```shell
fvm dart run build_runner build --delete-conflicting-outputs
```

- Les fichiers `.freezed.dart` et `.g.dart` sont versionnés : `fvm flutter test`
  fonctionne donc sans lancer la génération au préalable.
- Ne jamais les modifier à la main.
- Les options des générateurs sont dans `build.yaml`.

## Tests : obligatoires pour chaque fichier et chaque feature

- Tout nouveau fichier dans `lib/` doit avoir son fichier de test correspondant dans `test/`, en miroir de l'arborescence :
  `lib/features/cv/cv_repository.dart` → `test/features/cv/cv_repository_test.dart`
- Toute nouvelle feature ou modification de comportement doit être accompagnée de tests (unitaires, widget, et d'intégration si pertinent).
- Toute correction de bug doit inclure un test qui reproduit le bug.
- Une tâche n'est pas terminée tant que `fvm flutter test` et `fvm flutter analyze` ne passent pas.

## Commits

- Les agents **ne doivent pas** être mentionnés dans les commits : aucune ligne `Co-Authored-By` pour un agent ou une IA (Claude, Copilot, Codex, etc.), ni de mention « Generated with … ».
- Il en va de même pour les descriptions de pull requests.
- Les messages de commit sont rédigés **en anglais** et suivent la convention [Conventional Commits](https://www.conventionalcommits.org) :

  ```
  <type>(<scope>): <description>
  ```

  - `type` : `feat`, `fix`, `refactor`, `test`, `docs`, `style`, `chore`, `perf`, `build`, `ci`
  - `scope` : la zone concernée (feature, module ou dossier), par ex. `cv`, `pdf`, `auth`
  - `description` : à l'impératif, en minuscules, sans point final, 72 caractères maximum

  Exemples :

  ```
  feat(cv): add experience section editor
  fix(pdf): correct page margins on export
  test(cv): add unit tests for cv repository
  docs(agents): add commit conventions
  ```
