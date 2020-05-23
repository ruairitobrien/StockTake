import 'dart:async';
import 'dart:convert';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:stocktake/models/product.dart';

void main() {
  runApp(Stocktake());
}

class Stocktake extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stocktake',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  ProductResponse productResponse;

  @override
  // ignore: type_annotate_public_apis
  initState() {
    super.initState();
    // productResponse = ProductResponse(
    //     status: "SUCCESS",
    //     value: Product(
    //         barcode: "1234",
    //         description: "Something",
    //         averageCost: "2.2345",
    //         price: "2.1",
    //         stock: 0));
  }

  @override
  Widget build(BuildContext context) {
    Product product;
    if (productResponse != null) product = productResponse.value;

    Future fabPressed() async {
      try {
        print('PRESSED');
        var options = ScanOptions();

        var result = await BarcodeScanner.scan(options: options);
        var res = await getProduct(result.rawContent);
        print(res.body);
        var productRes = ProductResponse.fromJson(json.decode(res.body));
        setState(() => productResponse = productRes);
      } on PlatformException catch (e) {
        print(e);
      }
    }

    Future<void> _showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit Stock Count'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Save'),
                color: Colors.blue,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    var contentList = <Widget>[
      if (productResponse == null)
        Center(
          child: Text('Scan a barcode to begin'),
        ),
      if (productResponse != null)
        Card(
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.receipt),
                title: Text(product.description),
                subtitle: Text('Barcode: ${product.barcode}'),
              ),
              ListTile(
                title: Text('Price: ${product.price}'),
              ),
              ListTile(
                title: Text('Current stock: ${product.stock}'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showMyDialog();
                  },
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Flexible(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16.0),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  hintText: 'Enter number of items to add',
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter an amount';
                                  }
                                  return null;
                                },
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: IconButton(
                            icon: Icon(Icons.add_box),
                            color: Colors.blue,
                            iconSize: 48,
                            tooltip: 'Add stock',
                            onPressed: () {
                              setState(() {
                                if (_formKey.currentState.validate()) {}
                              });
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Stocktake'),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(24.0),
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: contentList),
      ),
      floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.camera), onPressed: fabPressed),
    );
  }
}

Future<http.Response> getProduct(String barCode) {
  return http.get(
      'https://script.google.com/macros/s/AKfycbyPSw_kcKCK7_tY453y4J1U13NR5VZssPhwaJYdPQHuhvDwHNM/exec?barcode=' +
          barCode);
}
