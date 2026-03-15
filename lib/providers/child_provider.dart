import 'package:flutter/material.dart';
import 'package:summer_camp/models/child_model.dart';
import 'package:summer_camp/services/child_service.dart';

enum ChildProviderState { idle, loading, success, error }

class ChildProvider extends ChangeNotifier {
  final _service = ChildService();

  ChildProviderState _state = ChildProviderState.idle;
  ChildProviderState get state => _state;

  String? _error;
  String? get error => _error;

  ChildModel? _registeredChild;
  ChildModel? get registeredChild => _registeredChild;

  List<ChildModel> _childrenList = [];
  List<ChildModel> get childrenList => _childrenList;

  ChildModel? _scannedChild;
  ChildModel? get scannedChild => _scannedChild;

  Future<bool> registerChild({
    required String childName,
    required int age,
    required String parentName,
    required String phone,
    required String address,
  }) async {
    _state = ChildProviderState.loading;
    _error = null;
    notifyListeners();

    try {
      _registeredChild = await _service.registerChild(
        childName: childName,
        age: age,
        parentName: parentName,
        phone: phone,
        address: address,
      );
      _state = ChildProviderState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _state = ChildProviderState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchChildrenByPhone(String phone) async {
    _state = ChildProviderState.loading;
    _error = null;
    _childrenList = [];
    notifyListeners();

    try {
      _childrenList = await _service.getChildrenByPhone(phone);
      _state = ChildProviderState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _state = ChildProviderState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchChildByCampId(String campId) async {
    _state = ChildProviderState.loading;
    _error = null;
    _scannedChild = null;
    notifyListeners();

    try {
      _scannedChild = await _service.getChildByCampId(campId);
      _state = ChildProviderState.success;
      notifyListeners();
      return _scannedChild != null;
    } catch (e) {
      _error = e.toString();
      _state = ChildProviderState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markEntry(String campId) async {
    try {
      _scannedChild = await _service.markEntry(campId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _state = ChildProviderState.idle;
    _error = null;
    _registeredChild = null;
    _childrenList = [];
    _scannedChild = null;
    notifyListeners();
  }
}
