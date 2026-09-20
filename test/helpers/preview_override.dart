import 'dart:typed_data';
import 'package:cv_maker/features/cv/presentation/preview/draft_preview_provider.dart';

final previewOverride = draftPreviewProvider.overrideWith(
  (ref) async => DraftPreview(Uint8List(0), []),
);
