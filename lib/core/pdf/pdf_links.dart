/// L'adresse d'un site telle qu'on l'écrit sur un CV : sans protocole, sans
/// « www. » et sans barre finale.
///
/// `https://www.linkedin.com/in/camille/` devient `linkedin.com/in/camille`.
/// Le lien cliquable garde l'adresse complète : voir [urlTarget].
String displayUrl(String url) {
  var text = url.trim();
  text = text.replaceFirst(RegExp(r'^https?://', caseSensitive: false), '');
  text = text.replaceFirst(RegExp(r'^www\.', caseSensitive: false), '');
  while (text.endsWith('/')) {
    text = text.substring(0, text.length - 1);
  }
  return text;
}

/// La cible d'un lien vers un site : l'adresse saisie, complétée d'un
/// protocole si elle n'en a pas.
String urlTarget(String url) {
  final text = url.trim();
  final hasScheme = RegExp(
    r'^[a-z][a-z0-9+.-]*:',
    caseSensitive: false,
  ).hasMatch(text);
  return hasScheme ? text : 'https://$text';
}

/// La cible d'un lien vers une adresse électronique.
String emailTarget(String email) => 'mailto:${email.trim()}';

/// La cible d'un lien vers un numéro de téléphone, réduit à ses chiffres.
String phoneTarget(String phone) =>
    'tel:${phone.replaceAll(RegExp(r'[^\d+]'), '')}';
