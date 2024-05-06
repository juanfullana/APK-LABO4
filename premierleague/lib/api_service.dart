import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiKey = '6dc6dddf0b7c41258a578ab4e7be4f93';
  static const String apiUrl = 'https://api.football-data.org/v2/competitions/PL';

  Future<dynamic> obtenerResultadosThisSeason() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/matches?status=FINISHED'),
        headers: {'X-Auth-Token': apiKey},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al obtener los resultados de la API');
      }

      final dynamic data = jsonDecode(response.body);
      if (data == null) {
        throw Exception('Error: Respuesta de la API nula');
      }

      return data;
    } catch (error) {
      throw Exception('Error al obtener los resultados de la API: $error');
    }
  }
}
