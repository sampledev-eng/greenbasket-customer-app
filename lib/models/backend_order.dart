class BackendOrder {
  final int orderId;
  final String status;
  final List<OrderedItem> items;

  BackendOrder({required this.orderId, required this.status, required this.items});

  factory BackendOrder.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List?)
            ?.map((e) => OrderedItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return BackendOrder(
      orderId: json['order_id'] as int,
      status: json['status'] as String,
      items: items,
    );
  }
}

class OrderedItem {
  final int productId;
  final String name;
  final int quantity;

  OrderedItem({required this.productId, required this.name, required this.quantity});

  factory OrderedItem.fromJson(Map<String, dynamic> json) {
    return OrderedItem(
      productId: json['product_id'] as int,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
    );
  }
}
