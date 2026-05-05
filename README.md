# 🇮🇳 Hindi Verbs Master

A gamified Flutter app to memorize all 100 Hindi verbs using **Spaced Repetition (SM-2)**, voice recording, and quiz mode — built for rapid, long-lasting retention.

---

## ✨ Techniques Used (Why They Work)

| Technique | Screen | Why it sticks |
|-----------|--------|---------------|
| **SM-2 Spaced Repetition** | Flashcards | Reviews only what you're about to forget — proven to 10× retention |
| **Active Recall** | Quiz (MCQ) | Forces retrieval from memory, not passive reading |
| **Bidirectional Testing** | Quiz | Alternates Hindi→English and English→Hindi to prevent one-way cue dependency |
| **Self-Voice Recording** | All screens | Hearing YOUR OWN voice triggers stronger memory encoding |
| **Categorization** | Browse, Home | Semantic grouping (movement, emotion…) aids chunking |
| **XP + Streak + Level** | Home | Dopamine loops keep daily sessions habit-forming |
| **Confetti on goals** | Flashcard, Quiz | Positive reinforcement moment at key milestones |
| **Daily Goal (15 reviews)** | Home | Small achievable goal beats "study everything" overwhelm |
| **Difficulty ratings** | Flashcard | Again / Hard / Good / Easy maps 1:1 to SM-2 quality 0/2/4/5 |
| **Romanization** | All | Bridges sound-gap so you learn pronunciation simultaneously |

---

## 🚀 Setup

### 1. Create Flutter project & copy files
```bash
flutter create hindi_verbs_master
cd hindi_verbs_master
# Replace pubspec.yaml and lib/ with the provided files
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Android permissions
Add to `android/app/src/main/AndroidManifest.xml` inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

Also set `minSdkVersion 21` in `android/app/build.gradle`.

### 4. iOS permissions
Add to `ios/Runner/Info.plist` inside `<dict>`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record your voice pronunciations for each Hindi verb.</string>
```

### 5. Run
```bash
flutter run
```

---

## 📁 Project Structure

```
lib/
├── main.dart                  # App entry, theme (AppColors)
├── data/
│   └── verbs_data.dart        # All 100 verbs with categories
├── models/
│   └── verb_model.dart        # VerbModel + SM-2 algorithm
├── services/
│   └── app_service.dart       # State: SRS, audio, XP, streaks
├── screens/
│   ├── home_screen.dart       # Dashboard: streak, XP, modes
│   ├── flashcard_screen.dart  # Flip cards + SRS rating
│   ├── quiz_screen.dart       # 4-option MCQ with animations
│   └── browse_screen.dart     # Search + filter + detail sheet
└── widgets/
    ├── audio_button.dart      # Record / Play / Re-record / Delete
    └── verb_card_face.dart    # Front + back card faces
```

---

## 🎯 How to Use

1. **Start with Flashcards** — tap the card to reveal the answer, then honestly rate yourself:
   - 😵 **Again** = forgot completely → shown again today
   - 😓 **Hard** = got it wrong or barely right → shown in 1 day
   - 🙂 **Good** = remembered with some effort → shown in ~4 days
   - 🔥 **Easy** = knew it instantly → shown in ~10 days

2. **Record your voice** — on the back of each card, tap "Record Your Voice". Say the verb and its meaning out loud. You can re-record anytime.

3. **Quiz yourself** — jump into Quiz Mode for rapid-fire 4-option MCQs. Build streak combos for bonus XP.

4. **Check Browse** — tap any verb for full detail: stats, audio, next review date.

5. **Daily goal: 15 reviews** — once hit, the progress ring turns gold. Maintain your streak!

---

## 📦 Key Dependencies

| Package | Use |
|---------|-----|
| `provider` | State management |
| `record` | Microphone recording (AAC/M4A) |
| `audioplayers` | Playback of recorded files |
| `shared_preferences` | Persist SRS progress & XP |
| `path_provider` | Device file path for audio storage |
| `permission_handler` | Runtime mic permission request |
| `flutter_animate` | Slide/fade/scale/shimmer animations |
| `percent_indicator` | Circular + linear progress indicators |
| `confetti` | Celebration particles |
| `google_fonts` | Poppins typeface |

---

## 🔮 Possible Extensions

- **Offline TTS** using `flutter_tts` for auto-pronunciation before you record your own
- **Sentence examples** from a curated JSON file per verb
- **Handwriting practice** using `signature` package
- **Firebase sync** to preserve progress across devices
- **Widget** (Android home screen) showing today's due count
