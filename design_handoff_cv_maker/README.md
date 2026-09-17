# Handoff : CV Maker — application de bureau Windows (Flutter, Material 3)

## Vue d'ensemble

Application de bureau **Windows** permettant de créer un CV. L'utilisateur remplit des formulaires
section par section dans la colonne centrale et voit à droite **le vrai PDF A4** du CV, qu'il peut
exporter. Tout fonctionne **hors ligne** ; les données restent sur la machine de l'utilisateur.

Utilisateurs : étudiants, jeunes diplômés, chercheurs d'emploi, professionnels qui mettent leur CV
à jour. Ils ne connaissent pas les logiciels de mise en page : l'interface doit être simple et
rassurante. **Toute l'interface est en français.**

Périmètre MVP : un seul modèle de CV, mode clair, pas de compte, pas de cloud, pas d'IA, pas
d'import LinkedIn, pas d'export Word, pas de version mobile/web.

## À propos des fichiers de design

Les fichiers de ce paquet (`CV Maker.dc.html`, `support.js`) sont des **références de design
réalisées en HTML** : des maquettes qui montrent l'apparence et le comportement attendus. Ce **n'est
pas du code de production à copier**. La tâche consiste à **recréer ces maquettes dans le projet
Flutter desktop cible**, avec ses patterns existants (widgets Material 3, gestion d'état, couche de
persistance déjà en place). Si le projet n'existe pas encore, créer une application Flutter desktop
Windows et implémenter les écrans décrits ici.

Ouvrir `CV Maker.dc.html` dans un navigateur : le document contient tous les écrans côte à côte
(zoom/pan libre). Chaque écran porte un attribut `data-screen-label` correspondant aux noms utilisés
ci-dessous.

## Fidélité

**Haute fidélité (hifi).** Couleurs, typographie, espacements et dimensions sont définitifs et
doivent être reproduits fidèlement. Tous les tokens sont listés en fin de document et se traduisent
directement en `ThemeData`. Les écrans sont des **états statiques** : les interactions (frappe,
glisser-déposer, ouverture de dialogues) sont décrites en texte, pas animées dans le HTML.

Fenêtre de référence : **1440 × 900**. Fenêtre étroite à prévoir : **≈ 900 × 760**.
Densité : `VisualDensity.compact`. Police d'interface : **Segoe UI** (police système Windows).
Police du PDF : **Noto Sans** (normal, gras, italique).

---

## Écran principal — trois colonnes

`data-screen-label="01 Écran principal – Infos perso"` et `"02 Écran principal – Expériences"`

```
┌──────────────┬────────────────────────┬────────────────────────┐
│ Navigation   │ Formulaire d'édition   │ Aperçu PDF   [↻] [⤓]   │
│ des sections │  [↶ Annuler] [↷ Rétab.]│                        │
└──────────────┴────────────────────────┴────────────────────────┘
   240 px            reste (flex)               620 px
```

Au-dessus : la barre de titre native Windows (32 px dans la maquette, non à dessiner si vous
utilisez la décoration système ; si vous utilisez `bitsdojo_window`, reproduire : icône
`description` bleue 16 px, titre « CV Maker — <nom du CV>.cv » en 12 px `onSurfaceVariant`, boutons
de fenêtre à droite, fond `#EDF0F5`, bordure basse 1 px `#DDE1E8`).

### 1. Colonne Navigation (240 px, fond `#F5F7FA`, bordure droite 1 px `#DDE1E8`)

**En-tête (padding 14/12/12, bordure basse 1 px `#DDE1E8`)**
- Sur-titre « CV OUVERT » : 11 px, `letter-spacing: .06em`, majuscules, `#43474E`.
- Ligne : nom du CV (14 px / 600, ellipsis) + `IconButton` 32 px `folder_open` (`#2F5D8C`,
  fond `#E3EAF3`, radius 16) → ouvre le dialogue **Mes CV**. Tooltip « Mes CV ».
- Sous-titre : « Modifié aujourd'hui à 14:02 » — 11 px `#73777F`.

**Liste des sections** (padding 8 px, rangées de 36 px, gap 1 px)
Chaque rangée = `ListTile` dense / `InkWell` : radius **18 px** (stadium), padding horizontal 10 px,
icône 18 px + libellé 13 px, gap 10 px.

