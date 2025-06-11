import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:warehouse_receipt/data/data_sources/receipt_remote_data_source.dart';
import 'package:warehouse_receipt/data/models/receipt.dart';

import '../../mock/mock_receipt.dart';

void main() {
  late FakeFirebaseFirestore fakeFs;
  late ReceiptRemoteDataSourceImpl dataSource;
  final String defaultReceiptId = 'receipt_001';
  final String secondReceiptId = 'receipt_002';

  setUp(() {
    fakeFs = FakeFirebaseFirestore();
    dataSource = ReceiptRemoteDataSourceImpl(firestore: fakeFs);
  });

  group('addReceipt', () {
    test('should add a document in Firestore', () async {
      await dataSource.addReceipt(tReceipt);
      final snapshot =
          await fakeFs.collection('receipts').doc(defaultReceiptId).get();
      expect(snapshot.exists, true);
      expect(Receipt.fromJson(snapshot.data()!), tReceipt);
    });
  });

  group('getAllReceipts', () {
    test('should retrieve list of receipts', () async {
      await fakeFs.collection('receipts').add(tReceipt.toJson());
      await fakeFs
          .collection('receipts')
          .add(sampleReceipt(secondReceiptId).toJson());

      final list = await dataSource.getAllReceipts();
      expect(list.length, 2);
      expect(list.any((r) => r.id == defaultReceiptId), true);
      expect(list.any((r) => r.id == secondReceiptId), true);
    });
  });

  group('getReceiptById', () {
    test('existing id should return Receipt', () async {
      await fakeFs
          .collection('receipts')
          .doc(defaultReceiptId)
          .set(tReceipt.toJson());
      final receipt = await dataSource.getReceiptById(defaultReceiptId);
      expect(receipt, isNotNull);
      expect(receipt, tReceipt);
    });

    test('non-existing id should return null', () async {
      final receipt = await dataSource.getReceiptById('nope');
      expect(receipt, isNull);
    });
  });

  group('deleteReceipt', () {
    test('should delete existing doc', () async {
      await fakeFs
          .collection('receipts')
          .doc(defaultReceiptId)
          .set(tReceipt.toJson());
      await dataSource.deleteReceipt(defaultReceiptId);
      final doc =
          await fakeFs.collection('receipts').doc(defaultReceiptId).get();
      expect(doc.exists, false);
    });
  });

  group('updateReceipt', () {
    test('should update existing doc', () async {
      await fakeFs
          .collection('receipts')
          .doc(defaultReceiptId)
          .set(tReceipt.toJson());
      final updated = Receipt(
        id: tReceipt.id,
        unit: 'Updated Unit',
        department: tReceipt.department,
        importDate: tReceipt.importDate,
        receiptNumber: tReceipt.receiptNumber,
        isDebit: tReceipt.isDebit,
        deliverName: tReceipt.deliverName,
        followReference: tReceipt.followReference,
        warehouseName: tReceipt.warehouseName,
        warehouseLocation: tReceipt.warehouseLocation,
        items: tReceipt.items,
        totalAmount: tReceipt.totalAmount,
        deliveryNumber: tReceipt.deliveryNumber,
        deliveryDate: tReceipt.deliveryDate,
        deliveryFrom: tReceipt.deliveryFrom,
        createdBy: tReceipt.createdBy,
        numberOfOriginalDocs: tReceipt.numberOfOriginalDocs,
        totalAmountInWords: tReceipt.totalAmountInWords,
        warehouseKeeper: tReceipt.warehouseKeeper,
        chiefAccountant: tReceipt.chiefAccountant,
        deliveredBy: tReceipt.deliveredBy,
      );
      await dataSource.updateReceipt(updated);
      final doc =
          await fakeFs.collection('receipts').doc(defaultReceiptId).get();
      expect(Receipt.fromJson(doc.data()!), updated);
    });

    test('update non-existing doc throws', () async {
      final non = sampleReceipt('nope');
      expect(() => dataSource.updateReceipt(non),
          throwsA(isA<FirebaseException>()));
    });
  });
}
