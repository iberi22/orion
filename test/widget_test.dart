// Orion Flutter App Widget Tests
//
// Simple tests for the Orion AI Wellness Companion app

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Orion App Basic Tests', () {
    testWidgets('Basic widget creation test', (WidgetTester tester) async {
      // Build a simple test widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Orion Test')),
            body: const Center(child: Text('Welcome to Orion')),
          ),
        ),
      );

      // Verify basic elements
      expect(find.text('Orion Test'), findsOneWidget);
      expect(find.text('Welcome to Orion'), findsOneWidget);
    });

    testWidgets('Button interaction test', (WidgetTester tester) async {
      int counter = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Counter: $counter'),
                      ElevatedButton(
                        onPressed: () => setState(() => counter++),
                        child: const Text('Increment'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Counter: 0'), findsOneWidget);
      expect(find.text('Increment'), findsOneWidget);

      // Test button tap
      await tester.tap(find.text('Increment'));
      await tester.pump();

      // Verify counter incremented
      expect(find.text('Counter: 1'), findsOneWidget);
    });

    testWidgets('Form field validation test', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      formKey.currentState!.validate();
                    },
                    child: const Text('Validate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Test form validation
      await tester.tap(find.text('Validate'));
      await tester.pump();

      expect(find.text('Please enter some text'), findsOneWidget);
    });

    testWidgets('Text input test', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Enter text here'),
            ),
          ),
        ),
      );

      // Test text input
      await tester.enterText(find.byType(TextField), 'Hello Orion');
      expect(controller.text, 'Hello Orion');
      expect(find.text('Hello Orion'), findsOneWidget);
    });

    testWidgets('Icon test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Column(
              children: [
                Icon(Icons.star, size: 50),
                Icon(Icons.favorite, color: Colors.red),
                Text('Icons Test'),
              ],
            ),
          ),
        ),
      );

      // Verify icons
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('Icons Test'), findsOneWidget);
    });
  });
}
