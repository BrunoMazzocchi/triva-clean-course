part of 'number_trivia_bloc.dart';

sealed class NumberTriviaState extends Equatable {
  const NumberTriviaState();

  @override
  List<Object> get props => [];
}

final class NumberTriviaInitial extends NumberTriviaState {}

final class NumberTriviaLoading extends NumberTriviaState {}

final class NumberTriviaLoaded extends NumberTriviaState {
  final NumberTrivia trivia;

  const NumberTriviaLoaded({required this.trivia});

  @override
  List<Object> get props => [trivia];
}

final class NumberTriviaError extends NumberTriviaState {
  final String message;

  const NumberTriviaError({required this.message});

  @override
  List<Object> get props => [message];
}

final class NumberTriviaEmpty extends NumberTriviaState {}
