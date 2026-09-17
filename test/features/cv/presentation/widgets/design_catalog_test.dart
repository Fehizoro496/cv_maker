import 'dart:convert';
import 'dart:typed_data';

import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:cv_maker/features/cv/presentation/catalog_preview_provider.dart';
import 'package:cv_maker/features/cv/presentation/widgets/design_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/desktop_view.dart';

/// Un PNG 1×1 valide : les vignettes rendues sont hors sujet ici, seule leur
/// présence compte.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC',
);

/// Le catalogue est testé sur son interface : la génération des vignettes est
/// couverte par le test de `catalogPreviewProvider`.
final _fakePreviews = catalogPreviewProvider.overrideWith(
  (ref, choice) async => Uint8List.fromList(_png),
);

void main() {
  CatalogChoice? result;

  Future<void> openCatalog(
    WidgetTester tester, {
    Size size = const Size(1440, 900),
    CvDesign selected = CvDesign.classic,
    CvAccent accent = CvAccent.blue,
    bool showPhoto = true,
    bool hasPhoto = true,
  }) async {
    useDesktopView(tester, size: size);
    result = null;
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
                      accent: accent,
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

  testWidgets('appliquer retourne aussi la couleur choisie', (tester) async {
    await openCatalog(tester);
    await tester.tap(find.byTooltip(CvAccent.burgundy.label));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Appliquer le modèle'));
    await tester.pumpAndSettle();
    expect(result?.accent, CvAccent.burgundy);
    expect(result?.design, CvDesign.classic);
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

  testWidgets('un modèle sans couleur désactive la palette', (tester) async {
    await openCatalog(tester, selected: CvDesign.plain);
    expect(find.text('Ce modèle n’utilise aucune couleur.'), findsOneWidget);
    await tester.tap(find.byTooltip(CvAccent.green.label));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Appliquer le modèle'));
    await tester.pumpAndSettle();
    // La pastille reste sans effet : la couleur enregistrée ne change pas.
    expect(result?.accent, CvAccent.blue);
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
