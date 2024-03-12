import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // Make sure this is correctly set up for your Firebase project.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gold and Silver Prices',
      home: PricesDisplayPage(),
    );
  }
}

class PricesDisplayPage extends StatefulWidget {
  @override
  _PricesDisplayPageState createState() => _PricesDisplayPageState();
}

class _PricesDisplayPageState extends State<PricesDisplayPage> {
  String selectedCurrency = 'USD';
  String selectedMetal = 'XAU'; // XAU for Gold, XAG for Silver
  List<String> metals = ['XAU', 'XAG'];
  List<String> currencies = ['USD', 'AUD', 'GBP', 'EUR', 'CHF', 'CAD', 'JPY', 'EGP', 'KWD', 'SAR'];
  Map<String, TextEditingController> caratControllers = {};
  final String apiKey = 'goldapi-1lsltm3aowc-io';
  TextEditingController _newCurrencyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPrices();
  }

  Future<void> fetchPrices() async {
    final String url = 'https://www.goldapi.io/api/$selectedMetal/$selectedCurrency';
    try {
      final response = await http.get(Uri.parse(url), headers: {"x-access-token": apiKey});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          caratControllers = {
            '24k': TextEditingController(text: data['price_gram_24k'].toString()),
            '22k': TextEditingController(text: data['price_gram_22k'].toString()),
            '21k': TextEditingController(text: data['price_gram_21k'].toString()),
            '20k': TextEditingController(text: data['price_gram_20k'].toString()),
            '18k': TextEditingController(text: data['price_gram_18k'].toString()),
          };
        });
      } else {
        showAlert('Failed to fetch prices. Please enter the prices manually.');
      }
    } catch (e) {
      showAlert('Error fetching prices: $e. Please enter the prices manually.');
    }
  }

  void uploadPricesToFirestore() async {
    if (caratControllers.entries.any((element) => element.value.text.isEmpty)) {
      showAlert('Please enter prices for all carats before uploading.');
      return;
    }

    final Map<String, String> metalNames = {
      'XAU': 'Gold',
      'XAG': 'Silver',
    };

    Map<String, dynamic> metalPrices = {};
    caratControllers.forEach((carat, controller) {
      metalPrices[carat] = double.tryParse(controller.text) ?? 0.0;
    });

    final documentReference = FirebaseFirestore.instance.collection('metalPrices').doc(selectedCurrency);

    Map<String, dynamic> updateData = {
      'currency': selectedCurrency,
      'last_updated': FieldValue.serverTimestamp(),
      'metals': {
        metalNames[selectedMetal] ?? 'Unknown': metalPrices, // Use the full metal name
      }
    };

    try {
      await documentReference.set({
        ...updateData,
        'metals': FieldValue.arrayUnion([updateData['metals']])
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Prices updated successfully in Firestore.')));
    } catch (e) {
      showAlert('Error updating prices in Firestore: $e');
    }
  }


  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gold and Silver Prices'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select Metal'),
              value: selectedMetal,
              onChanged: (String? newValue) {
                setState(() {
                  selectedMetal = newValue!;
                  fetchPrices();
                });
              },
              items: metals.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value == 'XAU' ? 'Gold' : 'Silver'),
                );
              }).toList(),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Choose Your Currency'),
              value: selectedCurrency,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCurrency = newValue!;
                  fetchPrices();
                });
              },
              items: currencies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: _newCurrencyController,
              decoration: InputDecoration(
                labelText: 'Add New Currency',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    final newCurrency = _newCurrencyController.text.toUpperCase();
                    if (!currencies.contains(newCurrency) && newCurrency.isNotEmpty) {
                      setState(() {
                        currencies.add(newCurrency);
                        selectedCurrency = newCurrency;
                        _newCurrencyController.clear();
                        fetchPrices();
                      });
                    }
                  },
                ),
              ),
            ),
            ...caratControllers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: entry.value,
                  decoration: InputDecoration(labelText: '${entry.key} Price Per Gram'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              );
            }).toList(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: uploadPricesToFirestore,
                child: Text('Upload Edited Prices to Firestore'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
