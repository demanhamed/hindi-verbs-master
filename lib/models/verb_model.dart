import 'package:flutter/material.dart';

// ─── Categories ───────────────────────────────────────────────────────────────

enum VerbCategory { movement, communication, emotion, cognition, physical, social }

extension VerbCategoryX on VerbCategory {
  String get label {
    switch (this) {
      case VerbCategory.movement:      return 'Movement';
      case VerbCategory.communication: return 'Communication';
      case VerbCategory.emotion:       return 'Emotion';
      case VerbCategory.cognition:     return 'Cognition';
      case VerbCategory.physical:      return 'Physical';
      case VerbCategory.social:        return 'Social';
    }
  }

  Color get color {
    switch (this) {
      case VerbCategory.movement:      return const Color(0xFF4CAF50);
      case VerbCategory.communication: return const Color(0xFF2196F3);
      case VerbCategory.emotion:       return const Color(0xFFE91E63);
      case VerbCategory.cognition:     return const Color(0xFF9C27B0);
      case VerbCategory.physical:      return const Color(0xFFFF9800);
      case VerbCategory.social:        return const Color(0xFF00BCD4);
    }
  }

  Color get lightColor => color.withValues(alpha: 0.15);

  String get emoji {
    switch (this) {
      case VerbCategory.movement:      return '🏃';
      case VerbCategory.communication: return '💬';
      case VerbCategory.emotion:       return '❤️';
      case VerbCategory.cognition:     return '🧠';
      case VerbCategory.physical:      return '✋';
      case VerbCategory.social:        return '🤝';
    }
  }
}

// ─── VerbModel ────────────────────────────────────────────────────────────────

class VerbModel {
  final int id;
  final String hindi;
  final String romanized;
  final String english;
  final VerbCategory category;
  String? audioPath;

  // SM-2 SRS fields
  int repetitions;
  double easeFactor;
  int intervalDays;
  DateTime? nextReview;
  int correctCount;
  int incorrectCount;
  bool isMastered;
  DateTime? lastReviewed;

  VerbModel({
    required this.id,
    required this.hindi,
    required this.romanized,
    required this.english,
    required this.category,
    this.audioPath,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 1,
    this.nextReview,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.isMastered = false,
    this.lastReviewed,
  });

  bool get isDueForReview =>
      nextReview == null || DateTime.now().isAfter(nextReview!);

  bool get isNew => repetitions == 0 && correctCount == 0;

  int get accuracy {
    final total = correctCount + incorrectCount;
    if (total == 0) return 0;
    return ((correctCount / total) * 100).round();
  }

  int get totalReviews => correctCount + incorrectCount;

  String get difficultyLabel {
    if (isMastered) return 'Mastered';
    if (repetitions == 0) return 'New';
    if (intervalDays <= 2) return 'Learning';
    if (intervalDays <= 10) return 'Reviewing';
    return 'Known';
  }

  Color get difficultyColor {
    if (isMastered) return const Color(0xFF4CAF50);
    if (repetitions == 0) return const Color(0xFF9E9E9E);
    if (intervalDays <= 2) return const Color(0xFFFF5722);
    if (intervalDays <= 10) return const Color(0xFFFF9800);
    return const Color(0xFF2196F3);
  }

  /// SM-2 algorithm: quality 0–5
  ///   0 = complete blackout
  ///   1 = wrong, familiar
  ///   2 = wrong, easy to recall after seeing answer
  ///   3 = correct with serious difficulty
  ///   4 = correct after hesitation
  ///   5 = perfect response
  void updateSRS(int quality) {
    assert(quality >= 0 && quality <= 5);

    if (quality >= 3) {
      if (repetitions == 0) {
        intervalDays = 1;
      } else if (repetitions == 1) {
        intervalDays = 6;
      } else {
        intervalDays = (intervalDays * easeFactor).round();
      }
      repetitions++;
      correctCount++;
    } else {
      repetitions = 0;
      intervalDays = 1;
      incorrectCount++;
    }

    easeFactor = easeFactor +
        (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (easeFactor < 1.3) easeFactor = 1.3;
    if (easeFactor > 2.5) easeFactor = 2.5;

    nextReview = DateTime.now().add(Duration(days: intervalDays));
    lastReviewed = DateTime.now();
    isMastered = repetitions >= 5 && accuracy >= 80;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'audioPath': audioPath,
        'repetitions': repetitions,
        'easeFactor': easeFactor,
        'intervalDays': intervalDays,
        'nextReview': nextReview?.toIso8601String(),
        'correctCount': correctCount,
        'incorrectCount': incorrectCount,
        'isMastered': isMastered,
        'lastReviewed': lastReviewed?.toIso8601String(),
      };

  VerbModel copyWithProgress(Map<String, dynamic> json) => VerbModel(
        id: id,
        hindi: hindi,
        romanized: romanized,
        english: english,
        category: category,
        audioPath: json['audioPath'] as String?,
        repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
        easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
        intervalDays: (json['intervalDays'] as num?)?.toInt() ?? 1,
        nextReview: json['nextReview'] != null
            ? DateTime.tryParse(json['nextReview'] as String)
            : null,
        correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
        incorrectCount: (json['incorrectCount'] as num?)?.toInt() ?? 0,
        isMastered: (json['isMastered'] as bool?) ?? false,
        lastReviewed: json['lastReviewed'] != null
            ? DateTime.tryParse(json['lastReviewed'] as String)
            : null,
      );
}
