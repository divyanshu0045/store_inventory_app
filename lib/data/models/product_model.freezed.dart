// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) {
  return _ProductModel.fromJson(json);
}

/// @nodoc
mixin _$ProductModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get sku => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get supplierId => throw _privateConstructorUsedError;
  String? get barcode => throw _privateConstructorUsedError;
  int get stockQuantity => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  int? get minimumStockThreshold => throw _privateConstructorUsedError;
  double? get cost => throw _privateConstructorUsedError;
  double? get sellingPrice => throw _privateConstructorUsedError;
  List<String>? get imageUrls => throw _privateConstructorUsedError;
  List<String>? get documentUrls => throw _privateConstructorUsedError;
  DateTime? get expiryDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProductModelCopyWith<ProductModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductModelCopyWith<$Res> {
  factory $ProductModelCopyWith(
          ProductModel value, $Res Function(ProductModel) then) =
      _$ProductModelCopyWithImpl<$Res, ProductModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String sku,
      String? description,
      String? category,
      String? supplierId,
      String? barcode,
      int stockQuantity,
      String? location,
      int? minimumStockThreshold,
      double? cost,
      double? sellingPrice,
      List<String>? imageUrls,
      List<String>? documentUrls,
      DateTime? expiryDate});
}

/// @nodoc
class _$ProductModelCopyWithImpl<$Res, $Val extends ProductModel>
    implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sku = null,
    Object? description = freezed,
    Object? category = freezed,
    Object? supplierId = freezed,
    Object? barcode = freezed,
    Object? stockQuantity = null,
    Object? location = freezed,
    Object? minimumStockThreshold = freezed,
    Object? cost = freezed,
    Object? sellingPrice = freezed,
    Object? imageUrls = freezed,
    Object? documentUrls = freezed,
    Object? expiryDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierId: freezed == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      stockQuantity: null == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      minimumStockThreshold: freezed == minimumStockThreshold
          ? _value.minimumStockThreshold
          : minimumStockThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      sellingPrice: freezed == sellingPrice
          ? _value.sellingPrice
          : sellingPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      imageUrls: freezed == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      documentUrls: freezed == documentUrls
          ? _value.documentUrls
          : documentUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductModelImplCopyWith<$Res>
    implements $ProductModelCopyWith<$Res> {
  factory _$$ProductModelImplCopyWith(
          _$ProductModelImpl value, $Res Function(_$ProductModelImpl) then) =
      __$$ProductModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String sku,
      String? description,
      String? category,
      String? supplierId,
      String? barcode,
      int stockQuantity,
      String? location,
      int? minimumStockThreshold,
      double? cost,
      double? sellingPrice,
      List<String>? imageUrls,
      List<String>? documentUrls,
      DateTime? expiryDate});
}

/// @nodoc
class __$$ProductModelImplCopyWithImpl<$Res>
    extends _$ProductModelCopyWithImpl<$Res, _$ProductModelImpl>
    implements _$$ProductModelImplCopyWith<$Res> {
  __$$ProductModelImplCopyWithImpl(
      _$ProductModelImpl _value, $Res Function(_$ProductModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sku = null,
    Object? description = freezed,
    Object? category = freezed,
    Object? supplierId = freezed,
    Object? barcode = freezed,
    Object? stockQuantity = null,
    Object? location = freezed,
    Object? minimumStockThreshold = freezed,
    Object? cost = freezed,
    Object? sellingPrice = freezed,
    Object? imageUrls = freezed,
    Object? documentUrls = freezed,
    Object? expiryDate = freezed,
  }) {
    return _then(_$ProductModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierId: freezed == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      stockQuantity: null == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      minimumStockThreshold: freezed == minimumStockThreshold
          ? _value.minimumStockThreshold
          : minimumStockThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      sellingPrice: freezed == sellingPrice
          ? _value.sellingPrice
          : sellingPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      imageUrls: freezed == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      documentUrls: freezed == documentUrls
          ? _value._documentUrls
          : documentUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductModelImpl implements _ProductModel {
  const _$ProductModelImpl(
      {required this.id,
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
      final List<String>? imageUrls,
      final List<String>? documentUrls,
      this.expiryDate})
      : _imageUrls = imageUrls,
        _documentUrls = documentUrls;

  factory _$ProductModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String sku;
  @override
  final String? description;
  @override
  final String? category;
  @override
  final String? supplierId;
  @override
  final String? barcode;
  @override
  final int stockQuantity;
  @override
  final String? location;
  @override
  final int? minimumStockThreshold;
  @override
  final double? cost;
  @override
  final double? sellingPrice;
  final List<String>? _imageUrls;
  @override
  List<String>? get imageUrls {
    final value = _imageUrls;
    if (value == null) return null;
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _documentUrls;
  @override
  List<String>? get documentUrls {
    final value = _documentUrls;
    if (value == null) return null;
    if (_documentUrls is EqualUnmodifiableListView) return _documentUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? expiryDate;

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, sku: $sku, description: $description, category: $category, supplierId: $supplierId, barcode: $barcode, stockQuantity: $stockQuantity, location: $location, minimumStockThreshold: $minimumStockThreshold, cost: $cost, sellingPrice: $sellingPrice, imageUrls: $imageUrls, documentUrls: $documentUrls, expiryDate: $expiryDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.minimumStockThreshold, minimumStockThreshold) ||
                other.minimumStockThreshold == minimumStockThreshold) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.sellingPrice, sellingPrice) ||
                other.sellingPrice == sellingPrice) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls) &&
            const DeepCollectionEquality()
                .equals(other._documentUrls, _documentUrls) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      sku,
      description,
      category,
      supplierId,
      barcode,
      stockQuantity,
      location,
      minimumStockThreshold,
      cost,
      sellingPrice,
      const DeepCollectionEquality().hash(_imageUrls),
      const DeepCollectionEquality().hash(_documentUrls),
      expiryDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      __$$ProductModelImplCopyWithImpl<_$ProductModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductModelImplToJson(
      this,
    );
  }
}

abstract class _ProductModel implements ProductModel {
  const factory _ProductModel(
      {required final String id,
      required final String name,
      required final String sku,
      final String? description,
      final String? category,
      final String? supplierId,
      final String? barcode,
      required final int stockQuantity,
      final String? location,
      final int? minimumStockThreshold,
      final double? cost,
      final double? sellingPrice,
      final List<String>? imageUrls,
      final List<String>? documentUrls,
      final DateTime? expiryDate}) = _$ProductModelImpl;

  factory _ProductModel.fromJson(Map<String, dynamic> json) =
      _$ProductModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get sku;
  @override
  String? get description;
  @override
  String? get category;
  @override
  String? get supplierId;
  @override
  String? get barcode;
  @override
  int get stockQuantity;
  @override
  String? get location;
  @override
  int? get minimumStockThreshold;
  @override
  double? get cost;
  @override
  double? get sellingPrice;
  @override
  List<String>? get imageUrls;
  @override
  List<String>? get documentUrls;
  @override
  DateTime? get expiryDate;
  @override
  @JsonKey(ignore: true)
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}