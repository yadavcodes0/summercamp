import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:summer_camp/models/child_model.dart';

class AdminDashboardService {
  final _client = Supabase.instance.client;

  /// Stream all children (Realtime)
  Stream<List<ChildModel>> streamAllChildren() {
    return _client
        .from('children')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) => list.map((e) => ChildModel.fromJson(e)).toList());
  }

  /// Stream all volunteers (Realtime)
  Stream<List<Map<String, dynamic>>> streamAllVolunteers() {
    return _client
        .from('volunteers')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  // Dashboard stats and recent entries can be derived directly from the lists
  // of children and volunteers in the Provider, so we don't need separate
  // streams for them. This is much more efficient and guarantees consistency.
}
