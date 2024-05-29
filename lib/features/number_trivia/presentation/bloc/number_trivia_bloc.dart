import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trivia/core/error/failures.dart';
import 'package:trivia/core/util/input_converter.dart';
import 'package:trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

// ignore: constant_identifier_names
const String SERVER_FAILURE_MESSAGE = 'Server Failure';
// ignore: constant_identifier_names
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
// ignore: constant_identifier_names
const String INVALID_INPUT_FAILURE_MESSAGE = 'Invalid Input - The number must be a positive integer or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(NumberTriviaInitial()) {
    on<GetTriviaForConcreteNumber>((event, emit) async {
      final inputEither = inputConverter.stringToUnsignedInteger(event.numberString);

      inputEither.fold(
        (failure) => emit(const NumberTriviaError(message: INVALID_INPUT_FAILURE_MESSAGE)),
        (integer) async {
          emit(NumberTriviaLoading());
          final failureOrTrivia = await getConcreteNumberTrivia(Params(number: integer));
          failureOrTrivia.fold(
            (failure) => emit(NumberTriviaError(message: _mapFailureToMessage(failure))),
            (trivia) => emit(NumberTriviaLoaded(trivia: trivia)),
          );
        },
      );
    });

    on<GetTriviaForRandomNumber>((event, emit) async {
      emit(NumberTriviaLoading());
      final failureOrTrivia = await getRandomNumberTrivia(const NoParams());
      failureOrTrivia.fold(
        (failure) => emit(NumberTriviaError(message: _mapFailureToMessage(failure))),
        (trivia) => emit(NumberTriviaLoaded(trivia: trivia)),
      );
    });
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure _:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }
}
