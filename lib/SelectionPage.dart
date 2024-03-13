import 'package:flutter/material.dart';
import 'PricesDisplayPage.dart'; // Ensure PricesDisplayPage.dart is in the same directory

class SelectionPage extends StatefulWidget {
  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  String selectedCurrency = 'USD';
  String selectedMetal = 'Gold'; // Use the full metal name to match JSON structure
  List<String> currencies = ['USD', 'AUD', 'GBP', 'EUR', 'CHF', 'CAD', 'JPY', 'EGP', 'KWD', 'SAR'];
  final List<String> metals = ['Gold', 'Silver']; // Gold and Silver

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Currency and Metal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedCurrency,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCurrency = newValue!;
                });
              },
              items: currencies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedMetal,
              onChanged: (String? newValue) {
                setState(() {
                  selectedMetal = newValue!;
                });
              },
              items: metals.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PricesDisplayPage(selectedCurrency: selectedCurrency, selectedMetal: selectedMetal),
                  ),
                );
              },
              child: Text('Show Prices'),
            ),
          ],
        ),
      ),
    );
  }
}
