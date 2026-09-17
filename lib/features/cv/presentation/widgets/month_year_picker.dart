import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/cv_month_year.dart';

/// Ce que l'utilisateur a choisi dans le sélecteur de date.
///
/// Un effacement et une annulation ne se confondent pas : l'annulation ne
/// retourne aucune sélection, l'effacement retourne une sélection vide.
class CvMonthYearSelection {
  const CvMonthYearSelection(this.value);

  /// La date choisie, ou `null` si l'utilisateur a effacé le champ.
  final CvMonthYear? value;
}

/// Ouvre le sélecteur de mois et d'année d'un champ de date du CV.
///
/// Retourne `null` si l'utilisateur annule.
Future<CvMonthYearSelection?> showMonthYearPicker(
  BuildContext context, {
  required String label,
  CvMonthYear? initialValue,
}) {
  return showDialog<CvMonthYearSelection>(
    context: context,
    builder: (context) => MonthYearPickerDialog(
      label: label,
      initial: initialValue,
      hasValue: initialValue != null,
    ),
  );
}

class MonthYearPickerDialog extends StatefulWidget {
  const MonthYearPickerDialog({
    super.key,
    required this.label,
    this.initial,
    this.hasValue = false,
  });

  final String label;
  final CvMonthYear? initial;
  final bool hasValue;

  @override
  State<MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late int _year = widget.initial?.year ?? DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final initial = widget.initial;

    return Dialog(
      child: SizedBox(
        width: 340,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('CHOISIR UNE DATE', style: textTheme.labelSmall),
              const SizedBox(height: 2),
              Text(widget.label, style: textTheme.titleLarge),
              const SizedBox(height: 14),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadii.control),
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Année précédente',
                      onPressed: () => setState(() => _year--),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        '$_year',
                        key: const Key('month-year-picker-year'),
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Année suivante',
                      onPressed: () => setState(() => _year++),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 2.6,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var month = 1; month <= 12; month++)
                    _MonthButton(
                      label: CvMonthYear.monthLabels[month - 1],
                      selected:
                          initial?.year == _year && initial?.month == month,
                      onPressed: () => Navigator.pop(
                        context,
                        CvMonthYearSelection(CvMonthYear(_year, month)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(
                  context,
                  CvMonthYearSelection(CvMonthYear(_year)),
                ),
                child: Text('Année $_year seule'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (widget.hasValue)
                    TextButton(
                      onPressed: () => Navigator.pop(
                        context,
                        const CvMonthYearSelection(null),
                      ),
                      child: const Text('Effacer'),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);
    const padding = EdgeInsets.zero;

    return selected
        ? FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              padding: padding,
              textStyle: textStyle,
            ),
            child: Text(label),
          )
        : TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              padding: padding,
              textStyle: textStyle,
              foregroundColor: AppColors.onSurface,
              backgroundColor: AppColors.surfaceContainerLow,
            ),
            child: Text(label),
          );
  }
}