| Section | Icône (Material Symbols) | Compteur |
|---|---|---|
| Informations personnelles | `person` | — |
| Profil professionnel | `short_text` | — |
| Expériences | `work` | 3 |
| Formations | `school` | 2 |
| Compétences | `bolt` | 9 |
| Langues | `translate` | 3 |

Puis un sur-titre « SECTIONS FACULTATIVES » (même style que « SECTIONS ») et :

| Section facultative | Icône | Visibilité |
|---|---|---|
| Certifications | `verified` | `visibility` |
| Projets | `folder` | `visibility` |
| Centres d'intérêt | `interests` | `visibility_off` |
| Références | `group` | `visibility_off` |

- **État sélectionné** : fond `#D6E3F2`, texte et icône `#12385C`, poids 600.
- **État non sélectionné** : texte `#43474E`, icône `#73777F`, fond transparent (hover : `#EDF0F5`).
- **Compteur** : 11 px `#73777F`, aligné à droite.
- **Interrupteur de visibilité** : `IconButton` 28 px à droite de la rangée,
  `visibility` (`#2F5D8C`) = section affichée dans le CV, `visibility_off` (`#9AA0A6`) = masquée.
  Quand une section est masquée, **toute la rangée passe en `#9AA0A6`** (libellé et icône) et la
  section n'apparaît pas dans le PDF. Tooltips : « Affichée dans le CV » / « Masquée dans le CV ».
  Basculer la visibilité régénère le PDF.

**Pied (bordure haute 1 px)** : `cloud_off` 15 px + « Hors ligne — données sur cet ordinateur »,
11 px `#73777F`.

### 2. Colonne Formulaire (flex, fond `#FCFCFF`)

**En-tête (padding 14 / 20 / 12, bordure basse 1 px `#E7EAEF`)**
- Titre de section : 18 px / 600. Sous-titre d'aide : 12 px `#43474E`, marge haute 2 px.
  - Infos perso : « Ces informations apparaissent en haut de votre CV. »
  - Expériences : « Commencez par la plus récente. Faites glisser pour réordonner. »
- **Annuler / Rétablir** : deux `IconButton` 32 px (`undo`, `redo`), icône 19 px.
  Actif `#2F5D8C`, **désactivé `#C0C4CA`**. Raccourcis **Ctrl+Z / Ctrl+Y**, tooltips
  « Annuler (Ctrl+Z) » / « Rétablir (Ctrl+Y) ».
- **Indicateur de sauvegarde** : puce de 28 px de haut, radius 14, padding 0/10, icône 16 px + texte
  12 px / 600 :
  - *Enregistré* — fond `#E3F1E7`, texte `#1E5233`, icône `check_circle`.
  - *Enregistrement…* — fond `#EDF0F5`, texte `#43474E`, icône `progress_activity` en rotation
    (1,1 s linéaire, infini).
  - *Erreur d'enregistrement* — fond `#FFDAD6`, texte `#8C1D18`, icône `error`, **+ bouton
    « Réessayer »** (24 px de haut, radius 12, fond `#8C1D18`, texte blanc 11 px) accolé dans la puce.

**Corps** : scroll vertical, padding 18 / 20 / 24, gap 18 px entre blocs.

#### Champ de saisie (`TextField` outlined, compact)

