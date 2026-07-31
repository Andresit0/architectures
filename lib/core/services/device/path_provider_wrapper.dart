import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;

abstract interface class IPathProviderWrapper {
  Future<Directory> getTemporaryDirectory();
  Future<Directory> getApplicationDocumentsDirectory();
}

class PathProviderWrapper implements IPathProviderWrapper {
  @override
  Future<Directory> getTemporaryDirectory() =>
      path_provider.getTemporaryDirectory();

  @override
  Future<Directory> getApplicationDocumentsDirectory() =>
      path_provider.getApplicationDocumentsDirectory();
}
