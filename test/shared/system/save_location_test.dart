import 'dart:io';
import 'dart:typed_data';

import 'package:cv_maker/shared/system/save_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le provider ouvre le dialogue du système', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(saveLocationProvider), same(pickPdfSaveLocation));
  });

  test('le provider se remplace dans les tests', () async {
    final asked = <String>[];
    final container = ProviderContainer(
      overrides: [
        saveLocationProvider.overrideWithValue(({
          required String suggestedName,
        }) async {
          asked.add(suggestedName);
          return 'C:/Exports/$suggestedName';
        }),
      ],
    );
    addTearDown(container.dispose);

    final path = await container.read(saveLocationProvider)(
      suggestedName: 'CV.pdf',
    );

    expect(path, 'C:/Exports/CV.pdf');
    expect(asked, ['CV.pdf']);
  });

  test('l’écriture passe par le système de fichiers', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(saveBytesProvider), same(savePdfBytes));
  });

  test('les octets exportés sont écrits tels quels', () async {
    final folder = Directory.systemTemp.createTempSync('save_location_test');
    addTearDown(() => folder.deleteSync(recursive: true));
    final path = '${folder.path}/CV.pdf';

    await savePdfBytes(path, Uint8List.fromList([37, 80, 68, 70]));

    expect(File(path).readAsBytesSync(), [37, 80, 68, 70]);
  });

  test('un dossier absent fait échouer l’écriture', () {
    expect(
      savePdfBytes('dossier-absent/CV.pdf', Uint8List(1)),
      throwsA(isA<Exception>()),
    );
  });

  test('un renoncement de l’utilisateur ne donne aucun chemin', () async {
    final container = ProviderContainer(
      overrides: [
        saveLocationProvider.overrideWithValue(
          ({required String suggestedName}) async => null,
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      await container.read(saveLocationProvider)(suggestedName: 'CV.pdf'),
      isNull,
    );
  });
}
