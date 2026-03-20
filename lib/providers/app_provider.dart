import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('fr');
  bool _isLoggedIn = false;
  String? _token;
  Map<String, dynamic>? _user;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '339408421821-bclcpvr9vpue3t1iqst0ochg0fcspsu9.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;

  AppProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      _isLoggedIn = true;
      // You could also load user info here if stored
    }
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLocale(String languageCode) {
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await ApiService.login(email, password);
    if (result['success']) {
      _isLoggedIn = true;
      _token = result['token'];
      _user = result['user'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      
      notifyListeners();
    }
    return result;
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return {'success': false, 'message': 'Annulé par l\'utilisateur'};

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return {'success': false, 'message': 'Impossible de récupérer l\'idToken de Google'};
      }

      final googleData = {
        'idToken': idToken,
        'email': googleUser.email,
        'prenom': googleUser.displayName?.split(' ').first ?? '',
        'nom': googleUser.displayName?.split(' ').skip(1).join(' ') ?? '',
        'picture': googleUser.photoUrl,
        'googleId': googleUser.id,
      };

      final result = await ApiService.loginGoogle(googleData);
      if (result['success']) {
        _isLoggedIn = true;
        _token = result['token'];
        _user = result['user'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        
        notifyListeners();
      }
      return result;
    } catch (e) {
      debugPrint('Erreur Google Sign-In: $e');
      return {'success': false, 'message': 'Erreur Google Sign-In: $e'};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final result = await ApiService.register(userData);
    return result;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  // Guest login
  void loginAsGuest() {
    _isLoggedIn = true;
    notifyListeners();
  }

  // Simple translation helper
  String translate(String fr, String en) {
    return _locale.languageCode == 'fr' ? fr : en;
  }
}
