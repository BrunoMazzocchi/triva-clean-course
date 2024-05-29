import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trivia/core/error/failures.dart';
import 'package:trivia/core/util/input_converter.dart';
import 'package:trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String INVALID_INPUT_FAILURE_MESSAGE = 'Invalid input - the number must be a positive integer or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(NumberTriviaInitial()) {
    on<GetTriviaForConcreteNumber>(_onGetTriviaForConcreteNumber);
    on<GetTriviaForRandomNumber>(_onGetTriviaForRandomNumber);
  }

  Future<void> _onGetTriviaForConcreteNumber(GetTriviaForConcreteNumber event, Emitter<NumberTriviaState> emit) async {
    final inputEither = inputConverter.stringToUnsignedInteger(event.numberString);

    await inputEither.fold(
      (failure) async {
        if (!emit.isDone) {
          emit(const NumberTriviaError(message: INVALID_INPUT_FAILURE_MESSAGE));
        }
      },
      (integer) async {
        emit(NumberTriviaLoading());
        final failureOrTrivia = await getConcreteNumberTrivia(Params(number: integer));
        if (!emit.isDone) {
          failureOrTrivia.fold(
            (failure) {
              emit(NumberTriviaError(message: _mapFailureToMessage(failure)));
            },
            (trivia) {
              emit(NumberTriviaLoaded(trivia: trivia));
            },
          );
        }
      },
    );
  }

  Future<void> _onGetTriviaForRandomNumber(GetTriviaForRandomNumber event, Emitter<NumberTriviaState> emit) async {
    emit(NumberTriviaLoading());
    final failureOrTrivia = await getRandomNumberTrivia(const NoParams());
    if (!emit.isDone) {
      failureOrTrivia.fold(
        (failure) {
          emit(NumberTriviaError(message: _mapFailureToMessage(failure)));
        },
        (trivia) {
          emit(NumberTriviaLoaded(trivia: trivia));
        },
      );
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server failure';
      case CacheFailure _:
        return 'Cache failure';
      default:
        return 'Unexpected error';
    }
  }
}
