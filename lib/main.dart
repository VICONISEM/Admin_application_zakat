import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // Ensure this file is correctly linked to your Firebase project.

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
  List<String> currencies = ['USD', 'AUD', 'GBP', 'EUR', 'CHF', 'CAD', 'JPY', 'EGP', 'KWD', 'SAR'];
  TextEditingController _newCurrencyController = TextEditingController();
  TextEditingController _goldPriceController = TextEditingController();
  TextEditingController _silverPriceController = TextEditingController();
  final String apiKey = 'goldapi-1lsltm3aowc-io'; // Replace with your actual API key.

  Future<void> fetchPrices() async {
    if (!currencies.contains(_newCurrencyController.text.toUpperCase()) && _newCurrencyController.text.isNotEmpty) {
      setState(() {
        currencies.add(_newCurrencyController.text.toUpperCase());
        selectedCurrency = _newCurrencyController.text.toUpperCase();
      });
    }

    String urlGold = 'https://www.goldapi.io/api/XAU/$selectedCurrency';
    String urlSilver = 'https://www.goldapi.io/api/XAG/$selectedCurrency';
    try {
      var responseGold = await http.get(Uri.parse(urlGold), headers: {"x-access-token": apiKey});
      var responseSilver = await http.get(Uri.parse(urlSilver), headers: {"x-access-token": apiKey});
      if (responseGold.statusCode == 200 && responseSilver.statusCode == 200) {
        var dataGold = json.decode(responseGold.body);
        var dataSilver = json.decode(responseSilver.body);
        if (dataGold['price_gram_24k'] == null || dataSilver['price_gram_24k'] == null) {
          showAlert('Please enter the prices manually.');
        } else {
          _goldPriceController.text = dataGold['price_gram_24k'].toString();
          _silverPriceController.text = dataSilver['price_gram_24k'].toString();
        }
      } else {
        showAlert('Failed to fetch prices. Please enter the prices manually.');
      }
    } catch (e) {
      showAlert('Error fetching prices: $e. Please enter the prices manually.');
    }
  }

  void uploadPricesToFirestore() async {
    if (_goldPriceController.text.isEmpty || _silverPriceController.text.isEmpty) {
      showAlert('Please enter prices for both gold and silver before uploading.');
      return;
    }

    double goldPrice = double.tryParse(_goldPriceController.text) ?? 0.0;
    double silverPrice = double.tryParse(_silverPriceController.text) ?? 0.0;
    final documentReference = FirebaseFirestore.instance.collection('metalPrices').doc(selectedCurrency);

    try {
      await documentReference.set({
        'currency': selectedCurrency,
        'price_of_gold': goldPrice,
        'price_of_silver': silverPrice,
        'last_updated': FieldValue.serverTimestamp(),
      });
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Choose Your Currency',
                ),
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
            ),
            TextField(
              controller: _newCurrencyController,
              decoration: InputDecoration(labelText: 'Add/Select New Currency'),
            ),
            ElevatedButton(
              onPressed: fetchPrices,
              child: Text('Fetch Prices'),
            ),
            TextField(
              controller: _goldPriceController,
              decoration: InputDecoration(labelText: 'Gold Price Per Gram'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _silverPriceController,
              decoration: InputDecoration(labelText: 'Silver Price Per Gram'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: uploadPricesToFirestore,
              child: Text('Upload Edited Prices to Firestore'),
            ),
          ],
        ),
      ),
    );
  }
}
