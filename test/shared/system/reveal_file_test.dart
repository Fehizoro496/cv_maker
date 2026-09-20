import 'package:cv_maker/shared/system/reveal_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le provider ouvre le dossier par le système', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(revealFileProvider), same(revealFile));
  });

  test('un dossier absent n’est pas ouvert', () async {
    expect(await revealFile('dossier-qui-n-existe-pas/CV.pdf'), isFalse);
  });

  test('le provider se remplace dans les tests', () async {
    final opened = <String>[];
    final container = ProviderContainer(
      overrides: [
        revealFileProvider.overrideWithValue((path) async {
          opened.add(path);
          return true;
        }),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(revealFileProvider)('C:/Exports/CV.pdf'), true);
    expect(opened, ['C:/Exports/CV.pdf']);
  });
}
