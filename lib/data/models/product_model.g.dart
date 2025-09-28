// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductModelImpl _$$ProductModelImplFromJson(Map<String, dynamic> json) =>
    _$ProductModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      supplierId: json['supplierId'] as String?,
      barcode: json['barcode'] as String?,
      stockQuantity: json['stockQuantity'] as int,
      location: json['location'] as String?,
      minimumStockThreshold: json['minimumStockThreshold'] as int?,
      cost: (json['cost'] as num?)?.toDouble(),
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble(),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      documentUrls: (json['documentUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
    );

Map<String, dynamic> _$$ProductModelImplToJson(_$ProductModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sku': instance.sku,
      'description': instance.description,
      'category': instance.category,
      'supplierId': instance.supplierId,
      'barcode': instance.barcode,
      'stockQuantity': instance.stockQuantity,
      'location': instance.location,
      'minimumStockThreshold': instance.minimumStockThreshold,
      'cost': instance.cost,
      'sellingPrice': instance.sellingPrice,
      'imageUrls': instance.imageUrls,
      'documentUrls': instance.documentUrls,
      'expiryDate': instance.expiryDate?.toIso8601String(),
    };