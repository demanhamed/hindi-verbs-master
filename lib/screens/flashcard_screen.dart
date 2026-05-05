import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/verb_model.dart';
import '../../services/app_service.dart';
import '../../widgets/audio_button.dart';
import '../../widgets/verb_card_face.dart';

class FlashcardScreen extends StatefulWidget {
  final List<VerbModel> verbs;

  const FlashcardScreen({super.key, required this.verbs});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  late List<VerbModel> _queue;
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isAnimating = false;
  bool _sessionDone = false;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  late ConfettiController _confettiController;

  int _correctThisSession = 0;
  int _skippedThisSession = 0;

  @override
  void initState() {
    super.initState();
    _queue = List.from(widget.verbs);

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _flipAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: pi / 2)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: -pi / 2, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50),
    ]).animate(_flipController);

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    context.read<AppService>().incrementSessions();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // ─── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _flipCard() async {
    if (_isAnimating) return;
    _isAnimating = true;

    await _flipController.forward(from: 0);
    setState(() => _isFlipped = !_isFlipped);

    _isAnimating = false;
  }

  Future<void> _rateVerb(int quality) async {
    final svc = context.read<AppService>();
    final verb = _queue[_currentIndex];

    final goalJustMet = await svc.reviewVerb(verb, quality);
    if (quality >= 3) _correctThisSession++;

    if (goalJustMet && mounted) {
      _confettiController.play();
    }

    await Future.delayed(const Duration(milliseconds: 150));
    _advanceCard();
  }

  void _advanceCard() {
    if (_currentIndex >= _queue.length - 1) {
      setState(() => _sessionDone = true);
    } else {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
      _flipController.reset();
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: _sessionDone
            ? const Text('Session Complete')
            : Text(
                '${_currentIndex + 1} / ${_queue.length}',
                style: const TextStyle(
                    fontSize: 16, color: AppColors.textSecondary),
              ),
        actions: [
          if (!_sessionDone)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '✅ $_correctThisSession',
                  style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          _sessionDone ? _buildDoneScreen() : _buildCardSession(),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
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

  // ─── Session UI ──────────────────────────────────────────────────────────────

  Widget _buildCardSession() {
    final svc = context.watch<AppService>();
    final verb = _queue[_currentIndex];
    final progress = (_currentIndex + 1) / _queue.length;

    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                borderRadius: BorderRadius.circular(4),
                minHeight: 5,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _PillLabel(
                      label: verb.category.emoji + ' ' + verb.category.label,
                      color: verb.category.color),
                  const Spacer(),
                  _PillLabel(
                      label: verb.difficultyLabel, color: verb.difficultyColor),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Flip Card
        Expanded(
          child: GestureDetector(
            onTap: _isFlipped ? null : _flipCard,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_flipAnimation.value),
                    alignment: Alignment.center,
                    child: _isFlipped
                        ? VerbCardBack(verb: verb, svc: svc)
                        : VerbCardFront(verb: verb),
                  );
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Rating buttons (shown after flip)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: _isFlipped ? _buildRatingButtons() : _buildFlipHint(),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFlipHint() {
    return Padding(
      key: const ValueKey('hint'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _flipCard,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Tap card to reveal · Then rate yourself',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingButtons() {
    return Padding(
      key: const ValueKey('rating'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Text(
            'How well did you know it?',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _RateButton(
                label: 'Again',
                emoji: '😵',
                color: AppColors.red,
                onTap: () => _rateVerb(0),
              ),
              const SizedBox(width: 8),
              _RateButton(
                label: 'Hard',
                emoji: '😓',
                color: const Color(0xFFFF9800),
                onTap: () => _rateVerb(2),
              ),
              const SizedBox(width: 8),
              _RateButton(
                label: 'Good',
                emoji: '🙂',
                color: AppColors.primary,
                onTap: () => _rateVerb(4),
              ),
              const SizedBox(width: 8),
              _RateButton(
                label: 'Easy',
                emoji: '🔥',
                color: AppColors.green,
                onTap: () => _rateVerb(5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Done Screen ─────────────────────────────────────────────────────────────

  Widget _buildDoneScreen() {
    final total = _queue.length;
    final pct = total > 0 ? ((_correctThisSession / total) * 100).round() : 0;

    String message;
    String emoji;
    if (pct >= 90) {
      message = 'Outstanding!';
      emoji = '🏆';
    } else if (pct >= 70) {
      message = 'Great work!';
      emoji = '🎉';
    } else if (pct >= 50) {
      message = 'Keep going!';
      emoji = '💪';
    } else {
      message = 'More practice needed';
      emoji = '📚';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72))
                .animate()
                .scale(delay: 100.ms, duration: 400.ms),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              'Session complete',
              style:
                  const TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            // Score card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ScoreTile(
                      value: '$_correctThisSession',
                      label: 'Correct',
                      color: AppColors.green),
                  _ScoreTile(
                      value: '${total - _correctThisSession}',
                      label: 'Missed',
                      color: AppColors.red),
                  _ScoreTile(
                      value: '$pct%', label: 'Score', color: AppColors.primary),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Home',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final svc = context.read<AppService>();
                      final newQueue = svc.dueVerbs;
                      if (newQueue.isEmpty) {
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          _queue = List.from(newQueue);
                          _currentIndex = 0;
                          _isFlipped = false;
                          _sessionDone = false;
                          _correctThisSession = 0;
                        });
                        _flipController.reset();
                      }
                    },
                    child: const Text('Study Again'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _PillLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _PillLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _RateButton extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _RateButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _ScoreTile(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
