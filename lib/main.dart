import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text('Counter Bloc'),
          ),
        ),
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state) {
            _controller.clear();
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            if (state is CounterStateIncremented) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.blue,
                  content: Text('Incremented'),
                  duration: Duration(milliseconds: 500),
                ),
              );
            } else if (state is CounterStateDecremented) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.blue,
                  content: Text('Decremented'),
                  duration: Duration(milliseconds: 500),
                ),
              );
            }
          },
          builder: (context, state) {
            final invalidValue =
                (state is CounterStateInvalidNumber) ? state.invalidValue : '';
            return Column(
              children: [
                Text('Current value => ${state.value}'),
                Visibility(
                  visible: state is CounterStateInvalidNumber,
                  child: Text('Invalid input: $invalidValue'),
                ),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter a number here',
                  ),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(
                              DecrementEvent(_controller.text),
                            );
                      },
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(
                              IncrementEvent(_controller.text),
                            );
                      },
                      child: const Icon(Icons.add),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

@immutable
abstract class CounterState {
  final int value;
  const CounterState(this.value);
}

class CounterStateValid extends CounterState {
  const CounterStateValid(super.value);
}

class CounterStateInvalidNumber extends CounterState {
  final String invalidValue;

  const CounterStateInvalidNumber(
      {required this.invalidValue, required int previousValue})
      : super(previousValue);
}

class CounterStateIncremented extends CounterState {
  const CounterStateIncremented(super.incrementedValue);
}

class CounterStateDecremented extends CounterState {
  const CounterStateDecremented(super.decrementedValue);
}

@immutable
abstract class CounterEvent {
  final String value;

  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(super.value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(super.value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementEvent>(
      (event, emit) {
        final integer = int.tryParse(event.value);
        if (integer == null) {
          emit(CounterStateInvalidNumber(
              invalidValue: event.value, previousValue: state.value));
        } else {
          emit(CounterStateIncremented(state.value + integer));
        }
      },
    );
    on<DecrementEvent>(
      (event, emit) {
        final integer = int.tryParse(event.value);
        if (integer == null) {
          emit(CounterStateInvalidNumber(
              invalidValue: event.value, previousValue: state.value));
        } else {
          emit(CounterStateDecremented(state.value - integer));
        }
      },
    );
  }
}
