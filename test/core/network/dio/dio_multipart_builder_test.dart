import 'dart:io';

import 'package:clean_architecture_sdd_harness/core/network/dio/dio_multipart_builder.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/i_multipart_file.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestMultipartFile implements IMultipartFile {
  const _TestMultipartFile({required this.fieldName, required this.filePath});

  @override
  final String fieldName;

  @override
  final String filePath;
}

void main() {
  late IDioMultipartBuilder builder;

  setUp(() {
    builder = const DioMultipartBuilder();
  });

  group('build', () {
    test('empty fields and files produces empty FormData', () async {
      final formData = await builder.build();

      expect(formData.fields, isEmpty);
      expect(formData.files, isEmpty);
    });

    test('fields without files attaches all fields', () async {
      final formData = await builder.build(
        fields: [
          {'key1': 'value1'},
          {'key2': 'value2'},
        ],
      );

      expect(formData.fields.length, 2);
      expect(formData.files, isEmpty);
      expect(formData.fields[0].value, 'value1');
      expect(formData.fields[1].value, 'value2');
    });

    test(
      'files without fields attaches all files (use MultipartFile)',
      () async {
        final file1 = MultipartFile.fromBytes([1, 2, 3], filename: 'a.txt');
        final file2 = MultipartFile.fromBytes([4, 5, 6], filename: 'b.txt');
        final formData = await builder.build(fileList: [file1, file2]);

        expect(formData.fields, isEmpty);
        expect(formData.files.length, 2);
        expect(formData.files[0].value.filename, 'a.txt');
        expect(formData.files[1].value.filename, 'b.txt');
      },
    );

    test('files without fields attaches files (use IMultipartFile)', () async {
      final tempDir = Directory.systemTemp.createTempSync('test_');
      final tempFile = File('${tempDir.path}/test.txt');
      await tempFile.writeAsString('hello');

      final mpFile = _TestMultipartFile(
        fieldName: 'testfile',
        filePath: tempFile.path,
      );
      final formData = await builder.build(fileList: [mpFile]);

      expect(formData.fields, isEmpty);
      expect(formData.files.length, 1);
      expect(formData.files[0].value.filename, 'testfile');
      expect(formData.files[0].value.length, greaterThan(0));

      await tempDir.delete(recursive: true);
    });

    test('paired fields+files attaches both per index', () async {
      final file1 = MultipartFile.fromBytes([1, 2, 3], filename: 'a.txt');
      final file2 = MultipartFile.fromBytes([4, 5, 6], filename: 'b.txt');
      final formData = await builder.build(
        fields: [
          {'key1': 'value1'},
          {'key2': 'value2'},
        ],
        fileList: [file1, file2],
      );

      expect(formData.fields.length, 2);
      expect(formData.files.length, 2);
      expect(formData.fields[0].value, 'value1');
      expect(formData.files[0].value.filename, 'a.txt');
      expect(formData.fields[1].value, 'value2');
      expect(formData.files[1].value.filename, 'b.txt');
    });

    test(
      'unpaired (fields length != fileList length) adds all fields first then files',
      () async {
        final file1 = MultipartFile.fromBytes([1, 2, 3], filename: 'a.txt');
        final formData = await builder.build(
          fields: [
            {'key1': 'value1'},
            {'key2': 'value2'},
          ],
          fileList: [file1],
        );

        expect(formData.fields.length, 2);
        expect(formData.files.length, 1);
        expect(formData.fields[0].value, 'value1');
        expect(formData.fields[1].value, 'value2');
        expect(formData.files[0].value.filename, 'a.txt');
      },
    );

    test('null fields with files attaches all files', () async {
      final file1 = MultipartFile.fromBytes([1, 2, 3], filename: 'a.txt');
      final formData = await builder.build(fileList: [file1]);

      expect(formData.fields, isEmpty);
      expect(formData.files.length, 1);
      expect(formData.files[0].value.filename, 'a.txt');
    });

    test('fields with null fileList attaches only fields', () async {
      final formData = await builder.build(
        fields: [
          {'key': 'value'},
        ],
      );

      expect(formData.fields.length, 1);
      expect(formData.files, isEmpty);
    });
  });
}
