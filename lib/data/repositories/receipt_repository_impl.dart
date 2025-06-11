import 'package:warehouse_receipt/data/data_sources/receipt_remote_data_source.dart';
import 'package:warehouse_receipt/data/models/receipt.dart';

abstract class ReceiptRepository {
  Future<void> addReceipt(Receipt receipt);
  Future<List<Receipt>> getAllReceipts();
  Future<Receipt?> getReceiptById(String id);
  Future<void> deleteReceipt(String id);
  Future<void> updateReceipt(Receipt receipt);
}

class ReceiptRepositoryImpl implements ReceiptRepository {
  final ReceiptRemoteDataSource _remoteDataSource;

  ReceiptRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> addReceipt(Receipt receipt) {
    return _remoteDataSource.addReceipt(receipt);
  }

  @override
  Future<List<Receipt>> getAllReceipts() {
    return _remoteDataSource.getAllReceipts();
  }

  @override
  Future<Receipt?> getReceiptById(String id) {
    return _remoteDataSource.getReceiptById(id);
  }

  @override
  Future<void> deleteReceipt(String id) {
    return _remoteDataSource.deleteReceipt(id);
  }

  @override
  Future<void> updateReceipt(Receipt receipt) async {
    await _remoteDataSource.updateReceipt(receipt);
  }
}
