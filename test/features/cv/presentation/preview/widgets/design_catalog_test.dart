import 'dart:convert';
import 'dart:typed_data';

import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/features/cv/domain/design/cv_design.dart';
import 'package:cv_maker/features/cv/presentation/preview/catalog_preview_provider.dart';
import 'package:cv_maker/features/cv/presentation/preview/widgets/design_catalog.dart';
import 'package:cv_maker/shared/widgets/color_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/desktop_view.dart';

/// Un PNG 1×1 valide : les vignettes rendues sont hors sujet ici, seule leur
/// présence compte.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC',
);

/// Les combinaisons dont une vignette a été demandée.
final requested = <CatalogChoice>{};

/// Le catalogue est testé sur son interface : la génération des vignettes est
/// couverte par le test de `catalogPreviewProvider`.
final _fakePreviews = catalogPreviewProvider.overrideWith((ref, choice) async {
  requested.add(choice);
  return Uint8List.fromList(_png);
});

/// La notation hexadécimale attendue par les clés des suggestions.
String _hex(int argb) => ColorPickerDialog.hexOf(Color(argb));

void main() {
  CatalogChoice? result;

  Future<void> openCatalog(
    WidgetTester tester, {
    Size size = const Size(1440, 900),
    CvDesign selected = CvDesign.classic,
    int accentArgb = CvAccent.defaultColor,
    bool showPhoto = true,
    bool hasPhoto = true,
  }) async {
    useDesktopView(tester, size: size);
    result = null;
    requested.clear();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [_fakePreviews],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showDialog<CatalogChoice>(
                    context: context,
                    builder: (_) => DesignCatalog(
                      selected: selected,
                      accentArgb: accentArgb,
                      showPhoto: showPhoto,
                      hasPhoto: hasPhoto,
                    ),
                  );
                },
                child: const Text('Ouvrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
  }

  for (final size in [
    const Size(1440, 900),
    const Size(1000, 760),
    const Size(620, 700),
  ]) {
    testWidgets('le catalogue montre tous les modèles à ${size.width}', (
      tester,
    ) async {
      await openCatalog(tester, size: size);
      expect(find.byType(DesignCatalog), findsOneWidget);
      for (final design in CvDesign.values) {
        expect(find.text(design.label), findsOneWidget, reason: design.name);
      }
      expect(find.text('Choisir un modèle'), findsOneWidget);
      expect(
        find.text('Compatible avec les logiciels de tri des candidatures'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('les vignettes viennent du PDF réel du CV', (tester) async {
    await openCatalog(tester);
    // Une vignette par modèle, plus le grand aperçu de droite.
    expect(find.byType(Image), findsNWidgets(CvDesign.values.length + 1));
  });

  testWidgets('le dialogue reprend les dimensions de la maquette', (
    tester,
  ) async {
    await openCatalog(tester);
    // Le Dialog pose ses propres ConstrainedBox : on cherche le nôtre.
    expect(
      tester
          .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .any(
            (box) =>
                box.constraints.maxWidth == DesignCatalog.maxWidth &&
                box.constraints.maxHeight == DesignCatalog.maxHeight,
          ),
      isTrue,
    );
    // Le panneau de droite occupe une largeur fixe.
    expect(
      tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .any((box) => box.width == DesignCatalog.settingsWidth),
      isTrue,
    );
  });

  testWidgets('chaque vignette garde le rapport A4', (tester) async {
    await openCatalog(tester);
    final ratios = tester
        .widgetList<AspectRatio>(find.byType(AspectRatio))
        .map((widget) => widget.aspectRatio)
        .toList();
    // Une vignette par modèle, plus le grand aperçu.
    expect(ratios, hasLength(CvDesign.values.length + 1));
    expect(ratios.every((ratio) => ratio == 210 / 297), isTrue);
  });

  testWidgets('le panneau de réglages reprend les libellés de la maquette', (
    tester,
  ) async {
    await openCatalog(tester);
    expect(find.text('COULEUR D’ACCENT'), findsOneWidget);
    expect(find.text('Afficher la photo'), findsOneWidget);
    expect(
      find.text('Ce modèle propose aussi une version sans photo.'),
      findsOneWidget,
    );
    // La couleur courante est affichée et modifiable.
    expect(find.text('#2F5D8C'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Choisir'), findsOneWidget);
  });

  testWidgets('l’en-tête annonce le nombre de modèles', (tester) async {
    await openCatalog(tester);
    expect(
      find.textContaining('${CvDesign.values.length} modèles'),
      findsOneWidget,
    );
  });

  testWidgets('le modèle enregistré est identifié par une pastille', (
    tester,
  ) async {
    await openCatalog(tester, selected: CvDesign.compact);
    final card = find.ancestor(
      of: find.text(CvDesign.compact.label),
      matching: find.byType(Semantics),
    );
    expect(
      tester
          .widgetList<Semantics>(card)
          .any((semantics) => semantics.properties.selected == true),
      isTrue,
    );
  });

  testWidgets('appliquer retourne le modèle choisi', (tester) async {
    await openCatalog(tester, selected: CvDesign.classic);
    await tester.tap(find.text(CvDesign.academic.label));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Appliquer le modèle'));
    await tester.pumpAndSettle();
    expect(result?.design, CvDesign.academic);
    expect(find.byType(DesignCatalog), findsNothing);
  });

  testWidgets('le sélecteur de couleur retourne une couleur libre', (
    tester,
  ) async {
    await openCatalog(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Choisir'));
    await tester.pumpAndSettle();
    expect(find.byType(ColorPickerDialog), findsOneWidget);

    // Une couleur qui n'appartient pas aux suggestions.
    await tester.enterText(
      find.byKey(const Key('color-picker-hex')),
      '#AB12CD',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Choisir'));
    await tester.pumpAndSettle();

    expect(find.text('#AB12CD'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Appliquer le modèle'));
    await tester.pumpAndSettle();
    expect(result?.accentArgb, 0xFFAB12CD);
    expect(result?.design, CvDesign.classic);
  });

  testWidgets('annuler le sélecteur laisse la couleur inchangée', (
    tester,
  ) async {
    await openCatalog(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Choisir'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('color-picker-hex')),
      '#AB12CD',
    );
    await tester.pump();
    // Le catalogue porte lui aussi un bouton « Annuler ».
    await tester.tap(
      find.descendant(
        of: find.byType(ColorPickerDialog),
        matching: find.widgetWithText(TextButton, 'Annuler'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('#2F5D8C'), findsOneWidget);
  });

  testWidgets('une suggestion du sélecteur applique sa couleur', (
    tester,
  ) async {
    await openCatalog(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Choisir'));
    await tester.pumpAndSettle();
    // La palette reste accessible en raccourci dans le sélecteur.
    for (final accent in CvAccent.values) {
      expect(
        find.byKey(ValueKey('suggestion-${_hex(accent.color)}')),
        findsOneWidget,
      );
    }
    await tester.tap(
      find.byKey(ValueKey('suggestion-${_hex(CvAccent.burgundy.color)}')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Choisir'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Appliquer le modèle'));
    await tester.pumpAndSettle();
    expect(result?.accentArgb, CvAccent.burgundy.color);
  });

  testWidgets('le réglage de photo se retourne aussi', (tester) async {
    await openCatalog(tester);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Appliquer le modèle'));
    await tester.pumpAndSettle();
    expect(result?.showPhoto, isFalse);
  });

  testWidgets('sans photo dans la session, le réglage est indisponible', (
    tester,
  ) async {
    await openCatalog(tester, hasPhoto: false);
    expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
    expect(find.textContaining('Ajoutez une photo'), findsOneWidget);
  });

  testWidgets('un modèle sans couleur désactive le sélecteur', (tester) async {
    await openCatalog(tester, selected: CvDesign.plain);
    expect(find.text('Ce modèle n’utilise aucune couleur.'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Choisir'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('changer la couleur ne régénère que le modèle choisi', (
    tester,
  ) async {
    await openCatalog(tester, selected: CvDesign.classic);
    final before = {...requested};
    requested.clear();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Choisir'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('color-picker-hex')),
      '#AB12CD',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Choisir'));
    await tester.pumpAndSettle();

    // Une seule combinaison nouvelle : le modèle sélectionné dans sa couleur.
    // La vignette et le grand aperçu la partagent, d'où une seule génération.
    expect(before, isNotEmpty);
    expect(requested, {
      (design: CvDesign.classic, accentArgb: 0xFFAB12CD, showPhoto: true),
    });
  });

  testWidgets('changer de modèle ne régénère que le nouveau choix', (
    tester,
  ) async {
    await openCatalog(tester, selected: CvDesign.classic);
    requested.clear();
    await tester.tap(find.text(CvDesign.compact.label));
    await tester.pumpAndSettle();
    // Le modèle quitté retrouve sa vignette de base, déjà rendue.
    expect(
      requested,
      everyElement(
        isA<CatalogChoice>().having(
          (choice) => choice.design,
          'design',
          CvDesign.compact,
        ),
      ),
    );
  });

  testWidgets('annuler ne retourne aucun choix', (tester) async {
    await openCatalog(tester, selected: CvDesign.banner);
    await tester.tap(find.text(CvDesign.plain.label));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Annuler'));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });

  testWidgets('fermer le catalogue ne retourne aucun choix', (tester) async {
    await openCatalog(tester);
    await tester.tap(find.byTooltip('Fermer le catalogue'));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });
}
