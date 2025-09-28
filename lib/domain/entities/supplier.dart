class Supplier {
  final String id;
  final String name;
  final String? contactName;
  final String? email;
  final String? phone;

  Supplier({
    required this.id,
    required this.name,
    this.contactName,
    this.email,
    this.phone,
  });
}