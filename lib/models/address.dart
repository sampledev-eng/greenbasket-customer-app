class Address {
  final int id;
  final String address;

  Address({required this.id, required this.address});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int,
      address: json['address'] as String,
    );
  }
}
