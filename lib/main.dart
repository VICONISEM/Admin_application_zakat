import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

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
    if (_formKey.currentState!.validate()) {
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
      Navigator.pop(context);
    }
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
                TextFormField(
                  controller: _countryController,
                  decoration: InputDecoration(labelText: 'Country'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a country';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _currencyController,
                  decoration: InputDecoration(labelText: 'Currency'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the currency';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _gold24Controller,
                  decoration: InputDecoration(labelText: 'Gold 24K Price per gram'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter gold 24K price per gram';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _gold22Controller,
                  decoration: InputDecoration(labelText: 'Gold 22K Price per gram'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter gold 22K price per gram';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _gold21Controller,
                  decoration: InputDecoration(labelText: 'Gold 21K Price per gram'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter gold 21K price per gram';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _gold18Controller,
                  decoration: InputDecoration(labelText: 'Gold 18K Price per gram'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter gold 18K price per gram';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _silverController,
                  decoration: InputDecoration(labelText: 'Silver Price per gram'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter silver price per gram';
                    }
                    return null;
                  },
                ),
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
  final TextEditingController _countrySearchController = TextEditingController();

  List<String> _countryList = [];
  List<String> _filteredCountryList = [];

  @override
  void initState() {
    super.initState();
    _fetchCountryList();
  }

  Future<void> _fetchCountryList() async {
    var snapshot = await FirebaseFirestore.instance.collection('metalPrices').get();
    final List<String> countries = snapshot.docs.map((doc) => doc.id).toList();
    setState(() {
      _countryList = countries;
      _filteredCountryList = countries;
    });
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _filteredCountryList = _countryList.where((country) =>
                          country.toLowerCase().contains(value.toLowerCase())).toList();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Search Country',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredCountryList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(_filteredCountryList[index]),
                      onTap: () {
                        setState(() {
                          selectedCountry = _filteredCountryList[index];
                          _countrySearchController.text = selectedCountry!;
                        });
                        Navigator.pop(context);
                        _fetchMetalPrices(selectedCountry!);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchMetalPrices(String countryId) async {
    var documentSnapshot = await FirebaseFirestore.instance.collection('metalPrices').doc(countryId).get();
    if (documentSnapshot.exists) {
      var data = documentSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _currencyController.text = data['currency'];
        _gold24Controller.text = data['gold_24'];
        _gold22Controller.text = data['gold_22'];
        _gold21Controller.text = data['gold_21'];
        _gold18Controller.text = data['gold_18'];
        _silverController.text = data['silver'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Read & Update Metal Prices'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _countrySearchController,
                readOnly: true,
                onTap: _showCountryPicker,
                decoration: InputDecoration(
                  labelText: 'Select a country',
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _currencyController,
                      decoration: InputDecoration(labelText: 'Currency'),
                      validator: (value) => value!.isEmpty ? 'Please enter the currency' : null,
                    ),
                    TextFormField(
                      controller: _gold24Controller,
                      decoration: InputDecoration(labelText: 'Gold 24K Price'),
                      validator: (value) => value!.isEmpty ? 'Please enter gold 24K price per gram' : null,
                    ),
                    TextFormField(
                      controller: _gold22Controller,
                      decoration: InputDecoration(labelText: 'Gold 22K Price'),
                      validator: (value) => value!.isEmpty ? 'Please enter gold 22K price per gram' : null,
                    ),
                    TextFormField(
                      controller: _gold21Controller,
                      decoration: InputDecoration(labelText: 'Gold 21K Price'),
                      validator: (value) => value!.isEmpty ? 'Please enter gold 21K price per gram' : null,
                    ),
                    TextFormField(
                      controller: _gold18Controller,
                      decoration: InputDecoration(labelText: 'Gold 18K Price'),
                      validator: (value) => value!.isEmpty ? 'Please enter gold 18K price per gram' : null,
                    ),
                    TextFormField(
                      controller: _silverController,
                      decoration: InputDecoration(labelText: 'Silver Price'),
                      validator: (value) => value!.isEmpty ? 'Please enter silver price per gram' : null,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
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
                      },
                      child: Text('Update'),
                    ),
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
  final TextEditingController _searchController = TextEditingController();

  List<String> _countryList = [];
  List<String> _filteredCountryList = [];

  @override
  void initState() {
    super.initState();
    _fetchCountryList();
    _searchController.addListener(() {
      _filterCountryList(_searchController.text);
    });
  }

  Future<void> _fetchCountryList() async {
    FirebaseFirestore.instance.collection('metalPrices').get().then((querySnapshot) {
      final List<String> countries = querySnapshot.docs.map((doc) => doc.id).toList();
      setState(() {
        _countryList = countries;
        _filteredCountryList = countries;
      });
    });
  }

  void _filterCountryList(String enteredKeyword) {
    List<String> results;
    if (enteredKeyword.isEmpty) {
      results = _countryList;
    } else {
      results = _countryList
          .where((country) =>
          country.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _filteredCountryList = results;
    });
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: _filterCountryList,
                decoration: InputDecoration(
                  labelText: 'Search Country',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredCountryList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(_filteredCountryList[index]),
                    onTap: () {
                      setState(() {
                        selectedCountry = _filteredCountryList[index];
                        _searchController.text = selectedCountry!;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteMetalPrice() async {
    if (selectedCountry != null) {
      await FirebaseFirestore.instance.collection('metalPrices').doc(selectedCountry).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Country deleted successfully')));
      setState(() {
        selectedCountry = null;
        _searchController.text = '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a country to delete')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Metal Price'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _searchController,
              readOnly: true,
              onTap: _showCountryPicker,
              decoration: InputDecoration(
                labelText: 'Search and select a country to delete',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: deleteMetalPrice,
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}