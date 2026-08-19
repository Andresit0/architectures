import 'package:clean_architecture_sdd_harness/core/network/dio/i_multipart_file.dart';
import 'package:dio/dio.dart';

abstract interface class IDioMultipartBuilder {
  Future<FormData> build({
    List<Map<String, String>>? fields,
    List<Object?>? fileList,
  });
}

class DioMultipartBuilder implements IDioMultipartBuilder {
  const DioMultipartBuilder();

  @override
  Future<FormData> build({
    List<Map<String, String>>? fields,
    List<Object?>? fileList,
  }) async {
    final formData = FormData();

    if (fields != null && fields.isNotEmpty) {
      if (fileList != null && fields.length == fileList.length) {
        for (var i = 0; i < fileList.length; i++) {
          final file = await _resolveFile(fileList[i]);
          if (file != null) {
            formData.files.add(MapEntry('file', file));
          }
          fields[i].forEach(
            (key, value) => formData.fields.add(MapEntry(key, value)),
          );
        }
      } else {
        for (final map in fields) {
          map.forEach(
            (key, value) => formData.fields.add(MapEntry(key, value)),
          );
        }
        if (fileList != null) {
          for (final f in fileList) {
            final file = await _resolveFile(f);
            if (file != null) {
              formData.files.add(MapEntry('file', file));
            }
          }
        }
      }
    } else if (fileList != null) {
      for (final f in fileList) {
        final file = await _resolveFile(f);
        if (file != null) {
          formData.files.add(MapEntry('file', file));
        }
      }
    }

    return formData;
  }

  Future<MultipartFile?> _resolveFile(Object? item) async {
    if (item is IMultipartFile) {
      return MultipartFile.fromFile(item.filePath, filename: item.fieldName);
    }
    if (item is MultipartFile) {
      return item;
    }
    return null;
  }
}
