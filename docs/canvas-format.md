# Templates canvas — format V2

Le canvas est l'unique système de templates, au format d'échange V2. Le moteur, le
catalogue et les échanges de fichiers le prennent en charge. L'application
visuelle de création reste à développer ; aujourd'hui on édite le JSON.

[Exemple complet sur deux pages](examples/canvas.cv-template.json).

L'enveloppe conserve `format: "cv-maker-template"`, l'identifiant et la révision
du modèle, mais porte `schemaVersion: 2`. `template.spec.canvas.pages` contient
les pages à rendre. Le format V1 est refusé, y compris dans le stockage local.
Un fichier V2 doit contenir un canvas ; aucune conversion ancienne n'est prévue.

```json
{
  "format": "cv-maker-template",
  "schemaVersion": 2,
  "template": {
    "id": "atelier.libre",
    "revision": 1,
    "label": "Libre",
    "description": "Un nom placé librement sur une page.",
    "spec": {
      "canvas": {
        "pages": [{
          "background": 4294967295,
          "elements": [{
            "id": "name",
            "type": "text",
            "x": 18, "y": 22, "width": 170, "height": 18,
            "binding": "personalInfo.fullName",
            "fontSize": 28, "bold": true,
            "color": 4280290104
          }]
        }]
      }
    }
  }
}
```

## Géométrie et styles

Chaque page est au format A4 portrait (210 × 297 mm). L'origine est en haut à
gauche. `x`, `y`, `width`, `height`, `padding`, `radius` et `borderWidth` sont en
millimètres ; `fontSize` est en points typographiques. Chaque cadre doit rester
entièrement dans la page et garder une surface intérieure positive.

Les éléments sont dessinés dans l'ordre du tableau : les suivants recouvrent
les précédents. Placer les fonds avant les textes. Cet ordre sert aussi à
l'émission du texte dans le PDF ; un placement libre ne garantit pas à lui seul
un ordre de lecture adapté aux logiciels de recrutement.

| Propriété | Valeur par défaut / rôle |
| --- | --- |
| `id` | Obligatoire, unique dans tout le canvas, 128 caractères maximum |
| `type` | `text`, `section`, `photo`, `rectangle` ou `flow` |
| `x`, `y`, `width`, `height` | Obligatoires ; largeur et hauteur ≥ 0,1 mm |
| `background` | Transparent pour un élément, blanc pour une page |
| `borderWidth`, `radius`, `padding` | 0 ; bordure, arrondis, marge intérieure |
| `borderColor`, `color` | ARGB 0xFF202B38 (entier décimal en JSON) |
| `fontSize` | 10 points, de 6 à 100 |
| `bold`, `italic` | `false`, pour les cadres texte |
| `align` | `left`, `center`, `right`, `justify`, pour les cadres texte |

Les limites sont 20 pages et 200 éléments par template ; le fichier reste
limité à 1 Mo. Bordures : 0–10 mm ; padding : 0–30 mm ; arrondis : 0–100 mm.
Les polices Noto Sans embarquées sont utilisées pour un rendu hors ligne.

## Types de cadres

- `text` : `text` contient une chaîne fixe, ou `binding` désigne une valeur du
  CV. Ne pas fournir les deux. Le texte fixe est limité à 10 000 caractères.
- `rectangle` : surface décorative, avec fond, bordure et arrondis.
- `photo` : photo du CV, recadrée pour remplir le cadre et découpée selon ses
  arrondis. Sans photo ou lorsque son affichage est désactivé, le cadre est omis.
- `section` : `section` désigne une section standard (`experiences`, `education`,
  `skills`, etc.). Elle est rendue avec son titre et tous ses éléments. Le style
  interne utilise les réglages `tokens` et `sections` ; la couleur et la taille
  du corps viennent du cadre. Une section vide ou masquée est omise.
- `flow` : cadre de contenu structuré qui se poursuit sur des pages supplémentaires
  si nécessaire, en conservant sa position et sa largeur. Les modèles intégrés
  utilisent ces cadres pour préserver les CV longs et les sections personnalisées.

Pour composer différemment les détails d'une expérience, utiliser plusieurs
cadres `text` liés à ses champs. Les cadres de section sont une commodité pour
réutiliser le rendu structuré existant, pas une contrainte sur la composition.

