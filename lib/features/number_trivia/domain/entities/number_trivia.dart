import 'package:equatable/equatable.dart';

/// Trivia entity that represents the API data that we got
class NumberTrivia extends Equatable {
  final String text;
  final int number;

  const NumberTrivia({
    required this.text,
    required this.number,
  });

  @override
  List<Object?> get props => [text, number];
}
