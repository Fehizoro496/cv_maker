import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/design/cv_template.dart';
import '../../domain/design/template_file.dart';

typedef ReadTemplateFile = Future<String?> Function();
typedef WriteTemplateFile = Future<bool> Function(CvTemplate template);

final readTemplateFileProvider = Provider<ReadTemplateFile>(
  (ref) => readTemplateFile,
);
final writeTemplateFileProvider = Provider<WriteTemplateFile>(
  (ref) => writeTemplateFile,
);

const _jsonType = XTypeGroup(
  label: 'Template CV (JSON)',
  extensions: ['json'],
  mimeTypes: ['application/json'],
  uniformTypeIdentifiers: ['public.json'],
);

Future<String?> readTemplateFile() async {
  final file = await openFile(acceptedTypeGroups: [_jsonType]);
  if (file == null) return null;
  if (await file.length() > TemplateFile.maxBytes) {
    throw const FormatException('Fichier trop volumineux (maximum 1 Mo).');
  }
  return file.readAsString();
}

Future<bool> writeTemplateFile(CvTemplate template) async {
  final name = '${template.id}.cv-template.json';
  final file = XFile.fromData(
    Uint8List.fromList(utf8.encode(TemplateFile.encode(template))),
    mimeType: 'application/json',
    name: name,
  );
  if (kIsWeb) {
    await file.saveTo(name);
    return true;
  }
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    throw UnsupportedError(
      'L’export de templates est disponible sur ordinateur et sur le Web.',
    );
  }
  final location = await getSaveLocation(
    suggestedName: name,
    acceptedTypeGroups: [_jsonType],
  );
  if (location == null) return false;
  await file.saveTo(location.path);
  return true;
}
