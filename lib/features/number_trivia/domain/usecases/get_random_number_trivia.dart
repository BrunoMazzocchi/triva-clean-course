import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:trivia/core/error/failures.dart';
import 'package:trivia/core/usecase/usecase.dart';
import 'package:trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';

class GetRandomNumberTrivia implements UseCase<NumberTrivia, NoParams> {
  final NumberTriviaRepository repository;

  GetRandomNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(NoParams params) async {
    return await repository.getRandomNumberTrivia();
  }
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object> get props => [];
}
