import 'dart:async';
import 'dart:convert';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:stocktake/models/product.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final stockInputController = TextEditingController();
  final stockEditInputController = TextEditingController();
  final fetchProductErrorSnackBar = SnackBar(
    content: Text('An error occurde red getting product'),
    backgroundColor: Colors.redAccent,
  );
  ProductResponse productResponse;
  bool isLoading = false;

  @override
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
  void dispose() {
    stockInputController.dispose();
    stockEditInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Product product;
    if (productResponse != null) product = productResponse.value;

    Future _fetchProduct(String barcode) async {
      setState(() => isLoading = true);
      var res = await getProduct(barcode);
      print(res);
      print(res.body);
      var productRes = ProductResponse.fromJson(json.decode(res.body));
      if (productRes.status == "SUCCESS") {
        setState(() => productResponse = productRes);
      } else {
        _scaffoldKey.currentState.showSnackBar(fetchProductErrorSnackBar);
      }
      setState(() => isLoading = false);
    }

    Future _fabPressed() async {
      try {
        var options = ScanOptions();
        var result = await BarcodeScanner.scan(options: options);
        var hasResult = !(result.rawContent?.isEmpty ?? true);
        if (hasResult) {
          _fetchProduct(result.rawContent);
        }
      } on Exception {
        setState(() => isLoading = false);
        _scaffoldKey.currentState.showSnackBar(fetchProductErrorSnackBar);
      }
    }

    Future<void> _onAdd() async {
      if (_formKey.currentState.validate()) {
        try {
          setState(() => isLoading = true);
          print(stockInputController.text);
          await updateProduct(
              product.barcode, int.parse(stockInputController.text), true);
          await _fetchProduct(product.barcode);
          stockInputController.clear();
        } on Exception {
          setState(() => isLoading = false);
          _scaffoldKey.currentState.showSnackBar(fetchProductErrorSnackBar);
        }
      }
    }

    Future<void> _onUpdate() async {
      try {
        setState(() => isLoading = true);
        print(stockEditInputController.text);
        await updateProduct(
            product.barcode, int.parse(stockEditInputController.text), false);
        await _fetchProduct(product.barcode);
        stockEditInputController.clear();
      } on Exception {
        setState(() => isLoading = false);
        _scaffoldKey.currentState.showSnackBar(fetchProductErrorSnackBar);
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
                children: <Widget>[
                  Text("Current stock: ${product.stock}"),
                  TextField(
                    controller: stockEditInputController,
                    keyboardType: TextInputType.number,
                  )
                ],
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
                  _onUpdate();
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
                                controller: stockInputController,
                                keyboardType: TextInputType.number,
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
                            onPressed: _onAdd,
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
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Stocktake'),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(24.0),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: contentList),
      ),
      floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.camera), onPressed: _fabPressed),
    );
  }
}
