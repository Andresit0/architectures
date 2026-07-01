part of '_function.lib.dart';

abstract class ICpPathProvider {
  Future<Directory> getTemporaryDirectory();
  Future<Directory> getApplicationDocumentsDirectory();
}

class CpPathProvider implements ICpPathProvider {
  @override
  Future<Directory> getTemporaryDirectory() =>
      path_provider.getTemporaryDirectory();

  @override
  Future<Directory> getApplicationDocumentsDirectory() =>
      path_provider.getApplicationDocumentsDirectory();
}
