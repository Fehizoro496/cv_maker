import 'dart:convert';

/// Une empreinte comparable du contenu d'un PDF.
///
/// Le paquet `pdf` termine chaque document par un identifiant aléatoire
/// (`/ID`, un SHA-256 d'horodatage et d'octets tirés au hasard) : deux
/// générations du même CV ne produisent donc jamais les mêmes octets.
/// Comparer les octets bruts ne prouverait rien — un test d'égalité échouerait
/// toujours, un test de différence réussirait toujours.
///
/// Cette empreinte retire cet identifiant pour que la comparaison porte sur le
/// contenu et la mise en forme, c'est-à-dire sur ce que les tests vérifient.
String pdfFingerprint(List<int> bytes) => latin1
    .decode(bytes)
    .replaceAll(RegExp(r'/ID\s*\[[^\]]*\]'), '/ID[]')
    .replaceAll(RegExp(r'/CreationDate\s*\([^)]*\)'), '/CreationDate()')
    .replaceAll(RegExp(r'/ModDate\s*\([^)]*\)'), '/ModDate()');
