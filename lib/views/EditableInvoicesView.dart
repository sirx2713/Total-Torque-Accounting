import 'package:flutter/material.dart';
import 'package:total_torque_accounting/models/EditableInvoice.dart';
import 'package:total_torque_accounting/models/EditableInvoiceStorage.dart';
import 'pdf_form_view.dart';

class EditableInvoicesView extends StatefulWidget {
  const EditableInvoicesView({super.key});

  @override
  State<EditableInvoicesView> createState() => _EditableInvoicesViewState();
}

class _EditableInvoicesViewState extends State<EditableInvoicesView>
    with AutomaticKeepAliveClientMixin {
  List<EditableInvoice> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true); // Show loading spinner
    try {
      _invoices = await EditableInvoiceStorage.loadInvoices(); // Load saved invoices
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading invoices: $e')),
      );
    } finally {
      setState(() => _isLoading = false); // Hide loading spinner
    }
  }

  Future<void> _deleteInvoice(String invoiceNumber) async {
    try {
      await EditableInvoiceStorage.deleteInvoice(invoiceNumber); // Remove the invoice
      await _loadInvoices(); // Reload the list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting invoice: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_invoices.isEmpty) {
      return const Center(
        child: Text(
          'No editable invoices found.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _invoices.length,
      itemBuilder: (context, index) {
        final invoice = _invoices[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(invoice.companyName),
            subtitle: Text('Invoice No: ${invoice.invoiceNumber}\n'
                'Total: ${invoice.totalAmount.toStringAsFixed(2)}'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Edit'),
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
                  case 'edit':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfFormView(
                          editableInvoice: invoice,
                        ),
                      ),
                    );
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
                              _deleteInvoice(invoice.invoiceNumber);
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
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true; // Ensures state persistence
}
