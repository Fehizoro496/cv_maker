import 'package:cv_maker/core/pdf/pdf_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('displayUrl', () {
    test('retire le protocole, le « www. » et la barre finale', () {
      expect(
        displayUrl('https://www.linkedin.com/in/camille/'),
        'linkedin.com/in/camille',
      );
      expect(displayUrl('HTTP://Exemple.fr'), 'Exemple.fr');
      expect(displayUrl('  camille-moreau.fr  '), 'camille-moreau.fr');
    });

    test('garde le reste de l’adresse', () {
      expect(displayUrl('https://exemple.fr/a?b=1#c'), 'exemple.fr/a?b=1#c');
      expect(displayUrl('https://wwwexemple.fr'), 'wwwexemple.fr');
    });
  });

  group('cibles des liens', () {
    test('une adresse sans protocole passe en https', () {
      expect(
        urlTarget('linkedin.com/in/camille'),
        'https://linkedin.com/in/camille',
      );
      expect(urlTarget('http://exemple.fr/'), 'http://exemple.fr/');
    });

    test('e-mail et téléphone', () {
      expect(emailTarget(' camille@exemple.fr '), 'mailto:camille@exemple.fr');
      expect(phoneTarget('+33 6 12-34.56 78'), 'tel:+33612345678');
    });
  });
}
