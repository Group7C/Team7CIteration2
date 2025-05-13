import 'package:http/http.dart' as http;
import 'dart:convert';

// handles user-related api operations
// [primarily for mapping between usernames and user ids]
class UserServices {
  // api endpoint [our local dev server againnnn]
  static const String baseUrl = 'http://127.0.0.1:5000';
  
  // finds numeric id for a username
  // [needed for many api operations that use ids]
  static Future<int?> getUserIdFromUsername(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get/user_id?username=$username'),
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['user_id'];
      }
      return null;
    } catch (e) {
      print('Error getting user ID for username $username: $e');
      return null;
    }
  }
  
  // batch converts multiple usernames to ids now
  // [more efficient than individual requests]
  static Future<Map<String, int>> getUserIdsFromUsernames(List<String> usernames) async {
    Map<String, int> userIds = {};
    
    for (String username in usernames) {
      int? userId = await getUserIdFromUsername(username);
      if (userId != null) {
        userIds[username] = userId;
      }
    }
    
    return userIds;
  }
}