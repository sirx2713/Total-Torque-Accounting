import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:total_torque_accounting/models/EditableInvoice.dart';
import '../services/pdf_service.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:signature/signature.dart';

class PdfFormView extends StatefulWidget {
  final EditableInvoice? editableInvoice; // Optional parameter for editing

  const PdfFormView({super.key, this.editableInvoice});

  @override
  State<PdfFormView> createState() => _PdfFormViewState();
}

class _PdfFormViewState extends State<PdfFormView>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _pdfService = PdfService();
  Uint8List? _signature;

  // Controllers for header information
  final _billToController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _referenceController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime _dueDate = DateTime.now();

  // Controllers for items
  List<InvoiceItem> _items = [];

  // Controllers for payment details
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();

  // Controller for authorized signature name
  final _authorizedNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If editing an existing invoice, pre-fill fields with its data
    if (widget.editableInvoice != null) {
      final invoice = widget.editableInvoice!;
      _billToController.text = invoice.companyName;
      _invoiceNumberController.text = invoice.invoiceNumber;
      _referenceController.text = invoice.reference;
      _selectedDate = invoice.date;
      _dueDate = invoice.dueDate;
      _items = invoice.items.map((item) {
        return InvoiceItem(
          productController: TextEditingController(text: item.product),
          quantityController:
          TextEditingController(text: item.quantity.toString()),
          rateController: TextEditingController(text: item.rate.toString()),
        );
      }).toList();
      _accountNameController.text = invoice.accountName;
      _bankNameController.text = invoice.bankName;
      _accountNumberController.text = invoice.accountNumber;
    } else {
      // Add an initial item for new invoices
      _items.add(InvoiceItem());
      // Set default values for payment details
      _accountNameController.text = 'Misheck T Mukarati';
      _bankNameController.text = 'Nedbank USD';
      _accountNumberController.text = '11990144941';
      // Generate an invoice number for new invoices
      _invoiceNumberController.text =
      'INV${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8)}';
    }
  }

  @override
  void dispose() {
    _billToController.dispose();
    _invoiceNumberController.dispose();
    _referenceController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _authorizedNameController.dispose();
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _showSignatureDialog() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Signature',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SignaturePad(
                onSignatureCapture: (signature) {
                  setState(() {
                    _signature = signature;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateItemAmount(InvoiceItem item) {
    double quantity = double.tryParse(item.quantityController.text) ?? 0;
    double rate = double.tryParse(item.rateController.text) ?? 0;
    return quantity * rate;
  }

  double _calculateTotal() {
    return _items.fold(0, (sum, item) => sum + _calculateItemAmount(item));
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: 'USD ',
      decimalDigits: 2,
    ).format(amount);
  }

  Future<void> _selectDate(BuildContext context, bool isDueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDueDate ? _dueDate : _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        if (isDueDate) {
          _dueDate = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  void _addItem() {
    setState(() {
      _items.add(InvoiceItem());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  @override
  bool get wantKeepAlive => true; // Ensures state persistence

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Invoice Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _billToController,
                      decoration: const InputDecoration(
                        labelText: 'Bill To',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _invoiceNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Invoice No.',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _referenceController,
                            decoration: const InputDecoration(
                              labelText: 'Reference',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                DateFormat('dd MMM yyyy')
                                    .format(_selectedDate),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Due Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                DateFormat('dd MMM yyyy').format(_dueDate),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Items Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Items',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          onPressed: _addItem,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        controller:
                                        _items[index].productController,
                                        decoration: const InputDecoration(
                                          labelText: 'Product',
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) =>
                                        value?.isEmpty ?? true
                                            ? 'Required'
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                        _items[index].quantityController,
                                        decoration: const InputDecoration(
                                          labelText: 'Qty',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        validator: (value) =>
                                        value?.isEmpty ?? true
                                            ? 'Required'
                                            : null,
                                        onChanged: (value) {
                                          setState(() {}); // Update calculations
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                        _items[index].rateController,
                                        decoration: const InputDecoration(
                                          labelText: 'Rate',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.numberWithOptions(
                                            decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*')),
                                        ],
                                        validator: (value) =>
                                        value?.isEmpty ?? true
                                            ? 'Required'
                                            : null,
                                        onChanged: (value) {
                                          setState(() {}); // Update calculations
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: _items.length > 1
                                          ? () => _removeItem(index)
                                          : null,
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Amount: ${_formatCurrency(_calculateItemAmount(_items[index]))}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Details Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accountNameController,
                      decoration: const InputDecoration(
                        labelText: 'Payable To',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bankNameController,
                      decoration: const InputDecoration(
                        labelText: 'Bank Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accountNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Account No',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Total Amount Card
            Card(
              elevation: 4,
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatCurrency(_calculateTotal()),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tax (0%):',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'USD 0.00',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          _formatCurrency(_calculateTotal()),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Signature Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Authorized Signature',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _authorizedNameController,
                      decoration: const InputDecoration(
                        labelText: 'Authorized Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          if (_signature != null)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.memory(
                                _signature!,
                                height: 100,
                              ),
                            )
                          else
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text('No signature added'),
                              ),
                            ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showSignatureDialog,
                            icon: const Icon(Icons.draw),
                            label: const Text('Add Signature'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Generate Invoice Button
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (_signature == null) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Missing Signature'),
                        content: const Text(
                            'Please add your signature before generating the invoice.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  try {
                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );

                    // Prepare invoice items
                    List<Map<String, dynamic>> items = _items.map((item) {
                      return {
                        'product': item.productController.text,
                        'quantity':
                        int.tryParse(item.quantityController.text) ?? 0,
                        'rate': double.tryParse(item.rateController.text) ?? 0,
                        'amount': _calculateItemAmount(item),
                      };
                    }).toList();

                    // Generate PDF
                    final file = await _pdfService.generatePdf(
                      companyName: _billToController.text,
                      invoiceNumber: _invoiceNumberController.text,
                      reference: _referenceController.text,
                      date: _selectedDate,
                      dueDate: _dueDate,
                      items: items,
                      accountName: _accountNameController.text,
                      bankName: _bankNameController.text,
                      accountNumber: _accountNumberController.text,
                      amount: _calculateTotal(),
                      signature: _signature,
                      authorizedName: _authorizedNameController.text,
                    );

                    // Remove loading indicator
                    Navigator.pop(context);

                    // Show success dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Success'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Invoice generated successfully!'),
                              const SizedBox(height: 8),
                              Text('Saved to: ${file.path}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Clear form
                                _formKey.currentState!.reset();
                                _items.clear();
                                _items.add(InvoiceItem());
                                _signature = null;
                                setState(() {});
                              },
                              child: const Text('OK'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await OpenFile.open(file.path);
                              },
                              child: const Text('Open PDF'),
                            ),
                          ],
                        );
                      },
                    );
                  } catch (e) {
                    // Remove loading indicator if showing
                    Navigator.pop(context);

                    // Show error dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: Text('Failed to generate invoice: $e'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else {
                  // Show validation error dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Validation Error'),
                        content: const Text(
                            'Please fill in all required fields.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Generate Invoice',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InvoiceItem {
  final TextEditingController productController;
  final TextEditingController quantityController;
  final TextEditingController rateController;

  InvoiceItem({
    TextEditingController? productController,
    TextEditingController? quantityController,
    TextEditingController? rateController,
  })  : productController = productController ?? TextEditingController(),
        quantityController = quantityController ?? TextEditingController(),
        rateController = rateController ?? TextEditingController();

  void dispose() {
    productController.dispose();
    quantityController.dispose();
    rateController.dispose();
  }
}

class SignaturePad extends StatefulWidget {
  final Function(Uint8List) onSignatureCapture;

  const SignaturePad({
    super.key,
    required this.onSignatureCapture,
  });

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Signature(
            controller: _controller,
            backgroundColor: Colors.white,
            height: 150,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () {
                _controller.clear();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (_controller.isNotEmpty) {
                  final signature = await _controller.toPngBytes();
                  if (signature != null) {
                    widget.onSignatureCapture(signature);
                    Navigator.pop(context);
                  }
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Save Signature'),
            ),
          ],
        ),
      ],
    );
  }
}
