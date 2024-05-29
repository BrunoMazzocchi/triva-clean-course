import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trivia/core/util/input_converter.dart';
import 'package:trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

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

      await inputEither.fold(
        (failure) async =>
            emit(const NumberTriviaError(message: 'Invalid input - the number must be a positive integer or zero')),
        (integer) async {
          emit(NumberTriviaLoading());
          final failureOrTrivia = await getConcreteNumberTrivia(Params(number: integer));
          failureOrTrivia.fold(
            (failure) => emit(const NumberTriviaError(message: 'Server failure')),
            (trivia) => emit(NumberTriviaLoaded(trivia: trivia)),
          );
        },
      );
    });

    on<GetTriviaForRandomNumber>((event, emit) async {
      emit(NumberTriviaLoading());
      final failureOrTrivia = await getRandomNumberTrivia(const NoParams());
      failureOrTrivia.fold(
        (failure) => emit(const NumberTriviaError(message: 'Server failure')),
        (trivia) => emit(NumberTriviaLoaded(trivia: trivia)),
      );
    });
  }
}
