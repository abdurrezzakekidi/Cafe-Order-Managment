class clsTable {
  final int id;
  final int no;
  final String status;

  clsTable({required this.id,required this.no,required this.status});
  // JSON'dan nesneye çevirme
  factory clsTable.fromJson(Map<String, dynamic> json) {
    return clsTable(
      id: json['id'],
      no: json['no'],
      status: json['status'],
    );
  }
  
}