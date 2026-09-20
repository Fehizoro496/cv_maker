import 'dart:io';
import 'dart:typed_data';

import 'package:cv_maker/app/bootstrap.dart';
import 'package:cv_maker/features/cv/data/cv_database.dart';
import 'package:cv_maker/features/cv/data/cv_repository.dart';
import 'package:cv_maker/features/cv/domain/cv_custom_section.dart';
import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:cv_maker/features/cv/domain/cv_entry.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/cv_autosave.dart';
import 'package:cv_maker/features/cv/presentation/cv_library_provider.dart';
import 'package:cv_maker/features/cv/presentation/cv_section_forms.dart';
import 'package:cv_maker/features/cv/presentation/cv_session_provider.dart';
import 'package:cv_maker/features/cv/presentation/cv_workspace.dart';
import 'package:cv_maker/features/cv/presentation/widgets/cv_pdf.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pdf_text.dart';

/// Les scénarios de validation du MVP, critère par critère (section 12 du
/// cahier des charges).
///
/// Ils ne remplacent pas les tests des jalons : ils vérifient que les
/// fonctionnalités livrées séparément tiennent ensemble, sur une vraie base
/// SQLite, jusqu'au texte du PDF. Chaque `test` porte le nom du critère
/// qu'il valide.
///
/// Ce qui relève de la fenêtre elle-même — fermeture pendant la saisie,
/// premier lancement sur une machine vierge — se vérifie à la main : le test
/// n'a pas de fenêtre.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late File file;
  var tick = DateTime.utc(2026, 9, 20, 9);
  final running = <_App>[];

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('cv_acceptance');
    file = File('${dir.path}/cv_maker.sqlite');
    tick = DateTime.utc(2026, 9, 20, 9);
    // Windows refuse de supprimer un fichier encore ouvert.
    addTearDown(() async {
      for (final app in running) {
        try {
          await app.quit();
        } catch (_) {
          // Déjà arrêtée par le test.
        }
      }
      running.clear();
      await dir.delete(recursive: true);
    });
  });

  /// Lance l'application comme `main`, sur le fichier de base du test.
  Future<_App> launch() async {
    final db = CvDatabase(NativeDatabase(file));
    final container = ProviderContainer(
      overrides: [
        ...await startupOverrides(DriftCvRepository(db)),
        clockProvider.overrideWithValue(
          () => tick = tick.add(const Duration(seconds: 1)),
        ),
      ],
    );
    container.read(cvAutosaveProvider);
    final app = _App(db, container);
    running.add(app);
    return app;
  }

  /// Un lancement suivi de la création d'un CV, déjà ouvert.
  Future<_App> launchWithCv() async {
    final app = await launch();
    await app.workspace.create();
    return app;
  }

  group('saisie et aperçu', () {
    test('un utilisateur peut renseigner toutes les sections principales, et '
        'le PDF les reflète', () async {
      final app = await launchWithCv();

      app.fillEverything();
      final text = pdfText(await app.pdf());

      expect(app.editor.document.personalInfo.firstName, 'Camille');
      expect(text, contains('Camille Moreau'));
      expect(text, contains('Profil professionnel.'));
      for (final section in _repeatableSections) {
        expect(
          text,
          contains(_valueFor(section)),
          reason: 'la section ${section.name} manque dans le PDF',
        );
      }
    });

    test('un CV long est réparti sur plusieurs pages A4', () async {
      final app = await launchWithCv();
      app.fillEverything(repeat: 8);

      final bytes = await app.pdf();

      expect(pdfPageTexts(bytes).length, greaterThan(1));
      // 595,28 × 841,89 points : l'A4 tel que le paquet `pdf` l'écrit.
      expect(
        RegExp(
          r'/MediaBox\s*\[[^\]]*595\.2\d*\s+841\.8\d*\]',
        ).allMatches(String.fromCharCodes(bytes.where((b) => b < 128))),
        isNotEmpty,
      );
    });

    test('les sections facultatives peuvent être masquées', () async {
      final app = await launchWithCv();
      app.fillEverything();

      app.editor.setSectionVisible(CvSection.interests, false);
      final text = pdfText(await app.pdf());

      expect(text, isNot(contains(_valueFor(CvSection.interests))));
      expect(text, contains(_valueFor(CvSection.experiences)));
    });

    test('les listes d’expériences et de formations se réorganisent', () async {
      final app = await launchWithCv();
      app.fillEverything(repeat: 2);

      for (final section in [CvSection.experiences, CvSection.education]) {
        final before = app.titlesOf(section);
        app.editor.reorderEntries(section, 0, 1);
        expect(app.titlesOf(section), before.reversed.toList());
      }
    });
  });

  group('undo / redo', () {
    test('toute modification de la session s’annule et se rétablit, y '
        'compris après un changement de CV', () async {
      final app = await launchWithCv();
      final first = app.openId;
      await app.workspace.create();
      final second = app.openId;

      app.editor.setDocumentField(CvDocumentFields.firstName, 'Alice');
      await app.workspace.open(first);
      app.editor.setDocumentField(CvDocumentFields.firstName, 'Bruno');
      app.editor.undo();
      expect(app.editor.document.personalInfo.firstName, isEmpty);
      app.editor.redo();
      expect(app.editor.document.personalInfo.firstName, 'Bruno');

      await app.workspace.open(second);
      expect(app.editor.document.personalInfo.firstName, 'Alice');
      app.editor.undo();
      expect(app.editor.document.personalInfo.firstName, isEmpty);
    });

    test('l’historique est vide au redémarrage', () async {
      final app = await launchWithCv();
      final id = app.openId;
      app.editor.setDocumentField(CvDocumentFields.firstName, 'Alice');
      await app.close();

      final next = await launch();
      await next.workspace.open(id);

      expect(next.editor.canUndo, isFalse);
      expect(next.editor.canRedo, isFalse);
      expect(next.editor.document.personalInfo.firstName, 'Alice');
    });
  });

  group('persistance', () {
    test(
      'les données sont retrouvées après le redémarrage, photo comprise',
      () async {
        final app = await launchWithCv();
        final id = app.openId;
        final photo = await _photoBytes();
        app.fillEverything();
        app.editor.setPhoto(photo);
        await app.close();

        final next = await launch();
        await next.workspace.open(id);

        expect(next.editor.document.personalInfo.firstName, 'Camille');
        expect(
          pdfText(await next.pdf()),
          contains(_valueFor(CvSection.skills)),
        );
        expect(next.container.read(cvSessionProvider).photo, photo);
      },
    );

    test('la couleur d’accent et l’affichage de la photo sont retrouvés '
        'après un redémarrage', () async {
      final app = await launchWithCv();
      final id = app.openId;

      app.editor.applyTemplate(
        design: CvDesign.banner,
        accentArgb: 0xFF7A1FA2,
        showPhoto: false,
      );
      await app.close();

      final next = await launch();
      await next.workspace.open(id);
      final presentation = next.editor.document.presentation;

      expect(presentation.designId, CvDesign.banner.id);
      expect(presentation.accentColor, 0xFF7A1FA2);
      expect(presentation.showPhoto, isFalse);
    });

    test('une section personnalisée de chaque type se remplit, se renomme, '
        'se masque et se retrouve après un redémarrage', () async {
      final app = await launchWithCv();
      final id = app.openId;
      final ids = <CvCustomSectionType, String>{
        for (final type in CvCustomSectionType.values)
          type: app.addCustomSection(type),
      };

      app.editor.renameCustomSection(
        ids[CvCustomSectionType.simpleList]!,
        'Distinctions',
      );
      app.editor.setSectionVisible(
        CvCustomSectionRef(ids[CvCustomSectionType.datedList]!),
        false,
      );
      await app.close();

      final next = await launch();
      await next.workspace.open(id);
      final sections = next.editor.document.customSections;

      expect(sections.map((s) => s.type), CvCustomSectionType.values);
      expect(
        sections.byId(ids[CvCustomSectionType.simpleList]!)!.name,
        'Distinctions',
      );
      expect(
        sections.byId(ids[CvCustomSectionType.datedList]!)!.visible,
        isFalse,
      );
      expect(
        sections.byId(ids[CvCustomSectionType.freeText]!)!.text,
        contains('Contenu libre'),
      );
      // Les modèles impriment les titres de section en capitales.
      final text = pdfText(await next.pdf()).toUpperCase();
      expect(text, contains('DISTINCTIONS'));
      expect(
        text,
        isNot(contains('ÉLÉMENT DATÉ')),
        reason: 'une section masquée ne s’imprime pas',
      );
    });

    test(
      'la photo apparaît dans le PDF, et s’enregistre hors du document',
      () async {
        final app = await launchWithCv();
        final id = app.openId;
        app.fillEverything();

        final without = (await app.pdf()).length;
        app.editor.setPhoto(await _photoBytes());
        final withPhoto = (await app.pdf()).length;
        await app.close();

        expect(
          withPhoto,
          greaterThan(without),
          reason: 'l’image entre dans le PDF',
        );
        final next = await launch();
        expect(await next.repository.readPhoto(id), await _photoBytes());
        final record = await (next.db.select(
          next.db.cvRecords,
        )..where((r) => r.id.equals(id))).getSingle();
        expect(
          record.document,
          isNot(contains('photo')),
          reason: 'le document JSON, réécrit à chaque frappe, l’ignore',
        );
      },
    );
  });

  group('catalogue', () {
    test('chaque modèle change le PDF sans perdre de contenu', () async {
      final app = await launchWithCv();
      app.fillEverything();
      final rendered = <String, String>{};

      for (final design in CvDesign.values) {
        app.editor.setDesign(design);
        final text = pdfText(await app.pdf());
        for (final section in _repeatableSections) {
          expect(
            text,
            contains(_valueFor(section)),
            reason: '${design.id} perd la section ${section.name}',
          );
        }
        rendered[design.id] = text;
      }

      expect(rendered, hasLength(CvDesign.values.length));
      expect(
        app.editor.document.presentation.orderedSections,
        CvSection.values,
        reason: 'le modèle ne réordonne pas le CV enregistré',
      );
    });
  });
}

