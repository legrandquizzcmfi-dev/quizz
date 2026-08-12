# Le Grand Quiz

Application mobile Flutter (Android & iOS) de quiz de culture générale
multi-thèmes, pour EFDET. Voir `Le_Grand_Quiz_-_Cahier_des_charges_Flutter.docx`
pour le cahier des charges complet.

## Structure du projet

```
lib/
  main.dart                 Point d'entrée : charge le contenu JSON + la progression
  app.dart                  MaterialApp, thème visuel
  app_data.dart             InheritedWidget partageant thèmes + progression
  models/                   Question, QuizStage, QuizLevel, QuizTheme, StageResult
  data/content_repository.dart   Lecture des fichiers JSON d'assets
  services/progress_service.dart Sauvegarde locale (SharedPreferences) + logique de déblocage
  screens/                  HomeScreen (onglets) → StagesScreen → QuizScreen → ResultScreen
  widgets/                  ProgressTile, StarsRow

assets/data/
  theme_1.json               Le Camp des Agneaux — Niveau 1 rempli (contenu d'exemple)
  theme_2.json               Le Message des 3B — structure vide, en attente de contenu
  theme_3.json                Instant ZTF — structure vide, en attente de contenu
```

## Contenu des questions

Chaque thème est un fichier JSON indépendant du code (§6, §8 du cahier des
charges), au format :

```json
{
  "themeId": "camp_des_agneaux",
  "title": "Le Camp des Agneaux",
  "levels": [
    {
      "index": 1,
      "stages": [
        {
          "index": 1,
          "questions": [
            {
              "id": "unique_id",
              "text": "Énoncé de la question ?",
              "options": ["Réponse A", "Réponse B", "Réponse C", "Réponse D"],
              "correctIndex": 0
            }
          ]
        }
      ]
    }
  ]
}
```

- 3 niveaux par thème, 12 étapes par niveau, 12 questions par étape.
- `correctIndex` est l'index (0 à 3) de la bonne réponse dans `options`.
- Un niveau/une étape sans `questions` s'affiche comme "Bientôt disponible"
  dans l'app plutôt que de bloquer.

**Contenu actuel** : seul `theme_1.json` (niveau 1, 12 étapes) contient des
questions, générées automatiquement à titre d'exemple pour valider le format
(énoncés génériques de culture générale — couleurs, formes, animaux, calcul).
Elles sont à remplacer par le vrai contenu EFDET (Camp des Agneaux, Message
des 3B, Instant ZTF), qui reste une dépendance critique du planning (§10).

## Logique de déblocage

Seuil retenu : 8 bonnes réponses sur 12 pour débloquer l'étape/le niveau
suivant (§13, point 1). La progression est sauvegardée uniquement sur
l'appareil (`shared_preferences`), sans compte ni synchronisation (§13,
point 2).

## Lancer le projet

```
flutter pub get
flutter run
```

## Points ouverts / à confirmer avec EFDET

- Nom définitif du projet ("Le Grand Quiz" est provisoire, §1).
- Thèmes définitifs des 3 onglets (§13, point 3).
- Contenu complet des 1 296 questions, au format JSON ci-dessus.
- Musique/ambiance sonore de fond et animations (§4.1) : pas encore
  implémentées, en attente des assets audio/graphiques et pour rester
  concentré sur le moteur de quiz en premier (§10, étape 1).
