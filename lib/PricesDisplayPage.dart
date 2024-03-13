import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PricesDisplayPage extends StatefulWidget {
  final String selectedCurrency;
  final String selectedMetal;

  PricesDisplayPage({required this.selectedCurrency, required this.selectedMetal});

  @override
  _PricesDisplayPageState createState() => _PricesDisplayPageState();
}

class _PricesDisplayPageState extends State<PricesDisplayPage> {
  Map<String, TextEditingController> caratControllers = {};

  @override
  void initState() {
    super.initState();
    fetchPrices();
  }

  Future<void> fetchPrices() async {
    final String url = 'https://www.goldapi.io/api/${widget.selectedMetal}/${widget.selectedCurrency}';
    try {
      final response = await http.get(Uri.parse(url), headers: {"x-access-token": "goldapi-1b3ndsltnaidg5-io"});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && _validatePrices(data)) {
          _updateCaratControllers(data);
        } else {
          _clearCaratControllers();
          showAlert('Some prices are missing or fetched data is null. Please enter the prices manually.');
        }
      } else {
        _clearCaratControllers();
        showAlert('Failed to fetch prices. Please enter the prices manually.');
      }
    } catch (e) {
      _clearCaratControllers();
      showAlert('Error fetching prices: $e. Please enter the prices manually.');
    }
  }


  void _updateCaratControllers(Map<String, dynamic> metalPrices) {
    setState(() {
      caratControllers = {
        '24k': TextEditingController(text: metalPrices['24k'].toString()),
        '22k': TextEditingController(text: metalPrices['22k'].toString()),
        '21k': TextEditingController(text: metalPrices['21k'].toString()),
        '20k': TextEditingController(text: metalPrices['20k'].toString()),
        '18k': TextEditingController(text: metalPrices['18k'].toString()),
      };
    });
  }

  void _clearCaratControllers() {
    setState(() {
      caratControllers = {
        '24k': TextEditingController(),
        '22k': TextEditingController(),
        '21k': TextEditingController(),
        '20k': TextEditingController(),
        '18k': TextEditingController(),
      };
    });
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
        title: Text('${widget.selectedMetal} Prices in ${widget.selectedCurrency}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: caratControllers.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextField(
                controller: entry.value,
                decoration: InputDecoration(labelText: '${entry.key} Price Per Gram'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
