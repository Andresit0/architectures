abstract interface class IAppDatabase {
  Future<IDatabaseHandle> get database;
  Future<void> resetDatabase();
}

abstract interface class IDatabaseHandle {
  Future<List<Map<String, Object?>>> findAll(String store);

  Future<void> replaceAll(
    String store,
    Map<String, Map<String, Object?>> records,
  );

  Future<void> deleteAll(String store);
}
