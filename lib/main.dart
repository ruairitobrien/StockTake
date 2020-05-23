import 'dart:async';
import 'dart:convert';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(Stocktake());
}

class Product {
  final String barcode;
  final String description;
  final String averageCost;
  final String price;
  final int stock;

  Product(
      {this.barcode,
      this.description,
      this.averageCost,
      this.price,
      this.stock});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        barcode: json['barcode'],
        description: json['description'],
        averageCost: json['averageCost'],
        price: json['price'],
        stock: json['stock']);
  }
}

class ProductResponse {
  final String status;
  final Product value;

  ProductResponse({
    this.status,
    this.value,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      status: json['status'],
      value: Product.fromJson(json['value']),
    );
  }
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
    productResponse = ProductResponse(
        status: "SUCCESS",
        value: Product(
            barcode: "1234",
            description: "Something",
            averageCost: "2.2345",
            price: "2.1",
            stock: 0));
  }

  @override
  Widget build(BuildContext context) {
    Product product;
    if (productResponse != null) product = productResponse.value;

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
                trailing: Icon(Icons.edit),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Enter number of items to add',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: IconButton(
                          icon: Icon(Icons.add_box),
                          color: Colors.lightBlue,
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
                  ),
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

  Future fabPressed() async {
    try {
      var options = ScanOptions();

      var result = await BarcodeScanner.scan(options: options);
      var res = await getProduct(result.rawContent);
      var productResponse = ProductResponse.fromJson(json.decode(res.body));
      setState(() => productResponse = productResponse);
    } on PlatformException catch (e) {
      print(e);
    }
  }
}

Future<http.Response> getProduct(String barCode) {
  return http.get(
      'https://script.google.com/macros/s/AKfycbyPSw_kcKCK7_tY453y4J1U13NR5VZssPhwaJYdPQHuhvDwHNM/exec?barcode=' +
          barCode);
}
