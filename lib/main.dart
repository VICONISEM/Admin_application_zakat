import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // Ensure proper Firebase initialization.

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
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Metal Prices CRUD')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Create Metal Price'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePage())),
            ),
            ElevatedButton(
              child: Text('Read & Update Metal Prices'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReadUpdatePage())),
            ),
            ElevatedButton(
              child: Text('Delete Metal Price'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DeletePage())),
            ),
          ],
        ),
      ),
    );
  }
}

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _gold24Controller = TextEditingController();
  final TextEditingController _gold22Controller = TextEditingController();
  final TextEditingController _gold21Controller = TextEditingController();
  final TextEditingController _gold18Controller = TextEditingController();
  final TextEditingController _silverController = TextEditingController();

  Future<void> createMetalPrice() async {
    await FirebaseFirestore.instance.collection('metalPrices').doc(_countryController.text.trim()).set({
      'currency': _currencyController.text.trim(),
      'gold_24': _gold24Controller.text.trim(),
      'gold_22': _gold22Controller.text.trim(),
      'gold_21': _gold21Controller.text.trim(),
      'gold_18': _gold18Controller.text.trim(),
      'silver': _silverController.text.trim(),
      'id': _countryController.text.trim(),
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data uploaded successfully')));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Metal Price')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(controller: _countryController, decoration: InputDecoration(labelText: 'Country')),
                TextFormField(controller: _currencyController, decoration: InputDecoration(labelText: 'Currency')),
                TextFormField(controller: _gold24Controller, decoration: InputDecoration(labelText: 'Gold 24K Price per gram')),
                TextFormField(controller: _gold22Controller, decoration: InputDecoration(labelText: 'Gold 22K Price per gram')),
                TextFormField(controller: _gold21Controller, decoration: InputDecoration(labelText: 'Gold 21K Price per gram')),
                TextFormField(controller: _gold18Controller, decoration: InputDecoration(labelText: 'Gold 18K Price per gram')),
                TextFormField(controller: _silverController, decoration: InputDecoration(labelText: 'Silver Price per gram')),
                ElevatedButton(onPressed: createMetalPrice, child: Text('Submit')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReadUpdatePage extends StatefulWidget {
  @override
  _ReadUpdatePageState createState() => _ReadUpdatePageState();
}

class _ReadUpdatePageState extends State<ReadUpdatePage> {
  String? selectedCountry;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _gold24Controller = TextEditingController();
  final TextEditingController _gold22Controller = TextEditingController();
  final TextEditingController _gold21Controller = TextEditingController();
  final TextEditingController _gold18Controller = TextEditingController();
  final TextEditingController _silverController = TextEditingController();

  Future<void> updateMetalPrice() async {
    if (selectedCountry != null && _formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('metalPrices').doc(selectedCountry).update({
        'currency': _currencyController.text.trim(),
        'gold_24': _gold24Controller.text.trim(),
        'gold_22': _gold22Controller.text.trim(),
        'gold_21': _gold21Controller.text.trim(),
        'gold_18': _gold18Controller.text.trim(),
        'silver': _silverController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data updated successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Read & Update Metal Prices")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('metalPrices').get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                List<DropdownMenuItem<String>> countryItems = snapshot.data!.docs.map((doc) => DropdownMenuItem(
                  value: doc.id,
                  child: Text(doc.id),
                )).toList();
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Select a country'),
                  items: countryItems,
                  onChanged: (value) async {
                    final docSnapshot = await FirebaseFirestore.instance.collection('metalPrices').doc(value).get();
                    final data = docSnapshot.data()!;
                    setState(() {
                      selectedCountry = value;
                      _currencyController.text = data['currency'];
                      _gold24Controller.text = data['gold_24'];
                      _gold22Controller.text = data['gold_22'];
                      _gold21Controller.text = data['gold_21'];
                      _gold18Controller.text = data['gold_18'];
                      _silverController.text = data['silver'];
                    });
                  },
                  value: selectedCountry,
                );
              },
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(controller: _currencyController, decoration: InputDecoration(labelText: 'Currency')),
                    TextFormField(controller: _gold24Controller, decoration: InputDecoration(labelText: 'Gold 24K Price')),
                    TextFormField(controller: _gold22Controller, decoration: InputDecoration(labelText: 'Gold 22K Price')),
                    TextFormField(controller: _gold21Controller, decoration: InputDecoration(labelText: 'Gold 21K Price')),
                    TextFormField(controller: _gold18Controller, decoration: InputDecoration(labelText: 'Gold 18K Price')),
                    TextFormField(controller: _silverController, decoration: InputDecoration(labelText: 'Silver Price')),
                    ElevatedButton(onPressed: updateMetalPrice, child: Text('Update')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeletePage extends StatefulWidget {
  @override
  _DeletePageState createState() => _DeletePageState();
}

class _DeletePageState extends State<DeletePage> {
  String? selectedCountry;

  Future<void> deleteMetalPrice(String? country) async {
    if (country != null) {
      await FirebaseFirestore.instance.collection('metalPrices').doc(country).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Country deleted successfully')));
      setState(() {
        selectedCountry = null; // Reset the dropdown after deletion
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delete Metal Price')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('metalPrices').get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                List<DropdownMenuItem<String>> countryItems = snapshot.data!.docs
                    .map((doc) => DropdownMenuItem(
                  value: doc.id,
                  child: Text(doc.id),
                ))
                    .toList();
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Select a country to delete'),
                  items: countryItems,
                  onChanged: (value) => setState(() {
                    selectedCountry = value;
                  }),
                  value: selectedCountry,
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => deleteMetalPrice(selectedCountry),
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}