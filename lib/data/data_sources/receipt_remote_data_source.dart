import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warehouse_receipt/data/models/receipt.dart';

abstract class ReceiptRemoteDataSource {
  Future<void> addReceipt(Receipt receipt);
  Future<List<Receipt>> getAllReceipts();
  Future<Receipt?> getReceiptById(String id);
  Future<void> deleteReceipt(String id);
  Future<void> updateReceipt(Receipt receipt);
}

class ReceiptRemoteDataSourceImpl implements ReceiptRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ReceiptRemoteDataSourceImpl();

  @override
  Future<void> addReceipt(Receipt receipt) async {
    await _firestore
        .collection('receipts')
        .doc(receipt.id)
        .set(receipt.toJson());
  }

  @override
  Future<List<Receipt>> getAllReceipts() async {
    final snapshot = await _firestore.collection('receipts').get();
    return snapshot.docs.map((doc) {
      return Receipt.fromJson(doc.data());
    }).toList();
  }

  @override
  Future<Receipt?> getReceiptById(String id) async {
    final doc = await _firestore.collection('receipts').doc(id).get();
    if (doc.exists) {
      return Receipt.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> deleteReceipt(String id) async {
    await _firestore.collection('receipts').doc(id).delete();
  }

  @override
  Future<void> updateReceipt(Receipt receipt) async {
    await _firestore
        .collection('receipts')
        .doc(receipt.id)
        .update(receipt.toJson());
  }
}
