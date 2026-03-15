class ChildModel {
  final String id;
  final String childId;
  final String childName;
  final int age;
  final String parentName;
  final String phone;
  final String address;
  final bool entryStatus;
  final DateTime? entryTime;
  final DateTime createdAt;

  ChildModel({
    required this.id,
    required this.childId,
    required this.childName,
    required this.age,
    required this.parentName,
    required this.phone,
    required this.address,
    required this.entryStatus,
    this.entryTime,
    required this.createdAt,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      childName: json['child_name'] as String,
      age: json['age'] as int,
      parentName: json['parent_name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      entryStatus: json['entry_status'] as bool? ?? false,
      entryTime: json['entry_time'] != null
          ? DateTime.parse(json['entry_time'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'child_name': childName,
      'age': age,
      'parent_name': parentName,
      'phone': phone,
      'address': address,
    };
  }

  ChildModel copyWith({bool? entryStatus, DateTime? entryTime}) {
    return ChildModel(
      id: id,
      childId: childId,
      childName: childName,
      age: age,
      parentName: parentName,
      phone: phone,
      address: address,
      entryStatus: entryStatus ?? this.entryStatus,
      entryTime: entryTime ?? this.entryTime,
      createdAt: createdAt,
    );
  }
}