## Liaisons aux données

Exemples : `personalInfo.fullName`, `personalInfo.headline`, `personalInfo.email`,
`profile`, `experiences.0.company`, `experiences.0.position`,
`experiences.0.period.start.year`, `education.0.degree`, `skills.0.name`,
`customSections.0.text`, `customSections.0.items.0.title`.

Les chemins suivent les clés du JSON du CV ; `personalInfo.fullName` est une
valeur calculée supplémentaire. Les indices commencent à zéro. La cible doit
être une valeur simple, pas une liste ou un objet. Un indice absent et une date
optionnelle absente donnent du texte vide ; une clé inconnue produit une erreur
de rendu. Les champs des sections masquées restent masqués.

## Dépassement et pagination

Pour les cadres fixes (`text`, `section`, `photo`, `rectangle`), les pages sont
explicites : un cadre ne se déplace pas, ne se réduit pas
automatiquement et ne se poursuit pas sur une autre page. Si son texte ou sa
section dépasse sa hauteur, la génération échoue avec l'identifiant du cadre.
L'aperçu principal affiche cette erreur, et l'aperçu du catalogue l'expose dans
l'infobulle d'erreur. L'export ne produit pas de PDF tronqué.

Il faut alors agrandir le cadre, réduire sa typographie ou revoir la composition.
Les indices de listes sont fixes : cette version n'ajoute pas automatiquement de
cadres ou de pages lorsque de nouvelles expériences sont saisies. Un template
ne rend que les contenus qu'il référence. Les sections non référencées restent
dans le CV, mais n'apparaissent pas dans le PDF.

Les cadres `flow` proposent une pagination automatique (voir ci-dessous).
Les blocs libres répétés, la rotation, les images décoratives externes et
l'import de polices ne font pas partie de cette version du canvas.
Dans une composition fixe, les couleurs et la géométrie de photo sont propres
aux cadres ; les contrôles globaux correspondants sont désactivés. Dans les
modèles utilisant des cadres de contenu, les réglages de thème restent disponibles.
Le choix d'afficher la photo continue de fonctionner.

Le stockage local, les conflits de révision, l'export/import et la copie du
template dans le CV conservent leurs règles de révision. Une mise à jour du
catalogue ne déplace donc pas les cadres des CV existants.

## Cadres de contenu paginés

`flow` utilise la même géométrie que les autres cadres. Ses propriétés sont :

| Propriété | Rôle |
| --- | --- |
| `sectionOrder` | Sections à rendre, dans l'ordre indiqué, sans doublons |
| `includeRemaining` | Ajouter les autres sections selon l'ordre du CV (défaut : false) |
| `excludedSections` | Sections réservées à un autre cadre |
| `includeCustom` | Ajouter les sections personnalisées visibles (défaut : false) |
| `showHeader` | Ajouter l'identité et l'en-tête au début du cadre |
| `showContacts` | Afficher les coordonnées dans ce cadre |
| `showPhoto` | Afficher la photo dans ce cadre plutôt que dans l'en-tête |
| `palette` | `custom` (couleur et taille du cadre), `body` ou `sidebar` (styles du thème) |
| `titleMargin` | Fraction de la largeur réservée aux titres en marge, de 0 à 0,35 |

Les sections vides ou masquées sont omises. Les cadres continuent indépendamment
les uns des autres : un en-tête ou des coordonnées déjà rendus ne se répètent pas.
Sur ces pages paginées, les éléments fixes constituent le fond répété et les
cadres de contenu sont peints au-dessus, dans leur ordre de déclaration.
Un bloc insécable plus haut que son cadre déclenche une erreur ciblée.

`showPageNumber: true` sur la page ajoute la pagination dans une bande inférieure
de 10 mm ; placer les cadres au-dessus de cette bande. Les cadres utilisent des
coordonnées fixes : une longue adresse s'adapte à la largeur de son cadre ou
rejoint l'en-tête, sans déplacer les autres éléments.

Les huit canvas intégrés sont définis dans
`lib/features/cv/domain/design/builtin_canvases.dart`. Les anciennes propriétés
`structure` ont été supprimées. Tous les PDF passent par le même interpréteur
de cadres canvas.
