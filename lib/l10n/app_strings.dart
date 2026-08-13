/// Textes de l'interface (hors contenu des questions, qui vit dans les JSON
/// de thème), disponibles en français et en anglais pour le sélecteur de
/// langue (§9).
class AppStrings {
  final String languageCode;

  const AppStrings(this.languageCode);

  bool get _isEn => languageCode == 'en';

  String get appTitle => _isEn ? 'The Great Quiz' : 'Le Grand Quiz';

  String get comingSoonBody => _isEn
      ? 'Coming soon — the questions for this theme will be added shortly.'
      : 'Contenu à venir — les questions de ce thème seront ajoutées prochainement.';

  // Les 3 niveaux de chaque thème sont des paliers de difficulté croissante
  // (§5.1) : on les nomme directement d'après cette difficulté plutôt que
  // par un numéro générique.
  String level(int index) {
    if (_isEn) {
      switch (index) {
        case 1:
          return 'Easy';
        case 2:
          return 'Medium';
        case 3:
          return 'Hard';
        default:
          return 'Level $index';
      }
    }
    switch (index) {
      case 1:
        return 'Facile';
      case 2:
        return 'Moyen';
      case 3:
        return 'Difficile';
      default:
        return 'Niveau $index';
    }
  }

  String get levelEmptyBody => _isEn
      ? "This level doesn't have any questions yet.\nContent will be added shortly."
      : 'Ce niveau ne contient pas encore de questions.\nLe contenu sera ajouté prochainement.';

  String stageTitle(String themeTitle, int index) =>
      _isEn ? '$themeTitle — Stage $index' : '$themeTitle — Étape $index';

  String levelTitle(String themeTitle, int index) =>
      '$themeTitle — ${level(index)}';

  String questionProgress(int current, int total) =>
      'Question $current / $total';

  String get next => _isEn ? 'Next' : 'Suivant';

  String get finish => _isEn ? 'Finish' : 'Terminer';

  String get bravo => _isEn ? 'Great job!' : 'Bravo !';

  String get almost => _isEn ? 'Almost!' : 'Presque !';

  String score(int score, int total) =>
      _isEn ? 'Score: $score / $total' : 'Score : $score / $total';

  String get passedMessage => _isEn
      ? 'Stage passed, the next one is unlocked!'
      : 'Étape validée, la suite est débloquée !';

  String get failedMessage => _isEn
      ? 'You need at least 8 correct answers to unlock the next stage.'
      : 'Il faut au moins 8 bonnes réponses pour débloquer la suite.';

  String get replayStage => _isEn ? 'Replay this stage' : 'Rejouer cette étape';

  String get nextStage => _isEn ? 'Next stage' : 'Étape suivante';

  String get backToStages => _isEn ? 'Back to stages' : 'Retour aux étapes';

  String get soon => _isEn ? 'Soon' : 'Bientôt';

  String soundTooltip(bool muted) {
    if (_isEn) return muted ? 'Unmute sound' : 'Mute sound';
    return muted ? 'Réactiver le son' : 'Couper le son';
  }

  String get start => _isEn ? 'Start' : 'Commencer';

  String get continueLabel => _isEn ? 'Continue' : 'Continuer';

  String get play => _isEn ? 'Play' : 'Jouer';

  String get themes => _isEn ? 'Themes' : 'Thèmes';

  String get challenges => _isEn ? 'Challenges' : 'Défis';

  String get leaderboard => _isEn ? 'Leaderboard' : 'Classements';

  String get favorites => _isEn ? 'Favorites' : 'Favoris';

  String get featureComingSoon => _isEn
      ? 'This feature is coming soon!'
      : 'Cette fonctionnalité arrive bientôt !';

  String get stagesWord => _isEn ? 'stages' : 'étapes';

  String stagesCompleted(int passed, int total) => _isEn
      ? '$passed of $total stages completed'
      : '$passed étapes réussies sur $total';

  String get welcomeBanner => _isEn
      ? 'Welcome! Ready for the adventure?'
      : 'Bienvenue ! Prêt pour l\'aventure ?';

  String get playCaption => _isEn
      ? 'Choose your theme and start playing!'
      : 'Choisis ton thème et commence à jouer !';

  String get myProgress => _isEn ? 'My progress' : 'Ma progression';

  String get stagesCompletedLabel =>
      _isEn ? 'Stages completed' : 'Étapes réussies';

  String get keepGoing => _isEn ? 'Keep it up!' : 'Continue comme ça !';

  String get myAchievements => _isEn ? 'My achievements' : 'Mes succès';

  String get discoverBadges =>
      _isEn ? 'Discover your badges!' : 'Découvre tes médailles !';

  String get seeAchievements =>
      _isEn ? 'See my achievements' : 'Voir mes succès';

  String get tagline =>
      _isEn ? 'Learn • Play • Grow' : 'Apprends • Joue • Grandis';

  String get profileTitle =>
      _isEn ? 'Let\'s talk about you!' : 'Parlons un peu de toi !';

  String get profileSubtitle => _isEn
      ? 'To start the quiz, we need a bit of info.'
      : 'Pour commencer le quiz, nous avons besoin de quelques infos.';

  String get nameLabel => _isEn ? 'Your name' : 'Ton nom';

  String get nameHint => _isEn ? 'Write your name here' : 'Écris ton nom ici';

  String get ageLabel => _isEn ? 'Your age' : 'Ton âge';

  String get ageHint => _isEn ? 'Write your age here' : 'Écris ton âge ici';
}