/// Une application lancée sur le fichier de base du test.
class _App {
  _App(this.db, this.container);

  final CvDatabase db;
  final ProviderContainer container;

  CvWorkspace get workspace => container.read(cvWorkspaceProvider);
  CvSessionNotifier get editor => container.read(cvSessionProvider.notifier);
  String get openId => container.read(cvSessionProvider).document.id;
  DriftCvRepository get repository => DriftCvRepository(db);

  /// Le PDF du CV ouvert, tel que l'aperçu et l'export le produisent.
  Future<Uint8List> pdf() {
    final session = container.read(cvSessionProvider);
    return buildCvPdf(
      session.document,
      session.document.designSpec,
      photo: session.photo,
    );
  }

  /// Remplit les informations personnelles et [repeat] éléments dans chaque
  /// section répétable, avec des valeurs reconnaissables dans le PDF.
  void fillEverything({int repeat = 1}) {
    editor
      ..setDocumentField(CvDocumentFields.firstName, 'Camille')
      ..setDocumentField(CvDocumentFields.lastName, 'Moreau')
      ..setDocumentField(CvDocumentFields.headline, 'Développeuse')
      ..setDocumentField(CvDocumentFields.profile, 'Profil professionnel.');
    for (final section in CvSection.values) {
      final form = cvSectionFormOf(section, editor.document);
      if (form == null || section == CvSection.personalInfo) continue;
      for (var i = 0; i < repeat; i++) {
        final id = editor.addEntry(section);
        var entry = editor.entriesOf(section).byId(id)!;
        for (final field in form.fields) {
          if (field is! CvEntryTextField) continue;
          entry = field.write(
            entry,
            identical(field, form.titleField)
                ? '${_valueFor(section)}${i == 0 ? '' : ' $i'}'
                : '${field.label} ${section.name}',
          );
        }
        editor.updateEntry(section, entry);
      }
    }
  }

