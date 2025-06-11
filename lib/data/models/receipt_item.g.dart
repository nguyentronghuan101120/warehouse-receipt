// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiptItem _$ReceiptItemFromJson(Map<String, dynamic> json) => ReceiptItem(
      id: json['id'] as String,
      index: (json['index'] as num).toInt(),
      title: json['title'] as String,
      code: json['code'] as String,
      unit: json['unit'] as String,
      quantityFromDoc: (json['quantityFromDoc'] as num).toInt(),
      quantityActual: (json['quantityActual'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );

Map<String, dynamic> _$ReceiptItemToJson(ReceiptItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'index': instance.index,
      'title': instance.title,
      'code': instance.code,
      'unit': instance.unit,
      'quantityFromDoc': instance.quantityFromDoc,
      'quantityActual': instance.quantityActual,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
    };
