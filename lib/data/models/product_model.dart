import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String sku,
    String? description,
    String? category,
    String? supplierId,
    String? barcode,
    required int stockQuantity,
    String? location,
    int? minimumStockThreshold,
    double? cost,
    double? sellingPrice,
    List<String>? imageUrls,
    List<String>? documentUrls,
    DateTime? expiryDate,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}