- Hauteur **44 px** (42 px à l'intérieur des cartes de liste), radius **4 px**,
  bordure 1 px `#73777F`, padding horizontal 12 px, valeur 13 px `#1A1C1E`.
- Label flottant : 11 px `#43474E`, posé sur la bordure (fond `#FCFCFF`, padding horizontal 4 px).
- **Focus** : bordure **2 px `#2F5D8C`**, label 11 px / 600 `#2F5D8C`, curseur `#2F5D8C`.
- **Désactivé** (ex. « Fin » quand « En cours » est coché) : bordure `#C3C7CD`, fond `#F2F3F5`,
  label et valeur `#9AA0A6`, valeur affichée « —— ».

#### Section « Informations personnelles » (état de référence, rempli)

1. Rangée de 2 champs (grid 1fr 1fr, gap 14 px) : **Prénom** « Camille », **Nom** « Moreau ».
2. **Titre professionnel** pleine largeur — montré **en focus** dans la maquette
   (« Développeuse Front-End »).
3. **Bloc photo** : conteneur padding 12 px, bordure 1 px `#DDE1E8`, radius 12, fond `#F5F7FA`.
   - Avatar 64 px radius 32, fond `#D6E3F2`, `account_circle` 30 px `#2F5D8C` (ou la photo choisie).
   - Titre « Photo (facultative) » 13 px / 600.
   - Boutons : `OutlinedButton.icon` « Choisir une image » (`upload`, 32 px, radius 16,
     bordure `#73777F`, texte `#2F5D8C` 12/600) + `TextButton` « Retirer » (texte `#43474E`).
   - Mention discrète : icône `info` 15 px `#73777F` + « La photo n'est pas enregistrée : elle devra
     être ajoutée à nouveau au prochain lancement. » 11 px `#43474E`, interligne 1,45.
   - **Comportement : la photo n'est jamais persistée.** Elle vit en mémoire pour la session
     (`Uint8List` en RAM), est utilisée dans le PDF, et disparaît au redémarrage.
4. Grid 2 × 2 (gap 14 px) : **Localisation** « Lyon, France », **Téléphone** « +33 6 12 34 56 78 »,
   **E-mail** « camille.moreau@email.fr », **Site / portfolio** « camille-moreau.fr ».
5. **Liens** (liste modifiable) : titre « Liens » 13 px / 600, puis une ligne par lien —
   bordure 1 px `#C3C7CD`, radius 12, padding 6/8, contenant : poignée `drag_indicator` 18 px
   `#9AA0A6` (`cursor: grab`), libellé 12 px / 600 sur 88 px (« LinkedIn », « GitHub »), URL 12 px
   `#43474E` en ellipsis, `IconButton` 28 px `edit` puis `delete` (`#73777F`).
   En bas : `OutlinedButton.icon` « Ajouter un lien » (`add`).

#### Motif commun des listes (Expériences, Formations, Compétences, Langues, Certifications, Projets, Centres d'intérêt, Références)

Voir `"02 Écran principal – Expériences"`.

- **Carte repliée** : bordure 1 px `#C3C7CD`, radius 12, fond `#FCFCFF`, padding 9 / 8 / 9 / 6,
  hauteur ≈ 46 px. Contenu : `drag_indicator` 18 px `#9AA0A6` → résumé sur **une ligne**
  (13 px / 600 pour l'essentiel + complément 400 `#43474E`) → `IconButton` 28 px `delete`
  (`#73777F`) → `IconButton` 28 px `expand_more` (20 px, `#43474E`).
  Résumé d'expérience : « Poste · Entreprise — janv. 2021 → août 2023 ».
- **Carte dépliée** : bordure 1 px **`#2F5D8C`**, `elevation 1`
  (`0 1px 3px rgba(16,24,40,.1)`), en-tête identique avec `expand_less` et bordure basse 1 px
  `#E7EAEF`, puis corps padding 16 / 14 avec gap 14 px.
- **Glisser-déposer** (`ReorderableListView`) : l'élément soulevé prend une bordure `#2F5D8C`, une
  ombre `0 8px 20px rgba(47,93,140,.28)` (elevation 6) et le curseur `grabbing` ;
  **l'emplacement de dépôt est marqué par une barre horizontale 2 px `#2F5D8C`** (radius 1,
  marge horizontale 4 px).
- **Ajouter** : bouton en bas de liste, aligné à gauche, 36 px, radius 18, fond `#D6E3F2`,
  texte `#12385C` 13/600, icône `add` 18 px — « Ajouter une expérience », « Ajouter une formation »…
- **Supprimer** : ouvre le dialogue de confirmation (voir plus bas), annulable par Ctrl+Z.
- **État vide** : conteneur bordure **pointillée** 1 px `#C3C7CD`, radius 12, fond `#F8F9FB`,
  padding 28 px, centré : icône de la section 28 px `#9AA0A6`, titre 14 px / 600
  (« Aucune expérience pour l'instant »), texte 12 px `#43474E` (« Ajoutez votre poste le plus
  récent en premier : il apparaîtra aussitôt dans l'aperçu. »), puis bouton rempli
  « Ajouter une expérience ».

#### Champs par section

- **Profil professionnel** : un seul `TextField` multiligne (min. 4 lignes).
- **Expériences** : Poste, Entreprise (grid 1fr 1fr) · Lieu, Début, Fin (grid 1.4fr 1fr 1fr, les
  champs de date portent une icône `calendar_month` 17 px en suffixe) · `Checkbox` **« En cours »**
  (cochée = `check_box` `#2F5D8C` 20 px, libellé 13 px ; désactive le champ Fin) ·
  **Description / réalisations** : `TextField` multiligne, hauteur min. 88 px, interligne 1,6,
  puces saisies par l'utilisateur (« • … »).
- **Formations** : Diplôme, Établissement, Lieu, Début, Fin, Description (facultative).
- **Compétences** : Nom, Catégorie (facultative), Niveau (facultatif).
- **Langues** : Langue, Niveau — `DropdownMenu` avec saisie libre autorisée
  (langue maternelle, C2, C1, B2, B1, A2, A1).
- **Certifications, Projets, Centres d'intérêt, Références** : listes simples (intitulé +
  organisme/date ou description courte selon le PDF de référence).

### 3. Colonne Aperçu PDF (620 px, min. 420 px ; fond `#EDF0F5`, bordure gauche 1 px `#DDE1E8`)

**Barre d'outils (48 px, fond `#F5F7FA`, bordure basse 1 px `#DDE1E8`, gap 8 px, padding 0/12)**
1. Titre « Aperçu PDF » 13 px / 600 (flex).
2. **Puce d'état** (24 px de haut, radius 12, 11 px / 600) :
   - *À jour* — `check_circle` 14 px, fond `#E3F1E7`, texte `#1E5233`.
   - *Génération en cours…* — `progress_activity` en rotation, fond `#E3EAF3`, texte `#12385C`.
   - *Erreur* — `error`, fond `#FFDAD6`, texte `#8C1D18`.
3. **Contrôle de zoom** : conteneur 32 px, radius 16, bordure 1 px `#C3C7CD` ; `remove` /
   valeur (« 100 % », largeur 40 px, centrée) / `add`. Pas de 25 %, bornes 50 %–200 %,
   molette Ctrl acceptée.
4. `IconButton` 32 px **`refresh`** `#2F5D8C`, tooltip « Rafraîchir ».
5. `FilledButton.icon` **« Exporter »** : 32 px, radius 16, fond `#2F5D8C`, texte blanc 12/600,
   icône `download` 16 px.

Pendant la génération, une **barre de progression 3 px** (`#D6E3F2` avec remplissage `#2F5D8C`)
s'affiche sous la barre d'outils.

**Zone de pages** : scroll vertical, pages centrées, gap 12 px, padding vertical 16 px, page
blanche avec ombre `0 2px 10px rgba(16,24,40,.18)`. Sous la dernière page : « Page 1 sur 1 »,
11 px `#43474E` (compteur qui suit le défilement).

**État « génération en cours »** (voir écran 02) : les pages existantes restent visibles à
`opacity .55` / `.35`, avec au centre `progress_activity` 34 px `#2F5D8C` et l'étiquette
« Mise à jour de l'aperçu… » (12 px / 600 `#12385C` sur pastille `#FCFCFF`, radius 12).

**État d'erreur** : au centre, `error` 24 px `#8C1D18`, « Le PDF n'a pas pu être généré. » 11–13 px
`#43474E`, `OutlinedButton.icon` « Réessayer » bordé `#8C1D18`.

---

## Fenêtre étroite (onglets)

`data-screen-label="03 Fenêtre étroite – Édition"` et `"04 Fenêtre étroite – Aperçu"`

Sous **1100 px de large**, la colonne Navigation (240 px) **reste visible**, et le formulaire et
l'aperçu deviennent **deux onglets** occupant le reste de la largeur.

- `TabBar` : hauteur 44 px, fond `#FCFCFF`, bordure basse 1 px `#DDE1E8`, deux onglets à largeur
  égale — « Édition » (`edit_note`) et « Aperçu » (`picture_as_pdf`). Onglet actif : texte et icône
  `#2F5D8C`, poids 600, **indicateur 3 px `#2F5D8C`** en bas. Onglet inactif : texte `#43474E`,
  icône `#73777F`.
- L'en-tête du formulaire devient compact : titre 16 px, `IconButton` 30 px, puce de sauvegarde
  26 px / 11 px.
- Les grilles de champs restent en 2 colonnes (gap 12 px) ; le bloc photo passe en une seule ligne
  (avatar 52 px + texte + bouton « Choisir… »).
- Dans l'onglet Aperçu, la barre d'outils reste la même mais la puce d'état est réduite (max 96 px)
  et le zoom par défaut devient **85 %** pour que la page entre en largeur.
- Transition d'onglet : 200 ms. Le passage large ⇄ étroit conserve la section sélectionnée ;
  en repassant en large, les deux panneaux réapparaissent côte à côte.

---

## Liste des CV et premier lancement

`data-screen-label="05 Liste des CV"`, `"06 Premier lancement"`

### Dialogue « Mes CV »

`Dialog` de **560 px** de large, radius **28 px**, fond `#FCFCFF`, padding 24 px, gap 16 px,
scrim `rgba(16,24,40,.32)`.

- En-tête : titre « Mes CV » 20 px / 600 + sous-titre « 3 CV enregistrés sur cet ordinateur »
  12 px `#43474E` ; à droite `FilledButton.icon` **« Créer »** (36 px, radius 18, `#2F5D8C`, `add`).
- Une ligne par CV (gap 8 px) : bordure 1 px `#DDE1E8`, radius 12, padding 10 / 10 / 10 / 12 ;
  icône `description` 22 px `#73777F`, nom 14 px / 600, méta 11 px `#43474E`
  (« Modifié le 12 septembre 2026 »), puis trois `IconButton` 32 px :
  `drive_file_rename_outline` (Renommer), `content_copy` (Dupliquer), `delete` (Supprimer).
- **CV ouvert** : bordure 1 px `#2F5D8C`, fond `#EEF4FA`, icône `#2F5D8C`, méta suffixée « · Ouvert ».
- Pied : « Au démarrage, le dernier CV modifié est rouvert. » 11 px `#73777F` + `TextButton`
  « Fermer ».
- Tri par date de modification décroissante. Un clic sur une ligne ouvre ce CV et ferme le dialogue.

### Premier lancement (aucun CV)

Écran vide centré : cercle 96 px fond `#E3EAF3` avec `note_add` 44 px `#2F5D8C` ; titre
« Bienvenue dans CV Maker » 24 px / 600 ; texte 14 px `#43474E`, interligne 1,6, largeur max 420 px :
« Remplissez vos informations section par section : le CV en PDF se met à jour à côté de vous. Tout
reste sur votre ordinateur. » ; `FilledButton.icon` **« Créer mon CV »** (40 px, radius 20, `add`
20 px) ; enfin `cloud_off` 16 px + « Fonctionne hors ligne, sans compte » 12 px `#73777F`.

Créer un CV depuis cet écran ouvre l'écran principal sur **Informations personnelles**.

---

## Confirmations, erreurs et notifications

`data-screen-label="07 …"` n'existe pas pour cette planche : elle est regroupée dans la section 4 du
document HTML.

### Dialogues de confirmation

`Dialog` 400 px, radius 28, padding 24, gap 12 :
icône `delete` 24 px `#8C1D18` → titre 18 px / 600 → texte 13 px `#43474E` interligne 1,55 →
actions alignées à droite (`TextButton` « Annuler » `#2F5D8C` / `FilledButton` « Supprimer »
fond `#8C1D18`, texte blanc), gap 8 px.

- **Supprimer un CV** — « Supprimer ce CV ? » / « « <nom> » sera supprimé définitivement de cet
  ordinateur. Cette action est irréversible. »
- **Supprimer un élément de liste** — « Supprimer cette expérience ? » / « « <résumé> » sera retirée
  de votre CV. Vous pourrez annuler avec Ctrl+Z. »
- **Renommer** — même gabarit, un `TextField` en focus (48 px, bordure 2 px `#2F5D8C`, label
  « Nom du CV », texte présélectionné) et actions « Annuler » / « Renommer » (`#2F5D8C`).

### Notifications « toast » (pas de `SnackBar`)

Empilées **en bas à droite** de la fenêtre, 16 px des bords, **3 au maximum**, la plus récente en
bas, entrée par glissement + fondu **180 ms**, disparition automatique après **4 s** (6 s si elles
portent une action), **croix de fermeture toujours présente**.

Gabarit : largeur 400 px (300 px en fenêtre étroite), fond `#FCFCFF`, bordure 1 px `#DDE1E8`,
**bordure gauche 4 px de couleur**, radius 12, padding 12 / 10 / 12 / 14,
ombre `0 10px 24px rgba(16,24,40,.16)` ; icône 20 px, titre 13 px / 600, texte secondaire 12 px
`#43474E`, action en `OutlinedButton` 30 px radius 15, `IconButton` `close` 24 px `#73777F`.

| Toast | Bordure gauche | Icône | Titre / texte / action |
|---|---|---|---|
| PDF pas à jour au moment de l'export | `#2F5D8C` | `progress_activity` (rotation) | « Mise à jour du PDF… » / « L'export démarrera dès que l'aperçu sera à jour. » |
| Export réussi | `#1E5233` | `check_circle` | « PDF exporté » / chemin du fichier (ellipsis) / action **« Ouvrir le dossier »** (`folder_open`) |
| Export échoué | `#8C1D18` (bordure `#F3CFCB`) | `error` | « L'export a échoué » / « Le fichier est ouvert dans une autre application. Fermez-le puis réessayez. » / action **« Réessayer »** (`refresh`) |

Implémentation Flutter : `Overlay` + `AnimatedSlide` / `AnimatedOpacity` dans un
`ToastController` global — **pas** `ScaffoldMessenger.showSnackBar`.

### Flux d'export

1. Clic sur **Exporter**.
2. Si le PDF n'est pas à jour : toast « Mise à jour du PDF… », régénération, puis on continue.
3. **Boîte de dialogue d'enregistrement native Windows** (`file_selector` / `file_picker`) —
   à ne pas dessiner. Nom proposé : `CV_<Prénom>_<Nom>.pdf`.
4. Succès → toast « PDF exporté » + « Ouvrir le dossier ». Échec → toast d'erreur + « Réessayer ».

### Erreurs à couvrir

- Échec de sauvegarde → puce d'en-tête « Erreur d'enregistrement » + action « Réessayer » ;
  les modifications restent en mémoire.
- Échec de génération du PDF → état d'erreur dans l'aperçu + « Réessayer ».
- Échec de l'export → toast d'erreur.
Message clair, sans jargon technique, toujours accompagné d'une action.

---

## Comportements et état

### Temporisations

| Comportement | Valeur |
|---|---|
| Sauvegarde automatique | **600 ms** après la dernière frappe (debounce) |
| Régénération du PDF | **900 ms** après la dernière frappe (debounce) |
| Transition d'onglet | 200 ms |
| Entrée d'un toast | 180 ms |
| Durée d'un toast | 4 s (6 s avec action) |
| Rotation de `progress_activity` | 1,1 s linéaire, infini |

### État applicatif

- `cvList: List<CvSummary>` — id, nom, date de modification ; trié par date décroissante.
- `currentCv: Cv` — modèle complet ; `openLastModified()` au démarrage.
- `selectedSection: SectionId` — pilote le formulaire affiché.
- `sectionVisibility: Map<SectionId, bool>` — uniquement pour les 4 sections facultatives.
- `saveState: idle | saving | saved | error`.
- `previewState: upToDate | generating | error` + `pdfBytes`, `pageCount`, `zoom`.
- `undoStack` / `redoStack` par CV (au moins 50 pas) ; Ctrl+Z / Ctrl+Y ; les boutons sont
  désactivés quand la pile correspondante est vide.
- `sessionPhoto: Uint8List?` — **jamais persistée**.
- Persistance : fichier local par CV (JSON ou SQLite), écriture atomique ; aucun accès réseau.
- Toute mutation du modèle déclenche : `saveState = saving` (debounce 600 ms) et
  `previewState = generating` (debounce 900 ms).

---

## Modèle de CV A4 (le PDF)

`data-screen-label="07 CV A4 – 1 page avec photo"`, `"08 CV A4 – page 1 sans photo"`,
`"09 CV A4 – page 2 sans photo"`

Un seul modèle « professionnel » dans le MVP. À générer avec le package **`pdf`** (`pw.*`),
police **Noto Sans** (regular / bold / italic embarquées dans `assets/fonts/`).
**Texte sélectionnable** : jamais d'image de texte.

- Format **A4 portrait** (210 × 297 mm), marges **18 mm** sur les quatre côtés
  (68 px à 96 dpi dans la maquette).
- Couleur d'accent unique `#2F5D8C`, réservée : filet sous l'en-tête, titre professionnel,
  titres de section. Tout le reste en noir/gris.
- Adapté aux logiciels de tri de candidatures (ATS) : une seule colonne, pas de tableau de mise en
  page, hiérarchie par la taille et la graisse.
- Numérotation « 1 / 2 » en bas à droite, 9,5 pt `#9AA0A6`.

### Styles du PDF

| Élément | Style |
|---|---|
| Nom | 23 pt / 700, `letter-spacing -.015em`, interligne 1,1 |
| Titre professionnel | 11 pt / 600, `#2F5D8C` |
| Coordonnées | 8,5 pt / 400, `#3A3F45`, interligne 1,7, séparateur « · » |
| Filet sous l'en-tête | 1,5 px, `#2F5D8C` |
| Titre de section | 8 pt / 700, majuscules, `letter-spacing .14em`, `#2F5D8C` |
| Intitulé (poste, diplôme, projet) | 10 pt / 700 |
| Dates | 8,5 pt / 400, `#3A3F45`, alignées à droite sur la même ligne que l'intitulé |
| Lieu | 8,5 pt / italique, `#3A3F45` |
| Corps et puces | 9,5 pt / 400, interligne 1,6 |
| Espacement entre sections | 20–22 px (≈ 5,5 mm) |
| Espacement entre éléments d'une section | 12–13 px |

### En-tête

- **Avec photo** : photo ronde **96 px** (25 mm) à gauche, gap 24 px, bloc texte à droite.
- **Sans photo** : bloc texte pleine largeur (voir page 1 de la version B).

### Ordre des sections

Profil professionnel · Expériences · Formations · Compétences · Langues · Certifications · Projets ·
Centres d'intérêt · Références. Les sections **masquées** ou vides n'apparaissent pas.

### Pagination

- **Un titre de section ne doit jamais rester seul en bas d'une page** : le titre et le premier
  élément qui le suit forment un bloc insécable (`pw.Column(children:[…])` non découpable, ou
  `keepTogether`).
- Un élément d'expérience ne doit pas être coupé après sa seule première ligne (au moins deux
  lignes du bloc restent solidaires).
