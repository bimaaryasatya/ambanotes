import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../api_service.dart';

class GraphQLService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<Map<String, dynamic>?> query(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    final url = Uri.parse('${_api.baseUrl.value}/graphql');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_api.token.value != null)
            'Authorization': 'Bearer ${_api.token.value}',
        },
        body: jsonEncode({
          'query': query,
          'variables': variables ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body.containsKey('errors')) {
          print('GraphQL errors: ${body['errors']}');
          return null;
        }
        return body['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      print('GraphQL request error: $e');
    }
    return null;
  }
}
