import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_data.dart';
import 'home_screen.dart';

/// Écran « Parlons un peu de toi ! », affiché uniquement au tout premier
/// lancement de l'application : recueille le prénom et l'âge de l'enfant
/// par-dessus l'illustration fournie par EFDET, avant d'accéder aux thèmes
/// (§9).
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  // Image native : assets/images/profile_setup.png, 941×1672. On fixe le
  // rapport largeur/hauteur du bloc illustré à cette valeur exacte (au lieu
  // d'un simple BoxFit.cover plein écran) pour que les champs superposés
  // restent pixel-parfaits même quand le clavier réduit la hauteur visible ;
  // le contenu devient alors défilable plutôt que déformé.
  static const double _imageAspectRatio = 941 / 1672;

  static const double _boxLeft = 0.29;
  static const double _boxRight = 0.13;
  static const double _nameTop = 0.605;
  static const double _nameHeight = 0.048;
  static const double _ageTop = 0.716;
  static const double _ageHeight = 0.050;

  static const double _buttonLeft = 0.04;
  static const double _buttonRight = 0.02;
  static const double _buttonTop = 0.845;
  static const double _buttonBottom = 0.012;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _ageController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  int? get _parsedAge => int.tryParse(_ageController.text.trim());

  bool get _isValid {
    final age = _parsedAge;
    return _nameController.text.trim().isNotEmpty && age != null && age > 0 && age <= 99;
  }

  void _continue(BuildContext context) {
    if (!_isValid) return;
    AppData.of(context).progress.saveProfile(
          name: _nameController.text.trim(),
          age: _parsedAge!,
        );
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6A4C93), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppData.of(context).strings;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1E3D),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = width / _imageAspectRatio;

            return SingleChildScrollView(
              child: SizedBox(
                width: width,
                height: height,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/profile_setup.png',
                      fit: BoxFit.fill,
                    ),
                    Positioned(
                      left: width * _boxLeft,
                      right: width * _boxRight,
                      top: height * _nameTop,
                      height: height * _nameHeight,
                      child: TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 24,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                        decoration: _fieldDecoration('Écris ton nom ici'),
                      ),
                    ),
                    Positioned(
                      left: width * _boxLeft,
                      right: width * _boxRight,
                      top: height * _ageTop,
                      height: height * _ageHeight,
                      child: TextField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        maxLength: 2,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                        decoration: _fieldDecoration('Écris ton âge ici'),
                      ),
                    ),
                    Positioned(
                      left: width * _buttonLeft,
                      right: width * _buttonRight,
                      top: height * _buttonTop,
                      bottom: height * _buttonBottom,
                      child: Semantics(
                        button: true,
                        label: strings.continueLabel,
                        enabled: _isValid,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            key: const Key('continue_button'),
                            borderRadius: BorderRadius.circular(40),
                            onTap: _isValid ? () => _continue(context) : null,
                            child: AnimatedOpacity(
                              opacity: _isValid ? 0 : 1,
                              duration: const Duration(milliseconds: 200),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
