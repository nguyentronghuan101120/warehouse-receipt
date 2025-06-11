// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Receipt _$ReceiptFromJson(Map<String, dynamic> json) => Receipt(
      id: json['id'] as String,
      unit: json['unit'] as String,
      department: json['department'] as String,
      importDate: (json['importDate'] as num).toInt(),
      receiptNumber: json['receiptNumber'] as String,
      isDebit: json['isDebit'] as bool,
      deliverName: json['deliverName'] as String,
      followReference: json['followReference'] as String,
      deliveryNumber: json['deliveryNumber'] as String,
      deliveryDate: (json['deliveryDate'] as num).toInt(),
      deliveryFrom: json['deliveryFrom'] as String,
      warehouseName: json['warehouseName'] as String,
      warehouseLocation: json['warehouseLocation'] as String,
      items: Receipt._itemsFromJson(json['items'] as List),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      totalAmountInWords: json['totalAmountInWords'] as String,
      numberOfOriginalDocs: (json['numberOfOriginalDocs'] as num).toInt(),
      createdBy: json['createdBy'] as String,
      deliveredBy: json['deliveredBy'] as String,
      warehouseKeeper: json['warehouseKeeper'] as String,
      chiefAccountant: json['chiefAccountant'] as String,
    );

Map<String, dynamic> _$ReceiptToJson(Receipt instance) => <String, dynamic>{
      'id': instance.id,
      'unit': instance.unit,
      'department': instance.department,
      'importDate': instance.importDate,
      'receiptNumber': instance.receiptNumber,
      'isDebit': instance.isDebit,
      'deliverName': instance.deliverName,
      'followReference': instance.followReference,
      'deliveryNumber': instance.deliveryNumber,
      'deliveryDate': instance.deliveryDate,
      'deliveryFrom': instance.deliveryFrom,
      'warehouseName': instance.warehouseName,
      'warehouseLocation': instance.warehouseLocation,
      'items': Receipt._itemsToJson(instance.items),
      'totalAmount': instance.totalAmount,
      'totalAmountInWords': instance.totalAmountInWords,
      'numberOfOriginalDocs': instance.numberOfOriginalDocs,
      'createdBy': instance.createdBy,
      'deliveredBy': instance.deliveredBy,
      'warehouseKeeper': instance.warehouseKeeper,
      'chiefAccountant': instance.chiefAccountant,
    };
