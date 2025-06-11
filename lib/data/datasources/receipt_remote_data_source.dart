import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warehouse_receipt/data/models/receipt.dart';

abstract class ReceiptRemoteDataSource {
  Future<List<Receipt>> getReceipts();
  Future<Receipt?> getReceiptById(String id);
  Future<void> addReceipt(Receipt receipt);
  Future<void> updateReceipt(Receipt receipt);
  Future<void> deleteReceipt(String id);
}

class ReceiptRemoteDataSourceImpl implements ReceiptRemoteDataSource {
  final FirebaseFirestore _firestore;

  ReceiptRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<Receipt>> getReceipts() async {
    final snapshot = await _firestore.collection('receipts').get();
    return snapshot.docs.map((doc) => Receipt.fromJson(doc.data())).toList();
  }

  @override
  Future<Receipt?> getReceiptById(String id) async {
    final doc = await _firestore.collection('receipts').doc(id).get();
    if (!doc.exists) return null;
    return Receipt.fromJson(doc.data()!);
  }

  @override
  Future<void> addReceipt(Receipt receipt) async {
    await _firestore
        .collection('receipts')
        .doc(receipt.id)
        .set(receipt.toJson());
  }

  @override
  Future<void> updateReceipt(Receipt receipt) async {
    await _firestore
        .collection('receipts')
        .doc(receipt.id)
        .update(receipt.toJson());
  }

  @override
  Future<void> deleteReceipt(String id) async {
    await _firestore.collection('receipts').doc(id).delete();
  }
}