  /// Les titres des éléments de [section], dans l'ordre d'affichage.
  List<String> titlesOf(CvSection section) {
    final form = cvSectionFormOf(section, editor.document)!;
    final title = form.titleField as CvEntryTextField;
    return [for (final entry in editor.entriesOf(section)) title.read(entry)];
  }

  /// Crée une section personnalisée de [type] et la remplit.
  String addCustomSection(CvCustomSectionType type) {
    final id = editor.addCustomSection(_customName(type), type);
    if (type == CvCustomSectionType.freeText) {
      editor.setCustomSectionText(id, 'Contenu libre de la section.');
      return id;
    }
    final ref = CvCustomSectionRef(id);
    final entryId = editor.addEntry(ref);
    final form = cvSectionFormOf(ref, editor.document)!;
    var entry = editor.entriesOf(ref).byId(entryId)!;
    entry = (form.titleField as CvEntryTextField).write(
      entry,
      type == CvCustomSectionType.datedList ? 'Élément daté' : 'Élément simple',
    );
    editor.updateEntry(ref, entry);
    return id;
  }

  /// Ferme l'application comme la fenêtre le ferait.
  Future<void> close() async {
    await workspace.saveBeforeExit();
    await quit();
  }

  Future<void> quit() async {
    container.dispose();
    await db.close();
  }
}

String _customName(CvCustomSectionType type) => switch (type) {
  CvCustomSectionType.freeText => 'Engagements',
  CvCustomSectionType.datedList => 'Publications',
  CvCustomSectionType.simpleList => 'Récompenses',
};

/// Les sections à éléments répétables : celles dont le premier élément porte
/// une valeur repère. Les informations personnelles et le profil sont des
/// champs du document, pas des listes.
final _repeatableSections = [
  for (final section in CvSection.values)
    if (section != CvSection.personalInfo && section != CvSection.profile)
      section,
];

/// La valeur repère écrite dans le titre du premier élément de [section].
String _valueFor(CvSection section) => 'Repère-${section.name}';

/// Une image PNG minuscule, suffisante pour entrer dans le PDF.
Future<Uint8List> _photoBytes() async => Uint8List.fromList(_pngPixel);

/// Un PNG 1 × 1 opaque, écrit octet par octet pour ne dépendre d'aucun asset.
const _pngPixel = <int>[
  137, 80, 78, 71, 13, 10, 26, 10, //
  0, 0, 0, 13, 73, 72, 68, 82,
  0, 0, 0, 1, 0, 0, 0, 1, 8, 2, 0, 0, 0, 144, 119, 83, 222,
  0, 0, 0, 12, 73, 68, 65, 84, 8, 215, 99, 248, 207, 192, 0, 0,
  3, 1, 1, 0, 24, 221, 141, 176,
  0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130,
];
