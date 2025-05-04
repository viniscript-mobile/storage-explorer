import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

/// Protocol that defines the interface for SQLite database operations.
abstract interface class SQLiteServiceProtocol {
  /// Opens a connection to the SQLite database at the specified path.
  ///
  /// Throws an [Exception] if the database file is not found.
  void openDatabase(String databasePath);

  /// Closes the current database connection.
  void closeDatabase();

  /// Retrieves a list of all tables in the database.
  ///
  /// Returns a [List] of table names, excluding system tables.
  List<String> selectTables();

  /// Gets the total number of items in a specified table.
  ///
  /// [tableName] The name of the table to count items from.
  /// Returns the total count of items in the table.
  int getTotalItems(String tableName);

  /// Retrieves a paginated list of items from a specified table.
  ///
  /// [tableName] The name of the table to query.
  /// [offset] The number of items to skip.
  /// [limit] The maximum number of items to return.
  /// Returns a [List] of [Map] objects representing the table rows.
  List<Map<String, dynamic>> selectTable({
    required String tableName,
    required int offset,
    required int limit,
  });

  /// Retrieves a list of column names for a specified table.
  ///
  /// [tableName] The name of the table to retrieve column names from.
  /// Returns a [List] of column names.
  List<String> selectTableInfo(String tableName);
}

/// Implementation of [SQLiteServiceProtocol] for SQLite database operations.
final class SQLiteService implements SQLiteServiceProtocol {
  late final Database _database;

  @override
  Future<void> openDatabase(String databasePath) async {
    if (!File(databasePath).existsSync()) {
      throw Exception('O banco de dados não foi encontrado em: $databasePath');
    }

    _database = sqlite3.open(databasePath, mode: OpenMode.readOnly);
  }

  @override
  void closeDatabase() {
    _database.dispose();
  }

  @override
  List<String> selectTables() {
    final tables = _database.select('''
      SELECT name 
      FROM sqlite_master 
      WHERE type = 'table' 
      AND name NOT LIKE 'sqlite_%' 
      ORDER BY name;
    ''');

    return tables.map((row) => row['name'] as String).toList();
  }

  @override
  List<Map<String, dynamic>> selectTable({
    required String tableName,
    required int offset,
    required int limit,
  }) {
    return _database.select('SELECT * FROM $tableName LIMIT $limit OFFSET $offset;');
  }

  @override
  int getTotalItems(String tableName) {
    final result = _database.select('SELECT COUNT(*) as count FROM $tableName;');
    return result.first['count'] as int;
  }

  @override
  List<String> selectTableInfo(String tableName) {
    return _database.select('PRAGMA table_info($tableName);').map((row) {
      return row['name'] as String;
    }).toList();
  }
}
