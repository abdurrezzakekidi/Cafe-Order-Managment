class clsUser {
  final int id;
  final String name;
  final String password;
  final String role;
  final String imagePath;

  clsUser({
    required this.id,
    required this.name,
    required this.password,
    required this.role,
    required this.imagePath
  });

  // Method to convert JSON into clsReport object
  factory clsUser.fromJson(Map<String, dynamic> json) {
    return clsUser(
      id: json['id'],
      name: json['name'],
      password: json['password'],
      role: json['role'],
      imagePath: json['imagePath']
    );
  }
}
