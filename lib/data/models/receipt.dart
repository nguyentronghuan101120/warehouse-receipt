import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'receipt_item.dart';

part 'receipt.g.dart';

@JsonSerializable(explicitToJson: true)
class Receipt extends Equatable {
  final String id; // Firestore document ID
  final String unit;
  final String department;
  final int importDate; // millisecondsSinceEpoch
  final String receiptNumber;
  final bool isDebit;

  // Delivery info
  final String deliverName;
  final String followReference;
  final String deliveryNumber;
  final int deliveryDate;
  final String deliveryFrom;
  final String warehouseName;
  final String warehouseLocation;

  // Table items
  @JsonKey(toJson: _itemsToJson, fromJson: _itemsFromJson)
  final List<ReceiptItem> items;

  // Summary
  final double totalAmount;
  final String totalAmountInWords;
  final int numberOfOriginalDocs;

  // Signatures
  final String createdBy;
  final String deliveredBy;
  final String warehouseKeeper;
  final String chiefAccountant;

  const Receipt({
    required this.id,
    required this.unit,
    required this.department,
    required this.importDate,
    required this.receiptNumber,
    required this.isDebit,
    required this.deliverName,
    required this.followReference,
    required this.deliveryNumber,
    required this.deliveryDate,
    required this.deliveryFrom,
    required this.warehouseName,
    required this.warehouseLocation,
    required this.items,
    required this.totalAmount,
    required this.totalAmountInWords,
    required this.numberOfOriginalDocs,
    required this.createdBy,
    required this.deliveredBy,
    required this.warehouseKeeper,
    required this.chiefAccountant,
  });

  static List<Map<String, dynamic>> _itemsToJson(List<ReceiptItem> items) {
    return items.map((item) => item.toJson()).toList();
  }

  static List<ReceiptItem> _itemsFromJson(List<dynamic> json) {
    return json
        .map((item) => ReceiptItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  factory Receipt.fromJson(Map<String, dynamic> json) =>
      _$ReceiptFromJson(json);
  Map<String, dynamic> toJson() => _$ReceiptToJson(this);

  @override
  List<Object?> get props => [
        id,
        unit,
        department,
        importDate,
        receiptNumber,
        isDebit,
        deliverName,
        followReference,
        deliveryNumber,
        deliveryDate,
        deliveryFrom,
        warehouseName,
        warehouseLocation,
        items,
        totalAmount,
        totalAmountInWords,
        numberOfOriginalDocs,
        createdBy,
        deliveredBy,
        warehouseKeeper,
        chiefAccountant,
      ];
}
