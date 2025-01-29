import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:total_torque_accounting/models/EditableInvoice.dart';

class EditableInvoiceStorage {
  static const String _storageKey = 'editable_invoices';

  // Save the list of invoices
  static Future<void> saveInvoices(List<EditableInvoice> invoices) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
    jsonEncode(invoices.map((invoice) => invoice.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  // Retrieve the list of invoices
  static Future<List<EditableInvoice>> loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => EditableInvoice.fromJson(json)).toList();
  }

  // Delete a specific invoice
  static Future<void> deleteInvoice(String invoiceNumber) async {
    final invoices = await loadInvoices();
    final updatedInvoices =
    invoices.where((invoice) => invoice.invoiceNumber != invoiceNumber).toList();
    await saveInvoices(updatedInvoices);
  }
}
