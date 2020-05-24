import 'package:http/http.dart' as http;
import 'dart:convert';

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
      value:
          json['status'] == "SUCCESS" ? Product.fromJson(json['value']) : null,
    );
  }
}

Future<http.Response> getProduct(String barcode) {
  return http.get(
      'https://script.google.com/macros/s/AKfycbyPSw_kcKCK7_tY453y4J1U13NR5VZssPhwaJYdPQHuhvDwHNM/exec?barcode=' +
          barcode);
}

Future<http.Response> updateProduct(String barcode, int stock, bool add) {
  print(stock);
  return http.post(
      Uri.encodeFull(
          'https://script.google.com/macros/s/AKfycbyPSw_kcKCK7_tY453y4J1U13NR5VZssPhwaJYdPQHuhvDwHNM/exec'),
      body: json.encode({'barcode': barcode, 'stockCount': stock, 'add': add}));
}
