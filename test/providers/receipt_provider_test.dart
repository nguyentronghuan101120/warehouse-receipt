import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:warehouse_receipt/data/repositories/receipt_repository_impl.dart';
import 'package:warehouse_receipt/providers/receipt_provider.dart';

import '../mock/mock_receipt.dart';
@GenerateMocks([ReceiptRepositoryImpl])
import 'receipt_provider_test.mocks.dart';

void main() {
  late MockReceiptRepositoryImpl mockRepository;
  late ReceiptProvider provider;

  setUp(() {
    mockRepository = MockReceiptRepositoryImpl();
    when(mockRepository.getAllReceipts()).thenAnswer((_) async => []);
    provider = ReceiptProvider(mockRepository);
  });

  group('ReceiptProvider Tests', () {
    test('initial state should be empty', () {
      expect(provider.receipts, []);
      expect(provider.selectedReceipt, null);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('loadReceipts should update receipts list on success', () async {
      final receipts = [tReceipt];
      when(mockRepository.getAllReceipts()).thenAnswer((_) async => receipts);

      await provider.loadReceipts();

      expect(provider.receipts, receipts);
      expect(provider.isLoading, false);
      expect(provider.error, null);
      verify(mockRepository.getAllReceipts()).called(2);
    });

    test('loadReceipts should handle errors', () async {
      when(mockRepository.getAllReceipts())
          .thenThrow(Exception('Failed to load receipts'));

      await provider.loadReceipts();

      expect(provider.receipts, []);
      expect(provider.isLoading, false);
      expect(provider.error, isNotNull);
      verify(mockRepository.getAllReceipts()).called(2);
    });

    test('selectReceipt should update selectedReceipt on success', () async {
      when(mockRepository.getReceiptById(tReceipt.id))
          .thenAnswer((_) async => tReceipt);

      await provider.selectReceipt(tReceipt.id);

      expect(provider.selectedReceipt, tReceipt);
      expect(provider.isLoading, false);
      expect(provider.error, null);
      verify(mockRepository.getReceiptById(tReceipt.id)).called(1);
    });

    test('selectReceipt should handle errors', () async {
      when(mockRepository.getReceiptById(tReceipt.id))
          .thenThrow(Exception('Failed to get receipt'));

      await provider.selectReceipt(tReceipt.id);

      expect(provider.selectedReceipt, null);
      expect(provider.isLoading, false);
      expect(provider.error, isNotNull);
      verify(mockRepository.getReceiptById(tReceipt.id)).called(1);
    });

    test('addReceipt should add receipt and reload list', () async {
      when(mockRepository.addReceipt(tReceipt)).thenAnswer((_) async {});
      when(mockRepository.getAllReceipts()).thenAnswer((_) async => [tReceipt]);

      await provider.addReceipt(tReceipt);

      expect(provider.receipts, [tReceipt]);
      expect(provider.isLoading, false);
      expect(provider.error, null);
      verify(mockRepository.addReceipt(tReceipt)).called(1);
      verify(mockRepository.getAllReceipts()).called(2);
    });

    test('addReceipt should handle errors', () async {
      when(mockRepository.addReceipt(tReceipt))
          .thenThrow(Exception('Failed to add receipt'));

      await provider.addReceipt(tReceipt);

      expect(provider.receipts, []);
      expect(provider.isLoading, false);
      expect(provider.error, isNotNull);
      verify(mockRepository.addReceipt(tReceipt)).called(1);
      verify(mockRepository.getAllReceipts()).called(1);
    });

    test('updateReceipt should update receipt and reload list', () async {
      when(mockRepository.updateReceipt(tReceipt)).thenAnswer((_) async {});
      when(mockRepository.getAllReceipts()).thenAnswer((_) async => [tReceipt]);

      await provider.updateReceipt(tReceipt);

      expect(provider.receipts, [tReceipt]);
      expect(provider.isLoading, false);
      expect(provider.error, null);
      verify(mockRepository.updateReceipt(tReceipt)).called(1);
      verify(mockRepository.getAllReceipts()).called(2);
    });

    test('updateReceipt should handle errors', () async {
      when(mockRepository.updateReceipt(tReceipt))
          .thenThrow(Exception('Failed to update receipt'));

      await provider.updateReceipt(tReceipt);

      expect(provider.receipts, []);
      expect(provider.isLoading, false);
      expect(provider.error, isNotNull);
      verify(mockRepository.updateReceipt(tReceipt)).called(1);
      verify(mockRepository.getAllReceipts()).called(1);
    });

    test('deleteReceipt should delete receipt and reload list', () async {
      when(mockRepository.deleteReceipt(tReceipt.id)).thenAnswer((_) async {});
      when(mockRepository.getAllReceipts()).thenAnswer((_) async => []);

      await provider.deleteReceipt(tReceipt.id);

      expect(provider.receipts, []);
      expect(provider.isLoading, false);
      expect(provider.error, null);
      verify(mockRepository.deleteReceipt(tReceipt.id)).called(1);
      verify(mockRepository.getAllReceipts()).called(2);
    });

    test('deleteReceipt should handle errors', () async {
      when(mockRepository.deleteReceipt(tReceipt.id))
          .thenThrow(Exception('Failed to delete receipt'));

      await provider.deleteReceipt(tReceipt.id);

      expect(provider.receipts, []);
      expect(provider.isLoading, false);
      expect(provider.error, isNotNull);
      verify(mockRepository.deleteReceipt(tReceipt.id)).called(1);
      verify(mockRepository.getAllReceipts()).called(1);
    });
  });
}
