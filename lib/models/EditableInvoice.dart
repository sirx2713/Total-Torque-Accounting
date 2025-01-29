class EditableInvoice {
  String companyName;
  String invoiceNumber;
  String reference;
  DateTime date;
  DateTime dueDate;
  List<InvoiceItem> items;
  String accountName;
  String bankName;
  String accountNumber;
  double totalAmount;

  EditableInvoice({
    required this.companyName,
    required this.invoiceNumber,
    required this.reference,
    required this.date,
    required this.dueDate,
    required this.items,
    required this.accountName,
    required this.bankName,
    required this.accountNumber,
    required this.totalAmount,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'invoiceNumber': invoiceNumber,
      'reference': reference,
      'date': date.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'accountName': accountName,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'totalAmount': totalAmount,
    };
  }

  // Create from JSON
  factory EditableInvoice.fromJson(Map<String, dynamic> json) {
    return EditableInvoice(
      companyName: json['companyName'],
      invoiceNumber: json['invoiceNumber'],
      reference: json['reference'],
      date: DateTime.parse(json['date']),
      dueDate: DateTime.parse(json['dueDate']),
      items: (json['items'] as List)
          .map((item) => InvoiceItem.fromJson(item))
          .toList(),
      accountName: json['accountName'],
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      totalAmount: json['totalAmount'],
    );
  }
}

class InvoiceItem {
  String product;
  int quantity;
  double rate;
  double amount;

  InvoiceItem({
    required this.product,
    required this.quantity,
    required this.rate,
    required this.amount,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
    };
  }

  // Create from JSON
  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      product: json['product'],
      quantity: json['quantity'],
      rate: json['rate'],
      amount: json['amount'],
    );
  }
}
