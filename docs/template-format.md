# Échange de templates — canvas uniquement

Tous les modèles utilisent désormais le canvas : modèles intégrés, fichiers
importés, aperçus et exports PDF. Le contrat d'échange est le format JSON V2.

- [Référence du canvas](canvas-format.md)
- [Exemple libre sur deux pages](examples/canvas.cv-template.json)
- [Exemple épuré avec pagination automatique](examples/epure.cv-template.json)

## Import et export

Dans **Catalogue des modèles**, utiliser **Importer un modèle** ou **Exporter
le modèle**. Chaque fichier UTF-8 `*.cv-template.json` contient un modèle,
avec une limite de 1 Mo. L'export contient la définition du template, sans
informations personnelles ni réglages propres au CV ouvert.

L'import est enregistré immédiatement dans le catalogue local, même si le
dialogue est ensuite annulé. **Appliquer le modèle** modifie le CV. Les modèles
importés sont conservés dans SQLite et rechargés au démarrage.

L'export de fichiers est disponible sur Windows, macOS, Linux et Web ; Android
et iOS nécessitent encore un adaptateur de partage/export.

## Contrat commun avec la future application de création

```json
{
  "format": "cv-maker-template",
  "schemaVersion": 2,
  "template": {
    "id": "atelier.epure",
    "revision": 1,
    "label": "Épuré",
    "description": "Un cadre de contenu paginé.",
    "spec": {
      "canvas": {
        "pages": [{
          "showPageNumber": true,
          "elements": [{
            "id": "body", "type": "flow",
            "x": 20, "y": 20, "width": 170, "height": 257,
            "palette": "body", "showHeader": true,
            "includeRemaining": true, "includeCustom": true
          }]
        }]
      }
    }
  }
}
```

`canvas` est obligatoire. `header`, `tokens` et `sections` sont des styles
optionnels pour les contenus structurés ; ils ne définissent pas une seconde
mise en page. Les positions et dimensions viennent exclusivement des cadres.
Les anciens champs `structure` et `tokens.pageMarginMm` sont refusés.

- `id` : identifiant stable de 1 à 128 caractères ASCII, lettres, chiffres,
  point, tiret ou souligné ; commencer par une lettre ou un chiffre. Employer
  un préfixe propre à l'éditeur, par exemple `atelier.epure`.
- `revision` : entier positif, augmenté à chaque publication.
- `label` : nom obligatoire, non blanc, limité à 100 caractères.
- `description` : texte obligatoire, éventuellement vide, limité à 500 caractères.
- `schemaVersion` : 2 ; les nouveaux imports V1 sont refusés.

Exporter un modèle intégré fournit une définition complète qui peut servir de
base. Changer son identifiant avant d'importer une variante : les identifiants
intégrés sont réservés.

## Révisions et conservation des CV

Un import identique est sans effet. Une révision supérieure remplace l'entrée
du catalogue ; une révision inférieure ou identique avec un contenu différent
est refusée. Le fichier est validé avant toute écriture.

Appliquer un modèle enregistre sa définition dans le CV. Les mises à jour du
catalogue ne remplacent pas cette copie : il faut appliquer à nouveau le modèle
pour adopter sa nouvelle révision.

Le format V1 et les définitions sans canvas ne sont plus pris en charge,
y compris dans le stockage local et les copies de templates dans les CV.
Aucune conversion de compatibilité n'est conservée. Un ancien template doit
être redéfini au format canvas V2 avant de pouvoir être chargé.

La synchronisation avec la future application de création reste manuelle par
fichiers. Le même contrat pourra être transporté par un service distant.
