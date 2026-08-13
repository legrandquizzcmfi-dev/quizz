import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_data.dart';
import '../widgets/glowing_button.dart';
import '../widgets/starry_background.dart';
import 'home_screen.dart';

/// Écran « Parlons un peu de toi ! », affiché uniquement au tout premier
/// lancement de l'application : recueille le prénom et l'âge de l'enfant.
/// Entièrement natif (fond étoilé + carte + champs + bouton), donc
/// pleinement responsive et localisable, plutôt qu'une illustration figée
/// avec des champs superposés à des coordonnées fixes (§9).
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
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

  InputDecoration _fieldDecoration(IconData icon, String hint) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF6A4C93)),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      body: StarryBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icon/icon.png', width: 140),
                    const SizedBox(height: 24),
                    Card(
                      color: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              strings.profileTitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B2E5C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              strings.profileSubtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15, color: Colors.black54),
                            ),
                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                strings.nameLabel,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A4C93)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              maxLength: 24,
                              decoration: _fieldDecoration(Icons.person_rounded, strings.nameHint),
                            ),
                            const SizedBox(height: 18),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                strings.ageLabel,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              maxLength: 2,
                              decoration: _fieldDecoration(Icons.cake_rounded, strings.ageHint),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    GlowingButton(
                      tapKey: const Key('continue_button'),
                      label: strings.continueLabel,
                      color: const Color(0xFFFFA726),
                      trailingIcon: Icons.arrow_forward_rounded,
                      onTap: _isValid ? () => _continue(context) : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
