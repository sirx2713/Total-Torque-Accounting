import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';

class InvoiceListView extends StatefulWidget {
  const InvoiceListView({super.key});

  @override
  State<InvoiceListView> createState() => _InvoiceListViewState();
}

class _InvoiceListViewState extends State<InvoiceListView>
    with AutomaticKeepAliveClientMixin {
  List<FileSystemEntity> _allInvoices = [];
  List<FileSystemEntity> _filteredInvoices = [];
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory
          .listSync()
          .where((file) => file.path.endsWith('.pdf'))
          .toList();
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      setState(() {
        _allInvoices = files;
        _filteredInvoices = files;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading invoices: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterInvoices(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredInvoices = _allInvoices
          .where((file) =>
          file.path.split('/').last.toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  Future<void> _openPdf(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening PDF: $e')),
      );
    }
  }

  Future<void> _deletePdf(String filePath) async {
    try {
      await File(filePath).delete();
      await _loadInvoices();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting invoice: $e')),
      );
    }
  }

  Future<void> _renamePdf(String oldPath) async {
    final oldFile = File(oldPath);
    final oldFileName = oldFile.path.split('/').last;

    // Show a dialog to input the new name
    String newName = oldFileName;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Invoice'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'New Name',
            hintText: 'Enter the new file name',
          ),
          controller: TextEditingController()..text = oldFileName.replaceAll('.pdf', ''),
          onChanged: (value) => newName = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (newName.isNotEmpty && !newName.endsWith('.pdf')) {
                newName = '$newName.pdf';
              }

              // Attempt to rename the file
              try {
                final directory = await getApplicationDocumentsDirectory();
                final newPath = '${directory.path}/$newName';
                await oldFile.rename(newPath);
                await _loadInvoices();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invoice renamed to $newName')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error renaming invoice: $e')),
                );
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  bool get wantKeepAlive => true; // Ensures state persistence

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: _filterInvoices,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search invoices...',
              border: OutlineInputBorder(),
            ),
          ),
        ),

        // Invoice List
        Expanded(
          child: _filteredInvoices.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No invoices found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _loadInvoices,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: _loadInvoices,
            child: ListView.builder(
              itemCount: _filteredInvoices.length,
              itemBuilder: (context, index) {
                final file = File(_filteredInvoices[index].path);
                final fileName = file.path.split('/').last;
                final fileStats = file.statSync();

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(fileName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Created: ${_formatDate(fileStats.modified)}'),
                        Text('Size: ${_formatFileSize(fileStats.size)}'),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'open',
                          child: Row(
                            children: [
                              Icon(Icons.open_in_new),
                              SizedBox(width: 8),
                              Text('Open'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Rename'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'open':
                            _openPdf(file.path);
                            break;
                          case 'rename':
                            _renamePdf(file.path);
                            break;
                          case 'delete':
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Invoice'),
                                content: const Text(
                                    'Are you sure you want to delete this invoice?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deletePdf(file.path);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            break;
                        }
                      },
                    ),
                    onTap: () => _openPdf(file.path),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
