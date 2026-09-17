/// Built-in layouts rendered locally with the bundled fonts.
enum CvDesign {
  professional('Professionnel'),
  modern('Moderne'),
  minimal('Minimaliste');

  const CvDesign(this.label);
  final String label;
}
