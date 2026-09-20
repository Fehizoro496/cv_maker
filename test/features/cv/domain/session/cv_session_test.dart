import 'dart:typed_data';

import 'package:cv_maker/features/cv/domain/document/cv_document.dart';
import 'package:cv_maker/features/cv/domain/session/cv_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final document = CvDocument.empty(id: 'cv-1', now: DateTime.utc(2026));
  final photo = Uint8List.fromList([1, 2, 3]);

  test('une session neuve n’a pas de photo', () {
    final session = CvSession(document: document);
    expect(session.hasPhoto, isFalse);
    expect(session.photo, isNull);
  });

  test('la photo accompagne le document sans y entrer', () {
    final session = CvSession(document: document, photo: photo);
    expect(session.hasPhoto, isTrue);
    expect(session.document.toJson().containsKey('photo'), isFalse);
  });

  test('withoutPhoto conserve le document', () {
    final session = CvSession(document: document, photo: photo);
    expect(session.withoutPhoto().document, document);
    expect(session.withoutPhoto().hasPhoto, isFalse);
  });

  test('une seule valeur porte le document et la photo', () {
    // C'est ce qui permettra à l'historique de restaurer les deux ensemble,
    // sans jamais rendre une photo à un document qui n'est plus le sien.
    final before = CvSession(document: document, photo: photo);
    final after = before.copyWith(
      document: document.copyWith(profile: 'Modifié'),
      photo: null,
    );
    expect(after.document.profile, 'Modifié');
    expect(after.hasPhoto, isFalse);
    expect(before.document.profile, isEmpty);
    expect(before.photo, same(photo));
  });
}
