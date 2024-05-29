import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trivia/core/error/exceptions.dart';
import 'package:trivia/core/error/failures.dart';
import 'package:trivia/core/platform/network_info.dart';
import 'package:trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:trivia/features/number_trivia/domain/entities/number_trivia.dart';

@GenerateMocks([NumberTriviaRemoteDataSource, NumberTriviaLocalDataSource, NetworkInfo])
import 'number_trivia_repository_impl_test.mocks.dart';

void main() {
  late MockNumberTriviaRemoteDataSource remoteDataSource;
  late MockNumberTriviaLocalDataSource localDataSource;
  late MockNetworkInfo networkInfo;
  late NumberTriviaRepositoryImpl repository;

  setUp(() {
    networkInfo = MockNetworkInfo();
    localDataSource = MockNumberTriviaLocalDataSource();
    remoteDataSource = MockNumberTriviaRemoteDataSource();

    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
  });

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    const tNumberTriviaModel = NumberTriviaModel(text: 'test trivia', number: tNumber);
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    group('device is online', () {
      setUp(() {
        when(networkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should check if the device is online', () async {
        when(remoteDataSource.getConcreteNumberTrivia(tNumber)).thenAnswer((_) async => tNumberTriviaModel);

        // Configure the mock to return a Future<bool>
        when(networkInfo.isConnected).thenAnswer((_) async => true);

        await repository.getConcreteNumberTrivia(tNumber);

        // Verify that the method has been called
        verify(networkInfo.isConnected);
      });

      test('should return remote data when call to remote data source is successful', () async {
        // Arrange
        when(remoteDataSource.getConcreteNumberTrivia(tNumber)).thenAnswer((_) async => tNumberTriviaModel);
        // Act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // Assert
        verify(remoteDataSource.getConcreteNumberTrivia(tNumber));
        verify(localDataSource.cacheNumberTrivia(tNumberTriviaModel));
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test('should return server failure when call to remote data source is unsuccessful', () async {
        // Arrange
        when(remoteDataSource.getConcreteNumberTrivia(tNumber)).thenThrow(ServerException());
        // Act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // Assert
        verify(remoteDataSource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(localDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(networkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return last locally cached data when the cached data is present', () async {
        // Arrange
        when(localDataSource.getLastNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        // Act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // Assert
        verifyZeroInteractions(remoteDataSource);
        verify(localDataSource.getLastNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test('should return CacheFailure when there is no cached data present', () async {
        // Arrange
        when(localDataSource.getLastNumberTrivia()).thenThrow(CacheException());
        // Act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // Assert
        verifyZeroInteractions(remoteDataSource);
        verify(localDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });
}
