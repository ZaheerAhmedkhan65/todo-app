import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String _baseUrl = 'http://localhost:3000/api';
  
  String? _authToken;
  String? _guestId;
  static const String _guestIdKey = 'guest_id';

  /// Initialize API service and load persisted guest ID
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _guestId = prefs.getString(_guestIdKey);
    
    // Generate new guest ID if not exists
    if (_guestId == null) {
      _guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_guestIdKey, _guestId!);
    }
  }

  /// Get or generate guest ID (persistent across app sessions)
  Future<String> getGuestId() async {
    if (_guestId == null) {
      await init();
    }
    return _guestId!;
  }

  /// Set authentication token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Get headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    if (_guestId == null) {
      await init();
    }
    
    final headers = {
      'Content-Type': 'application/json',
      'X-Guest-ID': _guestId!,
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/health'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Server unavailable'};
    } catch (e) {
      return {'success': false, 'message': 'Connection failed: $e'};
    }
  }

  /// Get all todos
  Future<List<Map<String, dynamic>>> getTodos({String? filter}) async {
    try {
      final uri = filter != null 
          ? Uri.parse('$_baseUrl/todos?filter=$filter')
          : Uri.parse('$_baseUrl/todos');
      
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching todos: $e');
      return [];
    }
  }

  /// Create a new todo
  Future<Map<String, dynamic>?> createTodo(Map<String, dynamic> todo) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/todos'),
        headers: headers,
        body: json.encode(todo),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Error creating todo: $e');
      return null;
    }
  }

  /// Update a todo
  Future<bool> updateTodo(int id, Map<String, dynamic> todo) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/todos/$id'),
        headers: headers,
        body: json.encode(todo),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating todo: $e');
      return false;
    }
  }

  /// Toggle todo completion
  Future<Map<String, dynamic>?> toggleTodo(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$_baseUrl/todos/$id/toggle'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Error toggling todo: $e');
      return null;
    }
  }

  /// Delete a todo
  Future<bool> deleteTodo(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/todos/$id'),
        headers: headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting todo: $e');
      return false;
    }
  }

  /// Get deleted todos history
  Future<List<Map<String, dynamic>>> getDeletedTodos() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/history'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching deleted todos: $e');
      return [];
    }
  }

  /// Clear deleted todos
  Future<bool> clearDeletedTodos() async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/history'),
        headers: headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error clearing deleted todos: $e');
      return false;
    }
  }

  /// Register user
  Future<Map<String, dynamic>?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Error registering: $e');
      return null;
    }
  }

  /// Login user
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }
}