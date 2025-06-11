import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'receipt_item.g.dart';

@JsonSerializable()
class ReceiptItem extends Equatable {
  final String id;
  final int index;
  final String title;
  final String code;
  final String unit;
  final int quantityFromDoc;
  final int quantityActual;
  final double unitPrice;
  final double totalPrice;

  const ReceiptItem({
    required this.id,
    required this.index,
    required this.title,
    required this.code,
    required this.unit,
    required this.quantityFromDoc,
    required this.quantityActual,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) =>
      _$ReceiptItemFromJson(json);
  Map<String, dynamic> toJson() => _$ReceiptItemToJson(this);

  @override
  List<Object?> get props => [
        id,
        index,
        title,
        code,
        unit,
        quantityFromDoc,
        quantityActual,
        unitPrice,
        totalPrice,
      ];
}
