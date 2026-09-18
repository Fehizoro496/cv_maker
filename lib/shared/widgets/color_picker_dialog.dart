import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_theme.dart';

/// Ouvre le sélecteur de couleur et retourne la couleur retenue.
///
/// Retourne `null` si l'utilisateur annule.
Future<Color?> showColorPicker(
  BuildContext context, {
  required Color initial,
  String title = 'Couleur d’accent',
  List<Color> suggestions = const [],
}) => showDialog<Color>(
  context: context,
  builder: (context) => ColorPickerDialog(
    initial: initial,
    title: title,
    suggestions: suggestions,
  ),
);

/// Sélecteur de couleur : teinte, saturation, luminosité et saisie
/// hexadécimale.
///
/// Écrit sur place plutôt qu'emprunté à un paquet : l'application doit
/// fonctionner entièrement hors ligne et n'embarquer que ce qu'elle utilise.
class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({
    super.key,
    required this.initial,
    this.title = 'Couleur d’accent',
    this.suggestions = const [],
  });

  final Color initial;
  final String title;

  /// Couleurs proposées en raccourci, sous le sélecteur.
  final List<Color> suggestions;

  static const width = 340.0;
  static const areaHeight = 180.0;
  static const hueBarHeight = 22.0;

  /// La notation hexadécimale d'une couleur, sans son canal alpha.
  static String hexOf(Color color) {
    final value = color.toARGB32() & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  /// La couleur notée par [text], ou `null` si la notation est invalide.
  static Color? parseHex(String text) {
    final digits = text.trim().replaceFirst('#', '');
    if (digits.length != 6) return null;
    final value = int.tryParse(digits, radix: 16);
    return value == null ? null : Color(0xFF000000 | value);
  }

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late HSVColor _hsv = HSVColor.fromColor(widget.initial);
  late final TextEditingController _hex = TextEditingController(
    text: ColorPickerDialog.hexOf(widget.initial),
  );

  Color get _color => _hsv.toColor();

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  void _setColor(HSVColor value, {bool syncField = true}) {
    setState(() => _hsv = value);
    if (syncField) _hex.text = ColorPickerDialog.hexOf(value.toColor());
  }

  /// Une couleur choisie dans la zone saturation / luminosité.
  void _pickFromArea(Offset local, Size size) {
    final saturation = (local.dx / size.width).clamp(0.0, 1.0);
    final value = 1 - (local.dy / size.height).clamp(0.0, 1.0);
    _setColor(_hsv.withSaturation(saturation).withValue(value));
  }

  void _pickHue(Offset local, double width) {
    final hue = (local.dx / width).clamp(0.0, 1.0) * 360;
    _setColor(_hsv.withHue(hue));
  }

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.dialog),
    ),
    child: SizedBox(
      width: ColorPickerDialog.width,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            _SaturationValueArea(hsv: _hsv, onChanged: _pickFromArea),
            const SizedBox(height: 12),
            _HueBar(hue: _hsv.hue, onChanged: _pickHue),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  key: const Key('color-picker-preview'),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _color,
                    borderRadius: BorderRadius.circular(AppRadii.control),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      key: const Key('color-picker-hex'),
                      controller: _hex,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(7),
                        FilteringTextInputFormatter.allow(
                          RegExp('[#0-9a-fA-F]'),
                        ),
                      ],
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Code hexadécimal',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: '#2F5D8C',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                      ),
                      onChanged: (text) {
                        final parsed = ColorPickerDialog.parseHex(text);
                        // Une saisie incomplète ne réinitialise pas le champ.
                        if (parsed != null) {
                          _setColor(
                            HSVColor.fromColor(parsed),
                            syncField: false,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (widget.suggestions.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'SUGGESTIONS',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  for (final suggestion in widget.suggestions)
                    _SuggestionDot(
                      key: ValueKey(
                        'suggestion-${ColorPickerDialog.hexOf(suggestion)}',
                      ),
                      color: suggestion,
                      isSelected: suggestion.toARGB32() == _color.toARGB32(),
                      onSelected: () =>
                          _setColor(HSVColor.fromColor(suggestion)),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context, _color),
                  child: const Text('Choisir'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// La zone de saturation et de luminosité de la teinte courante.
class _SaturationValueArea extends StatelessWidget {
  const _SaturationValueArea({required this.hsv, required this.onChanged});

  final HSVColor hsv;
  final void Function(Offset local, Size size) onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    // La zone vit dans une colonne : sans hauteur explicite, ses dégradés
    // n'auraient aucune contrainte verticale.
    height: ColorPickerDialog.areaHeight,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, ColorPickerDialog.areaHeight);
        return GestureDetector(
          key: const Key('color-picker-area'),
          behavior: HitTestBehavior.opaque,
          onPanDown: (details) => onChanged(details.localPosition, size),
          onPanUpdate: (details) => onChanged(details.localPosition, size),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.control),
            child: Stack(
              children: [
                // Du blanc vers la teinte pure : la saturation.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor(),
                        ],
                      ),
                    ),
                  ),
                ),
                // Puis vers le noir : la luminosité.
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: hsv.saturation * size.width - 8,
                  top: (1 - hsv.value) * size.height - 8,
                  child: const _Cursor(),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// La barre de teintes, du rouge au rouge.
class _HueBar extends StatelessWidget {
  const _HueBar({required this.hue, required this.onChanged});

  final double hue;
  final void Function(Offset local, double width) onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: ColorPickerDialog.hueBarHeight,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          key: const Key('color-picker-hue'),
          behavior: HitTestBehavior.opaque,
          onPanDown: (details) => onChanged(details.localPosition, width),
          onPanUpdate: (details) => onChanged(details.localPosition, width),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              ColorPickerDialog.hueBarHeight / 2,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          for (var degree = 0; degree <= 360; degree += 60)
                            HSVColor.fromAHSV(1, degree % 360, 1, 1).toColor(),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (hue / 360) * width - 8,
                  top: ColorPickerDialog.hueBarHeight / 2 - 8,
                  child: const _Cursor(),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Le repère blanc qui marque la valeur courante.
class _Cursor extends StatelessWidget {
  const _Cursor();

  @override
  Widget build(BuildContext context) => Container(
    width: 16,
    height: 16,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: const [BoxShadow(color: AppColors.pageShadow, blurRadius: 4)],
    ),
  );
}

class _SuggestionDot extends StatelessWidget {
  const _SuggestionDot({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onSelected,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: isSelected,
    button: true,
    child: InkWell(
      onTap: onSelected,
      customBorder: const CircleBorder(),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: AppColors.surface, width: 2)
              : null,
          boxShadow: isSelected
              ? [BoxShadow(color: color, spreadRadius: 2)]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, size: 15, color: Colors.white)
            : null,
      ),
    ),
  );
}
