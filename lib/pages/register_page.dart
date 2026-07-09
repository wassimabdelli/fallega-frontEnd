import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/app_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_input.dart';
import 'verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _acceptTerms = true;

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_prenomController.text.isEmpty ||
        _nomController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez accepter les conditions d\'utilisation')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    final userData = {
      'prenom': _prenomController.text.trim(),
      'nom': _nomController.text.trim(),
      'email': _emailController.text.trim(),
      'tel': int.tryParse(_phoneController.text.replaceAll(RegExp(r'\D'), '')) ?? 0,
      'password': _passwordController.text,
      'age': '2000-01-01', // Valeur par défaut
      'role': 'USER',    // Valeur par défaut demandée
    };

    final result = await appProvider.register(userData);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success'] || (result['message'] == null && result['user'] != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte créé ! Vérifiez votre email.')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationPage(email: _emailController.text.trim()),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Erreur lors de l\'inscription')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimary, kPrimaryDark],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.user_plus,
                    size: 40,
                    color: kPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Fallega',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  appProvider.translate('Créez votre compte', 'Create your account'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),

                // Signup Card
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        appProvider.translate('Inscription', 'Sign Up'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: AppInput(
                              controller: _prenomController,
                              placeholder: appProvider.translate('Prénom', 'First Name'),
                              icon: const Icon(LucideIcons.user),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppInput(
                              controller: _nomController,
                              placeholder: appProvider.translate('Nom', 'Last Name'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppInput(
                        controller: _emailController,
                        placeholder: 'Email',
                        icon: const Icon(LucideIcons.mail),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      AppInput(
                        controller: _phoneController,
                        placeholder: appProvider.translate('Téléphone', 'Phone'),
                        icon: const Icon(LucideIcons.phone),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      AppInput(
                        controller: _passwordController,
                        placeholder: appProvider.translate('Mot de passe', 'Password'),
                        icon: const Icon(LucideIcons.lock),
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      AppInput(
                        controller: _confirmPasswordController,
                        placeholder: appProvider.translate('Confirmer', 'Confirm'),
                        icon: const Icon(LucideIcons.shield_check),
                        isPassword: true,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _acceptTerms,
                              onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                              activeColor: kPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              appProvider.translate(
                                'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
                                'I accept the terms of use and privacy policy',
                              ),
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        fullWidth: true,
                        onPressed: _isLoading ? null : _handleRegister,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(appProvider.translate('S\'inscrire', 'Sign Up')),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            appProvider.translate('Déjà un compte ? ', 'Already have an account? '),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              appProvider.translate('Se connecter', 'Sign In'),
                              style: const TextStyle(
                                color: kPrimary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
