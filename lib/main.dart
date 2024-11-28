import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Zitat App',
      home: QuoteScreen(),
    );
  }
}

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  QuoteScreenState createState() => QuoteScreenState();
}

class QuoteScreenState extends State<QuoteScreen> {
  String quote = '';
  String author = '';
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    loadSavedQuote();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> loadSavedQuote() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      quote = prefs.getString('quote') ??
          'As me in life as a feather in the air missed its way to its aim so it left itself to the wind to lead it anywhere hopeless and aimless';
      author = prefs.getString('author') ?? 'Muhammad Hassan';
    });
  }

  Future<void> saveQuote(String quote, String author) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quote', quote);
    await prefs.setString('author', author);
  }

  Future<void> fetchQuote() async {
    final url = Uri.parse('https://api.api-ninjas.com/v1/quotes');
    final response = await http.get(
      url,
      headers: {
        'X-Api-Key': 'RzN5klLmwJH260bJVg0yfQ==anILjq2Zqvujuk1h',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        quote = data[0]['quote'];
        author = data[0]['author'];
      });
      await saveQuote(quote, author);

      _confettiController.play();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New quote loaded')),
      );
    } else {
      setState(() {
        quote = 'Fehler beim Abrufen des Zitats.';
        author = '';
      });
    }
  }

  Future<void> deleteQuote() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quote');
    await prefs.remove('author');
    setState(() {
      quote = 'Click to get a new Quotation';
      author = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/09c7b5584ff749eb34455a54ee657331.jpg',
              fit: BoxFit.cover,
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive, // Rundum
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            shouldLoop: false,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '"$quote"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color.fromARGB(255, 0, 83, 151),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    author.isNotEmpty ? '- $author' : '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 123, 0, 0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 180,
            left: 100,
            right: 100,
            child: ElevatedButton(
              onPressed: fetchQuote,
              child: const Text(
                'Get new Quotation',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: 80,
            right: 80,
            child: ElevatedButton(
              onPressed: deleteQuote,
              child: const Text(
                'Delete saved Quotation',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
