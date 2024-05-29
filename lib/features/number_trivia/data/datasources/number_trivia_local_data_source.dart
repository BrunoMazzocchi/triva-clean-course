import 'package:trivia/features/number_trivia/data/models/number_trivia_model.dart';

abstract class NumberTriviaLocalDataSource {
  /// Gets the cached [NumberTriviaModel] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws a [CacheException] for all error codes.
  Future<NumberTriviaModel> getLastNumberTrivia();

  /// Caches the [NumberTriviaModel] locally
  ///
  /// Throws a [CacheException] for all error codes.
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache);
}
