import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/domain/repositories/product_repository.dart';
import 'package:inventory_management_app/domain/usecases/get_product_count.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late GetProductCount usecase;
  late MockProductRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockProductRepository();
    usecase = GetProductCount(mockProductRepository);
  });

  const tProductCount = 10;

  test(
    'should get product count from the repository',
    () async {
      // arrange
      when(() => mockProductRepository.getProductCount())
          .thenAnswer((_) async => tProductCount);
      // act
      final result = await usecase();
      // assert
      expect(result, tProductCount);
      verify(() => mockProductRepository.getProductCount());
      verifyNoMoreInteractions(mockProductRepository);
    },
  );
}