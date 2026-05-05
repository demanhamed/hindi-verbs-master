import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/verb_model.dart';
import '../../data/verbs_data.dart';

class AppService extends ChangeNotifier {
  // ─── State ──────────────────────────────────────────────────────────────────

  List<VerbModel> _verbs = [];
  bool _isInitialized = false;

  // Gamification
  int _streak = 0;
  int _xp = 0;
  int _level = 1;
  int _todayCorrect = 0;
  int _totalSessions = 0;
  static const int dailyGoal = 15;
  static const int xpPerLevel = 300;

  // Audio state
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  int? _playingVerbId;
  int? _recordingVerbId;

  // ─── Getters ────────────────────────────────────────────────────────────────

  bool get isInitialized => _isInitialized;
  List<VerbModel> get verbs => _verbs;

  List<VerbModel> get dueVerbs {
    final due = _verbs.where((v) => v.isDueForReview).toList();
    // New cards first, then by next review date
    due.sort((a, b) {
      if (a.isNew != b.isNew) return a.isNew ? -1 : 1;
      final an = a.nextReview;
      final bn = b.nextReview;
      if (an == null && bn == null) return 0;
      if (an == null) return -1;
      if (bn == null) return 1;
      return an.compareTo(bn);
    });
    return due;
  }

  List<VerbModel> get newVerbs => _verbs.where((v) => v.isNew).toList();
  List<VerbModel> get masteredVerbs =>
      _verbs.where((v) => v.isMastered).toList();
  List<VerbModel> get learningVerbs =>
      _verbs.where((v) => !v.isNew && !v.isMastered).toList();

  int get streak => _streak;
  int get xp => _xp;
  int get level => _level;
  int get todayCorrect => _todayCorrect;
  int get totalSessions => _totalSessions;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  int? get playingVerbId => _playingVerbId;
  int? get recordingVerbId => _recordingVerbId;

  double get levelProgress {
    final base = (_level - 1) * xpPerLevel;
    final cap = _level * xpPerLevel;
    return ((_xp - base) / xpPerLevel).clamp(0.0, 1.0);
  }

  double get dailyProgress => (_todayCorrect / dailyGoal).clamp(0.0, 1.0);
  bool get dailyGoalMet => _todayCorrect >= dailyGoal;

  // ─── Init ───────────────────────────────────────────────────────────────────

  Future<void> init() async {
    await _loadStats();
    await _loadVerbs();
    _isInitialized = true;
    notifyListeners();
  }

  // ─── Verbs ──────────────────────────────────────────────────────────────────

  Future<void> _loadVerbs() async {
    final prefs = await SharedPreferences.getInstance();
    _verbs = buildVerbList().map((verb) {
      final raw = prefs.getString('verb_${verb.id}');
      if (raw != null) {
        try {
          return verb.copyWithProgress(jsonDecode(raw) as Map<String, dynamic>);
        } catch (_) {}
      }
      return verb;
    }).toList();
    notifyListeners();
  }

