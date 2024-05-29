import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:trivia/core/error/exceptions.dart';
import 'package:trivia/features/number_trivia/data/models/number_trivia_model.dart';

abstract class NumberTriviaRemoteDataSource {
  /// Calls the http://numbersapi.com/{number} endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  /// Calls the http://numbersapi.com/random endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

typedef _ConcreteOrRandomChooser = Future<Response> Function();

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;

  NumberTriviaRemoteDataSourceImpl({required this.client});

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async {
    return _getTrivia(() {
      return client.get(
        Uri.parse('http://numbersapi.com/$number'),
        headers: {'Content-Type': 'application/json'},
      );
    });
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() async {
    return _getTrivia(() {
      return client.get(
        Uri.parse('http://numbersapi.com/random'),
        headers: {'Content-Type': 'application/json'},
      );
    });
  }

  Future<NumberTriviaModel> _getTrivia(_ConcreteOrRandomChooser getConcreteOrRandom) async {
    final response = await getConcreteOrRandom();

    if (response.statusCode != 200) {
      throw ServerException();
    }

    return NumberTriviaModel.fromJson(json.decode(response.body));
  }
}
