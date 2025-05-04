import 'package:flutter/foundation.dart';
import 'package:storage_explorer/src/services/sqlite_service.dart';

/// Protocol that defines the interface for the storage explorer controller.
///
/// This protocol defines the contract for managing the state and operations
/// of the SQLite database explorer.
abstract base class StorageExplorerControllerProtocol with ChangeNotifier {
  /// Whether the controller is currently loading data.
  bool get isLoading;

  /// The total number of pages available for the current table.
  int get totalPages;

  /// The current page number being displayed.
  int get currentPage;

  /// The number of items to display per page.
  int get itemsPerPage;

  /// The currently selected table name.
  String get selectedTable;

  /// List of all available tables in the database.
  List<String> get tables;

  /// List of column names for the current table.
  List<String> get columns;

  /// Available options for items per page.
  List<int> get itemsPerPageOptions;

  /// The current page of data rows.
  List<Map<String, dynamic>> get rows;

  /// Initializes the controller and loads initial data.
  void initialize();

  /// Navigates to the next page of data.
  void didTapNextPage();

  /// Navigates to the previous page of data.
  void didTapPreviousPage();

  /// Navigates to the first page of data.
  void didTapFirstPage();

  /// Navigates to the last page of data.
  void didTapLastPage();

  /// Handles table selection changes.
  ///
  /// [tableName] The name of the newly selected table.
  void didSelectTable(String? tableName);

  /// Sets the number of items to display per page.
  ///
  /// [itemsPerPage] The new number of items per page.
  void setItemsPerPage(int itemsPerPage);

  /// Closes the database connection.
  void closeDatabase();
}

/// Implementation of [StorageExplorerControllerProtocol] for managing SQLite database exploration.
final class InspectorController extends StorageExplorerControllerProtocol {
  int _totalItems = 0;
  int _totalPages = 0;
  int _currentPage = 1;
  int _itemsPerPage = 20;
  bool _isLoading = true;
  String _selectedTable = '';
  final List<String> _tables = [];
  final List<String> _columns = [];
  final List<Map<String, dynamic>> _rows = [];
  final List<int> _itemsPerPageOptions = [10, 20, 50];

  /// The path to the SQLite database file.
  final String databasePath;

  /// The SQLite service instance.
  late final SQLiteServiceProtocol sqliteService;

  /// Creates an [InspectorController] instance.
  ///
  /// [databasePath] The path to the SQLite database file.
  InspectorController({
    required this.databasePath,
  }) {
    sqliteService = SQLiteService();
  }

  @override
  bool get isLoading => _isLoading;

  @override
  List<String> get tables => _tables;

  @override
  List<String> get columns => _columns;

  @override
  int get totalPages => _totalPages;

  @override
  int get currentPage => _currentPage;

  @override
  int get itemsPerPage => _itemsPerPage;

  @override
  String get selectedTable => _selectedTable;

  @override
  List<int> get itemsPerPageOptions => _itemsPerPageOptions;

  @override
  List<Map<String, dynamic>> get rows => _rows;

  @override
  Future<void> initialize() async {
    sqliteService.openDatabase(databasePath);
    _tables.addAll(sqliteService.selectTables());
    _selectedTable = _tables.first;
    _getTotalItems();
    _isLoading = false;
    _loadTableData();
  }

  @override
  void didSelectTable(String? tableName) {
    if (tableName == null || tableName == _selectedTable) return;
    _selectedTable = tableName;
    _getTotalItems();
    _loadTableData();
  }

  @override
  void setItemsPerPage(int value) {
    if (_itemsPerPageOptions.contains(value)) {
      _itemsPerPage = value;
      _currentPage = 1;
      _loadTableData();
    }
  }

  @override
  void didTapFirstPage() {
    if (_currentPage > 1) {
      _currentPage = 1;
      _loadTableData();
    }
  }

  @override
  void didTapPreviousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      _loadTableData();
    }
  }

  @override
  void didTapNextPage() {
    if (_currentPage < _totalPages) {
      _currentPage++;
      _loadTableData();
    }
  }

  @override
  void didTapLastPage() {
    if (_currentPage < _totalPages) {
      _currentPage = _totalPages;
      _loadTableData();
    }
  }

  @override
  void closeDatabase() {
    sqliteService.closeDatabase();
  }

  /// Loads the current page of data from the selected table.
  void _loadTableData() {
    final rows = sqliteService.selectTable(
      tableName: _selectedTable,
      offset: (_currentPage - 1) * _itemsPerPage,
      limit: _itemsPerPage,
    );

    if (_rows.isNotEmpty) _rows.clear();
    _rows.addAll(rows);

    if (_columns.isNotEmpty) _columns.clear();

    if (rows.isNotEmpty) {
      _columns.addAll(rows.first.keys);
    } else {
      final columns = sqliteService.selectTableInfo(_selectedTable);
      _columns.addAll(columns);
    }

    notifyListeners();
  }

  /// Updates the total number of items and pages for the current table.
  void _getTotalItems() {
    _totalItems = sqliteService.getTotalItems(_selectedTable);
    _totalPages = (_totalItems / _itemsPerPage).ceil();
  }
}
