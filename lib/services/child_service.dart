import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:summer_camp/models/child_model.dart';
import 'package:uuid/uuid.dart';

class ChildService {
  final _client = Supabase.instance.client;
  final _uuid = const Uuid();

  /// Generates a unique camp ID in the format SC2026-XXXX
  Future<String> _generateChildId() async {
    final result = await _client
        .from('children')
        .select('child_id')
        .order('created_at', ascending: false)
        .limit(1);

    if (result.isEmpty) {
      return 'SC2026-0001';
    }

    final lastId = result.first['child_id'] as String;
    // Extract number part: SC2026-0001 → 1
    final parts = lastId.split('-');
    final lastNum = int.tryParse(parts.last) ?? 0;
    final nextNum = lastNum + 1;
    return 'SC2026-${nextNum.toString().padLeft(4, '0')}';
  }

  /// Register a new child
  Future<ChildModel> registerChild({
    required String childName,
    required int age,
    required String parentName,
    required String phone,
    required String address,
  }) async {
    final childId = await _generateChildId();

    final data = {
      'id': _uuid.v4(),
      'child_id': childId,
      'child_name': childName,
      'age': age,
      'parent_name': parentName,
      'phone': phone,
      'address': address,
      'entry_status': false,
    };

    final response =
        await _client.from('children').insert(data).select().single();

    return ChildModel.fromJson(response);
  }

  /// Fetch children by parent phone number
  Future<List<ChildModel>> getChildrenByPhone(String phone) async {
    final response = await _client
        .from('children')
        .select()
        .eq('phone', phone)
        .order('created_at');

    return (response as List).map((e) => ChildModel.fromJson(e)).toList();
  }

  /// Fetch a single child by their camp ID
  Future<ChildModel?> getChildByCampId(String childId) async {
    final response = await _client
        .from('children')
        .select()
        .eq('child_id', childId)
        .maybeSingle();

    if (response == null) return null;
    return ChildModel.fromJson(response);
  }

  /// Mark a child as entered
  Future<ChildModel> markEntry(String childId) async {
    final now = DateTime.now().toIso8601String();
    final response = await _client
        .from('children')
        .update({'entry_status': true, 'entry_time': now})
        .eq('child_id', childId)
        .select()
        .single();

    return ChildModel.fromJson(response);
  }
}
