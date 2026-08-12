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
  theme_2.json               Le Message des 3B — 120 questions réelles (niveaux 1-2, étapes 1-5)
  theme_3.json                Instant ZTF — 432 questions réelles (3 niveaux x 12 étapes x 12 questions)
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

**Contenu actuel** :
- `theme_1.json` (Le Camp des Agneaux) : seul le niveau 1 (12 étapes) contient
  des questions, générées automatiquement à titre d'exemple pour valider le
  format (énoncés génériques de culture générale — couleurs, formes, animaux,
  calcul). À remplacer par le vrai contenu EFDET.
- `theme_2.json` (Le Message des 3B) : **120 questions réelles** (version
  française), fournies par l'utilisateur (QCM sur les messages de Beijing,
  Bertoua et Brazzaville). Le document source ne contient que 2 niveaux de
  difficulté (facile 3-5 ans, plus difficile 6-8 ans, 60 questions chacun) ;
  ils remplissent les étapes 1 à 5 des niveaux 1 et 2, les étapes 6 à 12 et le
  niveau 3 restent "Bientôt disponible" en attendant le reste du contenu. Les
  questions du document n'ont que 3 propositions (A/B/C) au lieu de 4, et la
  bonne réponse y était systématiquement en position A : les options ont donc
  été mélangées (mêmes énoncés et réponses, ordre randomisé) pour que le quiz
  reste réellement discriminant plutôt que "toujours répondre A". La version
  anglaise du même document n'a pas été intégrée, l'app n'étant pas encore
  localisée.
- `theme_3.json` (Instant ZTF) : **432 questions réelles**, fournies par
  l'utilisateur (quiz à choix multiples sur "Childhood Years" / "From His
  Lips" du Pr Zacharias Tanee Fomum). Les 3 niveaux de difficulté du document
  source (facile / moyen / difficile) sont mappés sur les 3 niveaux de l'app ;
  chaque niveau est découpé en 12 étapes de 12 questions dans l'ordre du
  document, avec les bonnes réponses reprises du tableau de correction fourni.

Le reste du contenu du Camp des Agneaux et du Message des 3B reste une
dépendance critique du planning (§10) tant qu'EFDET ne l'a pas fourni.

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
