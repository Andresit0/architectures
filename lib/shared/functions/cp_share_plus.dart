part of '_function.lib.dart';

abstract class ICpSharePlus {
  Future<void> shareFile({
    required List<int> bytes,
    required String fileName,
    String mimeType = 'application/octet-stream',
    String? subject,
  });
}

class CpSharePlus implements ICpSharePlus {
  @override
  Future<void> shareFile({
    required List<int> bytes,
    required String fileName,
    String mimeType = 'application/octet-stream',
    String? subject,
  }) async {
    final dir = await CustomFunction.pathProvider.getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    try {
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: mimeType, name: fileName)],
          subject: subject,
        ),
      );
    } finally {
      try {
        await file.delete();
      } catch (_) {}
    }
  }
}
