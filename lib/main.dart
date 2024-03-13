import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // Make sure this matches your Firebase configuration file

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
      title: 'Metal Prices App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Metal Prices CRUD'),
        ),
        body: MetalPricesForm(),
      ),
    );
  }
}

class MetalPricesForm extends StatefulWidget {
  @override
  _MetalPricesFormState createState() => _MetalPricesFormState();
}

class _MetalPricesFormState extends State<MetalPricesForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _gold24Controller = TextEditingController();
  final TextEditingController _gold22Controller = TextEditingController();
  final TextEditingController _gold21Controller = TextEditingController();
  final TextEditingController _gold18Controller = TextEditingController();
  final TextEditingController _silverController = TextEditingController();

  // CREATE or UPDATE
  Future<void> createOrUpdateMetalPrice(String country) async {
    await FirebaseFirestore.instance.collection('metalPrices').doc(country).set({
      'currency': _currencyController.text.trim(),
      'gold_24': _gold24Controller.text.trim(),
      'gold_22': _gold22Controller.text.trim(),
      'gold_21': _gold21Controller.text.trim(),
      'gold_18': _gold18Controller.text.trim(),
      'silver': _silverController.text.trim(),
      'id': country,
    });
  }

  // READ
  Future<Map<String, dynamic>?> readMetalPrice(String country) async {
    final docSnapshot = await FirebaseFirestore.instance.collection('metalPrices').doc(country).get();
    return docSnapshot.data();
  }

  // DELETE
  Future<void> deleteMetalPrice(String country) async {
    await FirebaseFirestore.instance.collection('metalPrices').doc(country).delete();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(labelText: 'Country'),
                validator: (value) => value!.isEmpty ? 'Please enter a country name' : null,
              ),
              TextFormField(
                controller: _currencyController,
                decoration: InputDecoration(labelText: 'Currency'),
                validator: (value) => value!.isEmpty ? 'Please enter the currency' : null,
              ),
              TextFormField(
                controller: _gold24Controller,
                decoration: InputDecoration(labelText: 'Gold 24K Price per gram'),
                validator: (value) => value!.isEmpty ? 'Please enter gold 24K price per gram' : null,
              ),
              TextFormField(
                controller: _gold22Controller,
                decoration: InputDecoration(labelText: 'Gold 22K Price per gram'),
                validator: (value) => value!.isEmpty ? 'Please enter gold 22K price per gram' : null,
              ),
              TextFormField(
                controller: _gold21Controller,
                decoration: InputDecoration(labelText: 'Gold 21K Price per gram'),
                validator: (value) => value!.isEmpty ? 'Please enter gold 21K price per gram' : null,
              ),
              TextFormField(
                controller: _gold18Controller,
                decoration: InputDecoration(labelText: 'Gold 18K Price per gram'),
                validator: (value) => value!.isEmpty ? 'Please enter gold 18K price per gram' : null,
              ),
              TextFormField(
                controller: _silverController,
                decoration: InputDecoration(labelText: 'Silver Price per gram'),
                validator: (value) => value!.isEmpty ? 'Please enter silver price per gram' : null,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await createOrUpdateMetalPrice(_countryController.text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data saved successfully')));
                  }
                },
                child: Text('Submit'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final data = await readMetalPrice(_countryController.text.trim());
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('Currency: ${data?['currency']}'),
                            Text('Gold 24K: ${data?['gold_24']}'),
                            Text('Gold 22K: ${data?['gold_22']}'),
                            Text('Gold 21K: ${data?['gold_21']}'),
                            Text('Gold 18K: ${data?['gold_18']}'),
                            Text('Silver: ${data?['silver']}'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text('OK'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Read'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await deleteMetalPrice(_countryController.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data deleted successfully')));
                },
                child: Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
