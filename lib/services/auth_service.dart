import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "https://api.mlluizdevtech.com.br";
  String? _token;
  GoogleSignInAccount? _currentUser;

  String? get token => _token;
  GoogleSignInAccount? get currentUser => _currentUser;

  // Instância do GoogleSignIn para versão 7.x
  final _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  // ⚠️ IMPORTANTE: Substitua este Client ID pelo seu do Google Cloud Console
  // Formato: "123456789-abc123def456.apps.googleusercontent.com"
  // Obtenha em: https://console.cloud.google.com/apis/credentials
  static const String serverClientId =
      "37636929163-4l0tgcuaqnp4csarn2kqbalbl0diejpo.apps.googleusercontent.com";

  /// Verifica se o usuário está autenticado
  bool get isAuthenticated => _token != null && _currentUser != null;

  /// Inicializa o GoogleSignIn (obrigatório na v7)
  Future<void> _initializeGoogleSignIn() async {
    if (_isInitialized) return;

    try {
      await _googleSignIn.initialize(
        // CRÍTICO para Android: forneça o serverClientId
        serverClientId: serverClientId,
      );
      _isInitialized = true;
      print("GoogleSignIn inicializado com sucesso");
    } catch (e) {
      print("Erro ao inicializar GoogleSignIn: $e");
      rethrow;
    }
  }

  /// Login com Google
  Future<bool> signInWithGoogle() async {
    try {
      // Garante que está inicializado
      await _initializeGoogleSignIn();

      // Verifica se a plataforma suporta authenticate
      if (!_googleSignIn.supportsAuthenticate()) {
        print("Plataforma não suporta authenticate()");
        return false;
      }

      // Autentica com Google (versão 7.x)
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      _currentUser = account;
      print("Usuário logado: ${account.email}");

      // Obtém a autenticação (agora é síncrono na v7)
      final GoogleSignInAuthentication auth = account.authentication;
      final String? googleIdToken = auth.idToken;

      if (googleIdToken == null) {
        print("Erro: Token do Google é null");
        return false;
      }

      print("Token do Google obtido com sucesso");

      // Envia token Google para sua API
      final response = await http.post(
        Uri.parse("$baseUrl/auth/google"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": googleIdToken}),
      );

      print("Status da resposta: ${response.statusCode}");
      print("Corpo da resposta: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data["token"]; // token da sua API
        print("Token da API recebido com sucesso");
        return true;
      } else {
        print("Erro na API: ${response.statusCode} - ${response.body}");
        _currentUser = null;
        return false;
      }
    } on GoogleSignInException catch (e) {
      print("GoogleSignInException: ${e.code.name} - ${e.description}");
      _currentUser = null;
      return false;
    } catch (e, stackTrace) {
      print("Erro no login com Google: $e");
      print("Stack trace: $stackTrace");
      _currentUser = null;
      return false;
    }
  }

  /// Tenta login silencioso (lightweight authentication)
  Future<bool> attemptSilentSignIn() async {
    try {
      await _initializeGoogleSignIn();

      final result = _googleSignIn.attemptLightweightAuthentication();

      GoogleSignInAccount? account;
      if (result is Future<GoogleSignInAccount?>) {
        account = await result;
      } else {
        account = result as GoogleSignInAccount?;
      }

      if (account == null) {
        return false;
      }

      _currentUser = account;

      // Obtém o token e envia para a API
      final GoogleSignInAuthentication auth = account.authentication;
      final String? googleIdToken = auth.idToken;

      if (googleIdToken == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/auth/google"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": googleIdToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data["token"];
        return true;
      }

      return false;
    } catch (e) {
      print("Erro no login silencioso: $e");
      return false;
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _token = null;
      _currentUser = null;
      print("Logout realizado com sucesso");
    } catch (e) {
      print("Erro ao fazer logout: $e");
    }
  }

  /// Desconecta completamente a conta Google
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      _token = null;
      _currentUser = null;
      print("Conta Google desconectada");
    } catch (e) {
      print("Erro ao desconectar: $e");
    }
  }

  /// Faz requisições autenticadas para sua API
  Future<http.Response> authenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    if (_token == null) {
      throw Exception('Usuário não autenticado');
    }

    final uri = Uri.parse("$baseUrl$endpoint");
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $_token",
    };

    switch (method.toUpperCase()) {
      case 'POST':
        return await http.post(uri, headers: headers, body: jsonEncode(body));
      case 'PUT':
        return await http.put(uri, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        return await http.delete(uri, headers: headers);
      default:
        return await http.get(uri, headers: headers);
    }
  }
}
