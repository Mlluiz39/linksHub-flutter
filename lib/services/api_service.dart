import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/social_link.dart';

class ApiService {
  static const String baseUrl =
      "https://api.mlluizdevtech.com.br/links"; // troque pelo seu endpoint real

  // Buscar todos
  Future<List<SocialLink>> getAllSocialLinks() async {
    final response = await http.get(Uri.parse("$baseUrl/social_links"));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => SocialLink.fromMap(e)).toList();
    } else {
      throw Exception("Erro ao carregar links");
    }
  }

  // Buscar por ID
  Future<SocialLink?> getSocialLink(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/social_links/$id"));
    if (response.statusCode == 200) {
      return SocialLink.fromMap(jsonDecode(response.body));
    }
    return null;
  }

  // Criar
  Future<int> insertSocialLink(SocialLink link) async {
    final response = await http.post(
      Uri.parse("$baseUrl/social_links"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(link.toMap()),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json["id"]; // depende do retorno da sua API
    } else {
      throw Exception("Erro ao inserir link");
    }
  }

  // Atualizar
  Future<bool> updateSocialLink(SocialLink link) async {
    final response = await http.put(
      Uri.parse("$baseUrl/social_links/${link.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(link.toMap()),
    );
    return response.statusCode == 200;
  }

  // Deletar
  Future<bool> deleteSocialLink(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/social_links/$id"));
    return response.statusCode == 200;
  }

  // Buscar por texto
  Future<List<SocialLink>> searchSocialLinks(String query) async {
    final response =
        await http.get(Uri.parse("$baseUrl/social_links/search?q=$query"));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => SocialLink.fromMap(e)).toList();
    } else {
      throw Exception("Erro na busca");
    }
  }
}
