import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:summer_camp/models/child_model.dart';

class AdminDashboardService {
  final _client = Supabase.instance.client;

  /// Fetch all children
  Future<List<ChildModel>> getAllChildren() async {
    final response = await _client
        .from('children')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => ChildModel.fromJson(e)).toList();
  }

  /// Fetch all volunteers
  Future<List<Map<String, dynamic>>> getAllVolunteers() async {
    final response = await _client
        .from('volunteers')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get dashboard stats
  Future<Map<String, int>> getDashboardStats() async {
    final children = await _client.from('children').select('id, entry_status');
    final volunteers = await _client.from('volunteers').select('id');

    final totalChildren = children.length;
    final totalVolunteers = volunteers.length;
    final enteredChildren =
        children.where((c) => c['entry_status'] == true).length;
    final remainingChildren = totalChildren - enteredChildren;

    return {
      'totalRegistrations': totalChildren + totalVolunteers,
      'totalChildren': totalChildren,
      'totalVolunteers': totalVolunteers,
      'entriesCompleted': enteredChildren,
      'remaining': remainingChildren,
    };
  }

  /// Get recent entries (last 10)
  Future<List<ChildModel>> getRecentEntries() async {
    final response = await _client
        .from('children')
        .select()
        .eq('entry_status', true)
        .order('entry_time', ascending: false)
        .limit(10);
    return (response as List).map((e) => ChildModel.fromJson(e)).toList();
  }
}
