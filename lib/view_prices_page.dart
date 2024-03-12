import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectionPage extends StatefulWidget {
  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  String selectedCurrency = 'USD';
  String selectedMetal = 'Gold'; // Default selections
  List<String> currencies = ['USD', 'AUD', 'GBP', 'EUR', 'CHF', 'CAD', 'JPY', 'EGP', 'KWD', 'SAR'];
  List<String> metals = ['Gold', 'Silver'];
  Map<String, dynamic> fetchedData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Currency and Metal'),
      ),
      body: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedCurrency,
            onChanged: (newValue) => setState(() => selectedCurrency = newValue!),
            items: currencies.map((currency) => DropdownMenuItem(value: currency, child: Text(currency))).toList(),
          ),
          DropdownButtonFormField<String>(
            value: selectedMetal,
            onChanged: (newValue) => setState(() => selectedMetal = newValue!),
            items: metals.map((metal) => DropdownMenuItem(value: metal, child: Text(metal))).toList(),
          ),
          ElevatedButton(
            onPressed: fetchAndDisplayData,
            child: Text('Show Prices'),
          ),
          if (fetchedData.isNotEmpty) ...[
            Expanded(child: buildPricesTable(fetchedData)),
          ],
        ],
      ),
    );
  }

  void fetchAndDisplayData() async {
    final document = await FirebaseFirestore.instance.collection('metalPrices').doc(selectedCurrency).get();
    if (document.exists) {
      setState(() {
        fetchedData = document.data()!['metals'][selectedMetal];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No data found for selected currency and metal.')));
    }
  }

  Widget buildPricesTable(Map<String, dynamic> data) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Carat')),
        DataColumn(label: Text('Price')),
      ],
      rows: data.entries
          .map((entry) => DataRow(cells: [DataCell(Text(entry.key)), DataCell(Text('${entry.value}'))]))
          .toList(),
    );
  }
}
