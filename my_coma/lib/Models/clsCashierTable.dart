class clsCashierTable {
  final int id;
  final int no;
  clsCashierTable({required this.id,required this.no});

  factory clsCashierTable.fromJson(Map<String, dynamic> json) {
    return clsCashierTable(
      id: json['id'],
      no: json['no']
      );
  }
}