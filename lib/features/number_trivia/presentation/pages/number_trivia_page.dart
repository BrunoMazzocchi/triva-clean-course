import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:trivia/features/number_trivia/presentation/widgets/widgets.dart';
import 'package:trivia/injection_container.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Trivia'),
      ),
      body: SingleChildScrollView(
        child: buildBody(context),
      ),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              // Top half
              BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                builder: (context, state) {
                  if (state is NumberTriviaInitial) {
                    return const MessageDisplay(
                      message: 'Start searching!',
                    );
                  } else if (state is NumberTriviaLoading) {
                    return const LoadingWidget();
                  } else if (state is NumberTriviaLoaded) {
                    return TriviaDisplay(numberTrivia: state.trivia);
                  } else if (state is NumberTriviaError) {
                    return MessageDisplay(
                      message: state.message,
                    );
                  } else {
                    return const MessageDisplay(
                      message: 'An unexpected error occurred!',
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              // Bottom half
              const TriviaControls()
            ],
          ),
        ),
      ),
    );
  }
}
