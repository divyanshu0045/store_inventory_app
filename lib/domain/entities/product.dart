class Product {
  final String id;
  final String name;
  final String sku;
  final String? description;
  final String? category;
  final String? supplierId;
  final String? barcode;
  final int stockQuantity;
  final String? location;
  final int? minimumStockThreshold;
  final double? cost;
  final double? sellingPrice;
  final List<String>? imageUrls;
  final List<String>? documentUrls;
  final DateTime? expiryDate;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    this.description,
    this.category,
    this.supplierId,
    this.barcode,
    required this.stockQuantity,
    this.location,
    this.minimumStockThreshold,
    this.cost,
    this.sellingPrice,
    this.imageUrls,
    this.documentUrls,
    this.expiryDate,
  });
}