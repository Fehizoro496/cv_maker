import 'package:cv_maker/features/cv/domain/document/cv_personal_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('les champs sont vides par défaut', () {
    const info = CvPersonalInfo();
    expect(info.firstName, isEmpty);
    expect(info.links, isEmpty);
    expect(info.fullName, isEmpty);
  });

  test('fullName n’ajoute pas d’espace si un seul nom est renseigné', () {
    expect(const CvPersonalInfo(firstName: 'Camille').fullName, 'Camille');
    expect(const CvPersonalInfo(lastName: 'Moreau').fullName, 'Moreau');
    expect(
      const CvPersonalInfo(firstName: 'Camille', lastName: 'Moreau').fullName,
      'Camille Moreau',
    );
  });

  test('aller-retour JSON sans perte, liens compris', () {
    const info = CvPersonalInfo(
      firstName: 'Camille',
      lastName: 'Moreau',
      headline: 'Développeuse Front-End',
      location: 'Lyon, France',
      phone: '+33 6 12 34 56 78',
      email: 'camille.moreau@email.fr',
      website: 'camille-moreau.fr',
      links: [CvLink(id: 'l1', label: 'LinkedIn', url: 'linkedin.com/in/cm')],
    );
    expect(CvPersonalInfo.fromJson(info.toJson()), info);
  });

  test('un lien est un élément répétable identifié', () {
    const link = CvLink(id: 'l1', label: 'GitHub');
    expect(link.id, 'l1');
    expect(CvLink.fromJson(link.toJson()), link);
  });
}
