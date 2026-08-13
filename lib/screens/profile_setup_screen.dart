import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_data.dart';
import '../ui/game_theme.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_decor.dart';
import '../widgets/responsive_design.dart';
import 'home_screen.dart';

/// « Parlons un peu de toi ! » : panneau bois + ruban, deux champs illustrés,
/// bouton CONTINUER désactivé jusqu'à saisie valide.
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
    _nameController.addListener(_onChanged);
    _ageController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  int? get _parsedAge => int.tryParse(_ageController.text.trim());

  bool get _isValid {
    final age = _parsedAge;
    return _nameController.text.trim().isNotEmpty &&
        age != null &&
        age > 0 &&
        age <= 99;
  }

  void _continue(BuildContext context) {
    if (!_isValid) return;
    AppData.of(
      context,
    ).progress.saveProfile(name: _nameController.text.trim(), age: _parsedAge!);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppData.of(context).strings;

    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: ResponsiveDesign(
            designWidth: 480,
            child: Padding(
              // 35 px de marge latérale : demande explicite du client.
              padding: const EdgeInsets.fromLTRB(35, 22, 35, 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(GameAssets.wordmark, width: 150),
                  ),
                  const SizedBox(height: 4),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Les enfants passent DERRIÈRE le panneau et son ruban.
                      Positioned(
                        left: -6,
                        top: -46,
                        child: Image.asset(GameAssets.kidBoy, width: 104),
                      ),
                      Positioned(
                        right: -10,
                        top: -46,
                        child: Image.asset(GameAssets.kidGirl, width: 118),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 96),
                        child: WoodPanel(
                          title: strings.profileTitle,
                          child: Column(
                            children: [
                              Text(
                                strings.profileSubtitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  height: 1.45,
                                  fontWeight: FontWeight.w700,
                                  color: GameTheme.inkBrown,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _Field(
                                iconAsset: GameAssets.iconPerson,
                                label: strings.nameLabel,
                                labelColor: GameTheme.ribbonBottom,
                                hint: strings.nameHint,
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                maxLength: 24,
                              ),
                              const SizedBox(height: 16),
                              _Field(
                                iconAsset: GameAssets.iconCake,
                                label: strings.ageLabel,
                                labelColor: GameTheme.greenDark,
                                hint: strings.ageHint,
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                maxLength: 2,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  GlowingButton(
                    tapKey: const Key('continue_button'),
                    label: strings.continueLabel.toUpperCase(),
                    fontSize: 21,
                    expand: true,
                    onTap: _isValid ? () => _continue(context) : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String iconAsset;
  final String label;
  final Color labelColor;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const _Field({
    required this.iconAsset,
    required this.label,
    required this.labelColor,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(iconAsset, width: 46),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                textCapitalization: textCapitalization,
                maxLength: maxLength,
                inputFormatters: inputFormatters,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF33261A),
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: _border(const Color(0xFFC9B689)),
                  enabledBorder: _border(const Color(0xFFC9B689)),
                  focusedBorder: _border(labelColor, 2.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, [double width = 2]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
}
