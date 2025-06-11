import 'package:flutter/foundation.dart';
import 'package:warehouse_receipt/data/models/receipt.dart';
import 'package:warehouse_receipt/data/repositories/receipt_repository_impl.dart';

class ReceiptProvider with ChangeNotifier {
  final ReceiptRepositoryImpl _repository;
  List<Receipt> _receipts = [];
  Receipt? _selectedReceipt;
  bool _isLoading = false;
  String? _error;

  ReceiptProvider(this._repository) {
    // Automatically load receipts when provider is created
    loadReceipts();
  }

  List<Receipt> get receipts => _receipts;
  Receipt? get selectedReceipt => _selectedReceipt;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReceipts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _receipts = await _repository.getAllReceipts();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectReceipt(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedReceipt = await _repository.getReceiptById(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReceipt(Receipt receipt) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.addReceipt(receipt);
      await loadReceipts(); // Reload the list
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateReceipt(Receipt receipt) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateReceipt(receipt);
      await loadReceipts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReceipt(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteReceipt(id);
      await loadReceipts(); // Reload the list
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
