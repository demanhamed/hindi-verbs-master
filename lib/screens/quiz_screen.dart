import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/verb_model.dart';
import '../../services/app_service.dart';

enum _AnswerState { unanswered, correct, wrong }

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<VerbModel>? _options;
  VerbModel? _currentVerb;
  int? _correctIndex;
  int? _selectedIndex;
  _AnswerState _answerState = _AnswerState.unanswered;

  int _score = 0;
  int _total = 0;
  int _streak = 0;
  int _bestStreak = 0;

  late ConfettiController _confetti;
  bool _showXpBurst = false;
  int _lastXp = 0;

  // Hindi display or English? Alternate to keep it spicy.
  bool _showHindi = true;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) => _nextQuestion());
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    final svc = context.read<AppService>();
    // Pick a random verb weighted toward due/learning cards
    final all = svc.verbs.toList()..shuffle();
    final verb = all.first;
    final result = svc.quizOptions(verb);

    setState(() {
      _currentVerb = verb;
      _options = result.options;
      _correctIndex = result.correctIndex;
      _selectedIndex = null;
      _answerState = _AnswerState.unanswered;
      _showHindi = _total % 2 == 0; // Alternate question direction
      _showXpBurst = false;
    });
  }

  Future<void> _selectAnswer(int index) async {
    if (_answerState != _AnswerState.unanswered) return;

    final isCorrect = index == _correctIndex;
    final svc = context.read<AppService>();

    setState(() {
      _selectedIndex = index;
      _answerState = isCorrect ? _AnswerState.correct : _AnswerState.wrong;
      _total++;
    });

    if (isCorrect) {
      _score++;
      _streak++;
      if (_streak > _bestStreak) _bestStreak = _streak;

      // SRS quality: 4 (correct with hesitation) or 5 if streak > 3
      final quality = _streak >= 3 ? 5 : 4;
      await svc.reviewVerb(_currentVerb!, quality);
      _lastXp = quality == 5 ? 25 : 10;

      if (_streak > 0 && _streak % 5 == 0) {
        _confetti.play();
      }

      setState(() => _showXpBurst = true);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) _nextQuestion();
    } else {
      _streak = 0;
      await svc.reviewVerb(_currentVerb!, 1);
      // Stay on card for 1.5s so user can see the right answer
      await Future.delayed(const Duration(milliseconds: 1600));
      if (mounted) _nextQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Quiz Mode'),
            const SizedBox(width: 12),
            if (_streak >= 3)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '$_streak',
                      style: const TextStyle(
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text('✅ ', style: TextStyle(fontSize: 15)),
                Text(
                  '$_score/$_total',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          // XP burst
          if (_showXpBurst)
            Positioned(
              top: 100,
              right: 32,
              child: Text(
                '+$_lastXp XP',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              )
                  .animate()
                  .slideY(begin: 0, end: -2, duration: 900.ms)
                  .fadeOut(delay: 500.ms),
            ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 25,
              colors: const [
                AppColors.primary,
                AppColors.accent,
                AppColors.gold,
                AppColors.green,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_currentVerb == null || _options == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    final verb = _currentVerb!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // Score bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _total > 0 ? _score / _total : 0,
                minHeight: 5,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.green),
              ),
            ),
            const SizedBox(height: 24),

            // Question direction label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: verb.category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: verb.category.color.withValues(alpha: 0.3)),
              ),
              child: Text(
                _showHindi
                    ? '${verb.category.emoji} What does this mean?'
                    : '${verb.category.emoji} Which Hindi verb means...',
                style: TextStyle(
                  color: verb.category.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Question Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    verb.category.color.withValues(alpha: 0.18),
                    AppColors.card,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: verb.category.color.withValues(alpha: 0.35),
                    width: 1.5),
              ),
              child: Column(
                children: [
                  Text(
                    _showHindi ? verb.hindi : verb.english,
                    style: TextStyle(
                      fontSize: _showHindi ? 52 : 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_showHindi) ...[
                    const SizedBox(height: 8),
                    Text(
                      verb.romanized,
                      style: TextStyle(
                        fontSize: 16,
                        color: verb.category.color.withValues(alpha: 0.85),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 250.ms).scale(
                begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

            const SizedBox(height: 24),

            // Answer Options
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(_options!.length, (i) {
                  final opt = _options![i];
                  return _OptionTile(
                    label: _showHindi ? opt.english : opt.hindi,
                    subLabel: _showHindi ? null : opt.romanized,
                    index: i,
                    state: _optionState(i),
                    onTap: () => _selectAnswer(i),
                  );
                }),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  _AnswerState _optionState(int index) {
    if (_answerState == _AnswerState.unanswered) {
      return _AnswerState.unanswered;
    }
    if (index == _correctIndex) return _AnswerState.correct;
    if (index == _selectedIndex) return _AnswerState.wrong;
    return _AnswerState.unanswered;
  }
}

// ─── Option Tile ──────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final String label;
  final String? subLabel;
  final int index;
  final _AnswerState state;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    this.subLabel,
    required this.index,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    Widget? trailingIcon;

    switch (state) {
      case _AnswerState.unanswered:
        bgColor = AppColors.card;
        borderColor = AppColors.border;
        textColor = AppColors.textPrimary;
        break;
      case _AnswerState.correct:
        bgColor = AppColors.green.withValues(alpha: 0.15);
        borderColor = AppColors.green;
        textColor = AppColors.green;
        trailingIcon = const Icon(Icons.check_circle_rounded,
            color: AppColors.green, size: 18);
        break;
      case _AnswerState.wrong:
        bgColor = AppColors.red.withValues(alpha: 0.12);
        borderColor = AppColors.red;
        textColor = AppColors.red;
        trailingIcon =
            const Icon(Icons.cancel_rounded, color: AppColors.red, size: 18);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (trailingIcon != null) ...[
              trailingIcon,
              const SizedBox(height: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: label.length > 20 ? 12 : 15,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (subLabel != null) ...[
              const SizedBox(height: 2),
              Text(
                subLabel!,
                style: TextStyle(
                    color: textColor.withValues(alpha: 0.6), fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      )
          .animate(target: state == _AnswerState.correct ? 1 : 0)
          .scaleXY(end: 1.03, duration: 200.ms),
    );
  }
}
