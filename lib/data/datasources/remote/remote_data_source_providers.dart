import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management_app/data/datasources/remote/api_client.dart';
import 'package:inventory_management_app/data/datasources/remote/product_remote_data_source.dart';

// 1. API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// 2. Product Remote Data Source Provider
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRemoteDataSourceImpl(apiClient);
});