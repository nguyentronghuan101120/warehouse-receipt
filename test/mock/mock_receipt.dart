import 'dart:convert';
import 'dart:io';

import 'package:warehouse_receipt/data/models/receipt.dart';

const defaultReceiptId = 'receipt_001';
const secondReceiptId = 'receipt_002';

Receipt sampleReceipt(String id) {
  final mockData = json.decode(
    File('test/mock/mock_receipt.json').readAsStringSync(),
  ) as List<dynamic>;

  final receiptData = mockData.firstWhere(
    (receipt) => receipt['id'] == id,
    orElse: () => mockData.first,
  );

  return Receipt.fromJson(receiptData);
}

final tReceipt = sampleReceipt(defaultReceiptId);
