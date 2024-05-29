import 'package:flutter/material.dart';
import 'package:trivia/features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'package:trivia/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Trivia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NumberTriviaPage(),
    );
  }
}
