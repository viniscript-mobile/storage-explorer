import 'package:flutter/material.dart';
import 'package:storage_explorer/src/storage_explorer_controller.dart';

/// A widget that displays a user interface for exploring SQLite database contents.
///
/// This widget provides a table view of database contents with pagination,
/// table selection, and items per page configuration.
class StorageExplorerView extends StatefulWidget {
  /// The path to the SQLite database file.
  final String databasePath;

  /// Creates a [StorageExplorerView] instance.
  ///
  /// [databasePath] The path to the SQLite database file.
  const StorageExplorerView({super.key, required this.databasePath});

  @override
  State<StorageExplorerView> createState() => _StorageExplorerViewState();
}

/// The state class for [StorageExplorerView].
class _StorageExplorerViewState extends State<StorageExplorerView> {
  late final StorageExplorerControllerProtocol viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = InspectorController(databasePath: widget.databasePath);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.initialize();
    });
  }

  @override
  void dispose() {
    viewModel.closeDatabase();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Storage Explorer'),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Tables available',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: viewModel.selectedTable,
                    hint: const Text('Select a table'),
                    items: viewModel.tables.map((table) {
                      return DropdownMenuItem<String>(value: table, child: Text(table));
                    }).toList(),
                    onChanged: viewModel.didSelectTable,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Items per page:'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: viewModel.itemsPerPage,
                    items: viewModel.itemsPerPageOptions.map((value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        viewModel.setItemsPerPage(value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: viewModel.currentPage > 1 ? viewModel.didTapFirstPage : null,
                    icon: const Icon(Icons.first_page),
                  ),
                  IconButton(
                    onPressed: viewModel.currentPage > 1 ? viewModel.didTapPreviousPage : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    onPressed: viewModel.currentPage < viewModel.totalPages ? viewModel.didTapNextPage : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                  IconButton(
                    onPressed: viewModel.currentPage < viewModel.totalPages ? viewModel.didTapLastPage : null,
                    icon: const Icon(Icons.last_page),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: DataTable(
                      columnSpacing: 24,
                      border: TableBorder.all(color: Colors.grey),
                      headingRowColor: WidgetStatePropertyAll(Colors.grey.shade400),
                      dataRowColor: const WidgetStatePropertyAll(Colors.white),
                      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                      columns: List.generate(
                        viewModel.columns.length,
                        (index) => DataColumn(
                          label: Text(
                            viewModel.columns[index],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      rows: List.generate(
                        viewModel.rows.length,
                        (rowIndex) {
                          final row = viewModel.rows[rowIndex];
                          return DataRow(
                            cells: List.generate(
                              viewModel.columns.length,
                              (colIndex) {
                                final column = viewModel.columns[colIndex];
                                return DataCell(
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 200,
                                    ),
                                    child: Text(
                                      '${row[column]}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
