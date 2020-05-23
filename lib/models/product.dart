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
