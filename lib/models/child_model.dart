class ChildModel {
  final String id;
  final String childId;
  final String childName;
  final int age;
  final String parentName;
  final String phone;
  final String address;
  final String? gender;
  final bool entryStatus;
  final DateTime? entryTime;
  final String? branchName;
  final String? markedByVolunteerName;
  final String? markedByVolunteerPhone;
  final DateTime createdAt;

  ChildModel({
    required this.id,
    required this.childId,
    required this.childName,
    required this.age,
    required this.parentName,
    required this.phone,
    required this.address,
    this.gender,
    this.branchName,
    required this.entryStatus,
    this.entryTime,
    this.markedByVolunteerName,
    this.markedByVolunteerPhone,
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
      gender: json['gender'] as String?,
      branchName: json['branch_name'] as String?,
      entryStatus: json['entry_status'] as bool? ?? false,
      entryTime: json['entry_time'] != null
          ? DateTime.parse(json['entry_time'] as String)
          : null,
      markedByVolunteerName: json['marked_by_volunteer_name'] as String?,
      markedByVolunteerPhone: json['marked_by_volunteer_phone'] as String?,
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
      'gender': gender,
      'branch_name': branchName,
    };
  }

  ChildModel copyWith({
    bool? entryStatus,
    DateTime? entryTime,
    String? markedByVolunteerName,
    String? markedByVolunteerPhone,
  }) {
    return ChildModel(
      id: id,
      childId: childId,
      childName: childName,
      age: age,
      parentName: parentName,
      phone: phone,
      address: address,
      gender: gender,
      branchName: branchName,
      entryStatus: entryStatus ?? this.entryStatus,
      entryTime: entryTime ?? this.entryTime,
      markedByVolunteerName: markedByVolunteerName ?? this.markedByVolunteerName,
      markedByVolunteerPhone: markedByVolunteerPhone ?? this.markedByVolunteerPhone,
      createdAt: createdAt,
    );
  }
}