- Deux versions à valider : **une page avec photo** (profil + 3 expériences + 2 formations +
  compétences + langues) et **deux pages sans photo** (mêmes données enrichies + certifications,
  projets, centres d'intérêt, références).

---

## Tokens de design

### Couleurs — `ColorScheme.fromSeed(seedColor: Color(0xFF2F5D8C))`, `Brightness.light`

| Token | Hex |
|---|---|
| primary | `#2F5D8C` |
| onPrimary | `#FFFFFF` |
| secondaryContainer (sélection nav, bouton tonal) | `#D6E3F2` |
| onSecondaryContainer | `#12385C` |
| surface | `#FCFCFF` |
| surfaceContainerLow (nav, barres d'outils) | `#F5F7FA` |
| surfaceContainer (fond d'aperçu, barre de titre) | `#EDF0F5` |
| onSurface | `#1A1C1E` |
| onSurfaceVariant | `#43474E` |
| outline (bordure de champ) | `#73777F` |
| outlineVariant (séparateurs) | `#DDE1E8` |
| bordure de carte | `#C3C7CD` |
| texte/icône désactivés | `#9AA0A6` (bordure désactivée `#C0C4CA`, fond `#F2F3F5`) |
| error | `#8C1D18` |
| errorContainer / onErrorContainer | `#FFDAD6` / `#8C1D18` |
| succès (conteneur / texte) | `#E3F1E7` / `#1E5233` |
| accent du PDF | `#2F5D8C` |
| encre du PDF / gris du PDF | `#1B1F23` / `#3A3F45` |
| scrim de dialogue | `rgba(16,24,40,.32)` |

### Typographie d'interface (Segoe UI)

| Rôle | Style |
|---|---|
| headlineSmall — titre d'écran | 24 px / 600 |
| titleLarge — titre de section | 18 px / 600 |
| titleMedium — titre de carte | 14 px / 600 |
| bodyMedium — texte courant, champs | 13 px / 400 |
| bodySmall — texte secondaire | 12 px / 400, `#43474E` |
| labelSmall — sur-titre | 11 px / 500, majuscules, `letter-spacing .06em`, `#43474E` |
| labelMedium — puces et boutons | 12 px / 600 |

### Espacements (densité compacte)

4 (icônes) · 8 (entre cartes) · 12 (entre champs d'une rangée) · 14 (entre champs d'un bloc) ·
16 (padding de panneau) · 20 (gouttière du formulaire) · 24 (padding de dialogue) · 28 (états vides).

### Dimensions clés

| Élément | Valeur |
|---|---|
| Colonne navigation | 240 px |
| Colonne aperçu | 620 px (min. 420) |
| Bascule en onglets | largeur de fenêtre < 1100 px |
| Rangée de navigation | 36 px |
| `TextField` compact | 44 px (42 px dans les cartes) |
| `IconButton` | 32 px (28 px dans les cartes) |
| Barre d'outils de l'aperçu / `TabBar` | 48 px / 44 px |
| Barre de titre | 32 px |
| Boutons | 36 px (40 px pour l'appel à l'action principal) |
| Marge du PDF | 18 mm |

### Rayons

4 px `TextField` · 12 px cartes de liste, toasts, conteneurs · 18 px (stadium) boutons et rangées de
navigation · 28 px `Dialog` · avatars en cercle complet.

### Élévations / ombres

| Usage | Ombre |
|---|---|
| Carte dépliée (elevation 1) | `0 1px 3px rgba(16,24,40,.10)` |
| Page PDF dans l'aperçu | `0 2px 10px rgba(16,24,40,.18)` |
| Élément en cours de glissement (elevation 6) | `0 8px 20px rgba(47,93,140,.28)` |
| Toast | `0 10px 24px rgba(16,24,40,.16)` |
| Dialog | `0 12px 40px rgba(16,24,40,.30)` |

---

## Assets

- **Icônes** : Material Symbols Outlined (poids 400, taille optique 20). Les noms utilisés dans la
  maquette correspondent aux `Icons.*` de Flutter : `person`, `short_text` (`Icons.short_text`),
  `work`, `school`, `bolt`, `translate`, `verified`, `folder`, `interests`, `group`, `visibility`,
  `visibility_off`, `folder_open`, `undo`, `redo`, `refresh`, `download`, `add`, `remove`, `delete`,
  `drag_indicator`, `expand_more`, `expand_less`, `check_circle`, `error`, `info`, `close`, `edit`,
  `edit_note`, `picture_as_pdf`, `calendar_month`, `upload`, `account_circle`, `note_add`,
  `description`, `cloud_off`, `content_copy`, `drive_file_rename_outline`, `check_box`.
- **Polices** : Segoe UI (fournie par Windows, aucun asset à embarquer) ;
  **Noto Sans** regular / bold / italic à placer dans `assets/fonts/` pour le PDF
  (`pw.Font.ttf`) — licence SIL OFL.
- **Photo de profil** : fournie par l'utilisateur à l'exécution ; l'emplacement gris avec la
  mention `PHOTO` dans la maquette n'est qu'un repère de cadrage, à ne pas reproduire.
- Aucun logo ni illustration à produire.

## Fichiers de ce paquet

| Fichier | Contenu |
|---|---|
| `README.md` | Cette spécification (auto-suffisante). |
| `CV Maker.dc.html` | Toutes les maquettes : écran principal (2 états), fenêtre étroite (2 onglets), liste des CV, premier lancement, planche d'états et de dialogues, modèle A4 (1 page avec photo, 2 pages sans), tokens. |
| `support.js` | Runtime nécessaire à l'affichage du fichier HTML (ne pas porter dans l'app). |

Ouvrir le HTML dans un navigateur ; le document se déplace au glisser et se zoome à la molette.
