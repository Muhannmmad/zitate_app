import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zitat App',
      home: QuoteScreen(),
    );
  }
}

class QuoteScreen extends StatefulWidget {
  @override
  _QuoteScreenState createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  String quote = 'click here to get new quotation.';
  String author = '';

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
    } else {
      setState(() {
        quote = 'Fehler beim Abrufen des Zitats.';
        author = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            'assets/09c7b5584ff749eb34455a54ee657331.jpg',
            fit: BoxFit.cover,
          ),
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
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: const Color.fromARGB(255, 0, 83, 151)),
                ),
                SizedBox(height: 10),
                Text(
                  author.isNotEmpty ? '- $author' : '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: const Color.fromARGB(255, 123, 0, 0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: fetchQuote,
                  child: Text(
                    'Get new quotation',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