  Future<void> _saveVerb(VerbModel verb) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('verb_${verb.id}', jsonEncode(verb.toJson()));
  }

  VerbModel verbById(int id) => _verbs.firstWhere((v) => v.id == id);

  // ─── SRS Review ─────────────────────────────────────────────────────────────

  /// Returns true if daily goal was just reached (for confetti trigger)
  Future<bool> reviewVerb(VerbModel verb, int quality) async {
    final wasGoalMet = dailyGoalMet;

    verb.updateSRS(quality);

    if (quality >= 3) {
      _todayCorrect++;
      // XP: 10 base + 5 bonus per quality above 3, +20 if newly mastered
      int gained = 10 + ((quality - 3) * 5);
      if (verb.isMastered && verb.repetitions == 5) gained += 20;
      _xp += gained;
      _updateLevel();
    }

    final idx = _verbs.indexWhere((v) => v.id == verb.id);
    if (idx != -1) _verbs[idx] = verb;

    await _saveVerb(verb);
    await _saveStats();
    notifyListeners();

    return !wasGoalMet && dailyGoalMet;
  }

  void _updateLevel() {
    _level = (_xp ~/ xpPerLevel) + 1;
  }

  // ─── Audio Recording ────────────────────────────────────────────────────────

  Future<bool> startRecording(int verbId) async {
    try {
      // Request mic permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) return false;

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/verb_audio_$verbId.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      _isRecording = true;
      _recordingVerbId = verbId;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('startRecording error: $e');
      return false;
    }
  }

  Future<void> stopRecording(int verbId) async {
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      _recordingVerbId = null;

      if (path != null) {
        final idx = _verbs.indexWhere((v) => v.id == verbId);
        if (idx != -1) {
          _verbs[idx].audioPath = path;
          await _saveVerb(_verbs[idx]);
        }
      }
    } catch (e) {
      debugPrint('stopRecording error: $e');
      _isRecording = false;
    }
    notifyListeners();
  }

  Future<void> cancelRecording() async {
    try {
      await _recorder.cancel();
    } catch (_) {}
    _isRecording = false;
    _recordingVerbId = null;
    notifyListeners();
  }

  // ─── Audio Playback ─────────────────────────────────────────────────────────

  Future<void> playAudio(int verbId, String path) async {
    try {
      // Toggle off if same verb already playing
      if (_isPlaying && _playingVerbId == verbId) {
        await _player.stop();
        _isPlaying = false;
        _playingVerbId = null;
        notifyListeners();
        return;
      }

      if (_isPlaying) await _player.stop();

      _isPlaying = true;
      _playingVerbId = verbId;
      notifyListeners();

      await _player.play(DeviceFileSource(path));
      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
        _playingVerbId = null;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('playAudio error: $e');
      _isPlaying = false;
      _playingVerbId = null;
      notifyListeners();
    }
  }

  Future<void> stopAudio() async {
    await _player.stop();
    _isPlaying = false;
    _playingVerbId = null;
    notifyListeners();
  }

  Future<void> deleteRecording(int verbId) async {
    final idx = _verbs.indexWhere((v) => v.id == verbId);
    if (idx == -1) return;

    final path = _verbs[idx].audioPath;
    if (path != null) {
      try {
        final f = File(path);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }

    _verbs[idx].audioPath = null;
    await _saveVerb(_verbs[idx]);
    notifyListeners();
  }

  // ─── Quiz Helpers ────────────────────────────────────────────────────────────

  /// Returns 4 options (1 correct + 3 wrong) in random order.
  /// Returns the correct index within the returned list.
  ({List<VerbModel> options, int correctIndex}) quizOptions(VerbModel verb) {
    final rng = Random();
    final pool = [..._verbs]..remove(verb);
    pool.shuffle(rng);
    final distractors = pool.take(3).toList();
    final options = [...distractors, verb]..shuffle(rng);
    return (options: options, correctIndex: options.indexOf(verb));
  }

  // ─── Stats Persistence ───────────────────────────────────────────────────────

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    _xp = prefs.getInt('xp') ?? 0;
    _level = (_xp ~/ xpPerLevel) + 1;
    _streak = prefs.getInt('streak') ?? 0;
    _totalSessions = prefs.getInt('totalSessions') ?? 0;

    final lastDate = prefs.getString('lastDate');
    final today = _dateKey(DateTime.now());

    if (lastDate == today) {
      _todayCorrect = prefs.getInt('todayCorrect') ?? 0;
    } else {
      // New day logic
      final yesterday =
          _dateKey(DateTime.now().subtract(const Duration(days: 1)));
      if (lastDate == yesterday) {
        final yc = prefs.getInt('todayCorrect') ?? 0;
        if (yc > 0) _streak++;
      } else if (lastDate != null) {
        _streak = 0; // broke the chain
      }
      _todayCorrect = 0;
      await prefs.setString('lastDate', today);
      await prefs.setInt('streak', _streak);
    }
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('xp', _xp);
    await prefs.setInt('streak', _streak);
    await prefs.setInt('todayCorrect', _todayCorrect);
    await prefs.setInt('totalSessions', _totalSessions);
  }

  Future<void> incrementSessions() async {
    _totalSessions++;
    await _saveStats();
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  Future<void> resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _streak = 0;
    _xp = 0;
    _level = 1;
    _todayCorrect = 0;
    _totalSessions = 0;
    await _loadVerbs();
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
}
