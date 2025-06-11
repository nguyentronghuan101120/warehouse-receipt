// receipt_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:warehouse_receipt/data/data_sources/receipt_remote_data_source.dart';
import 'package:warehouse_receipt/data/repositories/receipt_repository_impl.dart';

import '../../mock/mock_receipt.dart';

@GenerateNiceMocks([MockSpec<ReceiptRemoteDataSource>()])
import 'receipt_repository_impl_test.mocks.dart';

void main() {
  late MockReceiptRemoteDataSource mockRemote;
  late ReceiptRepositoryImpl repository;

  setUp(() {
    mockRemote = MockReceiptRemoteDataSource();
    repository = ReceiptRepositoryImpl(mockRemote);
  });

  final tReceiptList = [tReceipt];

  group('ReceiptRepositoryImpl', () {
    test('addReceipt: should call remoteDataSource.addReceipt', () async {
      when(mockRemote.addReceipt(tReceipt)).thenAnswer((_) => Future.value());
      await repository.addReceipt(tReceipt);
      verify(mockRemote.addReceipt(tReceipt)).called(1);
      verifyNoMoreInteractions(mockRemote);
    });

    test('getAllReceipts: should return list from remote', () async {
      when(mockRemote.getAllReceipts()).thenAnswer((_) async => tReceiptList);
      final result = await repository.getAllReceipts();
      verify(mockRemote.getAllReceipts()).called(1);
      expect(result, equals(tReceiptList));
    });

    test('getReceiptById: forward to remoteDataSource', () async {
      when(mockRemote.getReceiptById('1')).thenAnswer((_) async => tReceipt);
      final res = await repository.getReceiptById('1');
      verify(mockRemote.getReceiptById('1')).called(1);
      expect(res, equals(tReceipt));
    });

    test('deleteReceipt: forward and complete', () async {
      when(mockRemote.deleteReceipt('1')).thenAnswer((_) async {});
      await repository.deleteReceipt('1');
      verify(mockRemote.deleteReceipt('1')).called(1);
    });

    test('updateReceipt: forward to remoteDataSource', () async {
      when(mockRemote.updateReceipt(tReceipt)).thenAnswer((_) async {});
      await repository.updateReceipt(tReceipt);
      verify(mockRemote.updateReceipt(tReceipt)).called(1);
    });
  });
}
