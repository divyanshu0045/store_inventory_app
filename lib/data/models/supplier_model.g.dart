// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SupplierModelImpl _$$SupplierModelImplFromJson(Map<String, dynamic> json) =>
    _$SupplierModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      contactName: json['contactName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$$SupplierModelImplToJson(_$SupplierModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'contactName': instance.contactName,
      'email': instance.email,
      'phone': instance.phone,
    };