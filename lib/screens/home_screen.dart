import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../services/app_service.dart';
import '../../models/verb_model.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';
import 'browse_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(
      builder: (context, svc, _) {
        if (!svc.isInitialized) {
          return const Scaffold(
            backgroundColor: AppColors.bg,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHeader(context, svc),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildStreakXpRow(context, svc),
                        const SizedBox(height: 20),
                        _buildDailyGoalCard(context, svc),
                        const SizedBox(height: 20),
                        _buildStatsRow(svc),
                        const SizedBox(height: 28),
                        _sectionLabel('Study Modes'),
                        const SizedBox(height: 14),
                        _buildModeCards(context, svc),
                        const SizedBox(height: 28),
                        _sectionLabel('Categories'),
                        const SizedBox(height: 14),
                        _buildCategoryChips(context, svc),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, AppService svc) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1040), AppColors.bg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'हिंदी Verbs Master',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                          ).createShader(const Rect.fromLTWH(0, 0, 200, 30)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '100 verbs · SM-2 Spaced Repetition',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Level badge
                GestureDetector(
                  onTap: () => _showLevelDialog(context, svc),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          'Lv ${svc.level}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // XP Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'XP: ${svc.xp}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Next Lv: ${svc.level * AppService.xpPerLevel} XP',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: svc.levelProgress,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  // ─── Streak + XP row ────────────────────────────────────────────────────────

  Widget _buildStreakXpRow(BuildContext context, AppService svc) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: '🔥',
            value: '${svc.streak}',
            label: 'Day Streak',
            color: const Color(0xFFFF6B35),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: '✅',
            value: '${svc.todayCorrect}',
            label: 'Today',
            color: AppColors.green,
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0),
        ),
      ],
    );
  }

  // ─── Daily Goal Card ────────────────────────────────────────────────────────

  Widget _buildDailyGoalCard(BuildContext context, AppService svc) {
    final pct = svc.dailyProgress;
    final met = svc.dailyGoalMet;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: met
              ? [const Color(0xFF1A3A2A), const Color(0xFF0D1F16)]
              : [AppColors.card, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              met ? AppColors.green.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 40,
            lineWidth: 7,
            percent: pct,
            center: Text(
              met ? '🎉' : '${(pct * 100).round()}%',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            progressColor: met ? AppColors.green : AppColors.primary,
            backgroundColor: AppColors.border,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 800,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  met ? '🌟 Goal Crushed!' : 'Daily Goal',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  met
                      ? 'Amazing work today!'
                      : '${svc.todayCorrect} / ${AppService.dailyGoal} verbs reviewed',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (!met) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.border,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 5,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  // ─── Stats Row ───────────────────────────────────────────────────────────────

  Widget _buildStatsRow(AppService svc) {
    return Row(
      children: [
        _MiniStat(
          value: '${svc.masteredVerbs.length}',
          label: 'Mastered',
          icon: Icons.military_tech_rounded,
          color: AppColors.gold,
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(width: 10),
        _MiniStat(
          value: '${svc.learningVerbs.length}',
          label: 'Learning',
          icon: Icons.school_rounded,
          color: AppColors.accent,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(width: 10),
        _MiniStat(
          value: '${svc.newVerbs.length}',
          label: 'New',
          icon: Icons.fiber_new_rounded,
          color: AppColors.textSecondary,
        ).animate().fadeIn(delay: 250.ms),
        const SizedBox(width: 10),
        _MiniStat(
          value: '${svc.dueVerbs.length}',
          label: 'Due Now',
          icon: Icons.notifications_active_rounded,
          color: svc.dueVerbs.isNotEmpty
              ? const Color(0xFFFF6B35)
              : AppColors.green,
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  // ─── Mode Cards ─────────────────────────────────────────────────────────────

  Widget _buildModeCards(BuildContext context, AppService svc) {
    return Column(
      children: [
        // Primary: Flashcards
        _ModeCard(
          icon: '🃏',
          title: 'Smart Flashcards',
          subtitle: '${svc.dueVerbs.length} due · Spaced Repetition (SM-2)',
          gradient: const [Color(0xFF5A2FBF), Color(0xFF7C6FFF)],
          onTap: svc.dueVerbs.isEmpty
              ? null
              : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FlashcardScreen(verbs: svc.dueVerbs),
                    ),
                  ),
          badge: svc.dueVerbs.isNotEmpty ? '${svc.dueVerbs.length}' : null,
        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 12),
        Row(
          children: [
            // Quiz
            Expanded(
              child: _SmallModeCard(
                icon: '🎯',
                title: 'Quiz',
                subtitle: 'Test yourself',
                color: AppColors.accent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizScreen()),
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
            ),
            const SizedBox(width: 12),
            // Browse
            Expanded(
              child: _SmallModeCard(
                icon: '📖',
                title: 'Browse',
                subtitle: 'All 100 verbs',
                color: const Color(0xFF00BCD4),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BrowseScreen()),
                ),
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Category Chips ─────────────────────────────────────────────────────────

  Widget _buildCategoryChips(BuildContext context, AppService svc) {
    final categories = VerbCategory.values;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final count = svc.verbs.where((v) => v.category == cat).length;
        final mastered =
            svc.verbs.where((v) => v.category == cat && v.isMastered).length;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BrowseScreen(filterCategory: cat),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cat.color.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.label,
                      style: TextStyle(
                        color: cat.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$mastered/$count',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      ),
    );
  }

  void _showLevelDialog(BuildContext context, AppService svc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Level ${svc.level}',
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total XP: ${svc.xp}',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text('Mastered: ${svc.masteredVerbs.length}/100 verbs',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text('Sessions: ${svc.totalSessions}',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppColors.card,
                    title: const Text('Reset All Progress?',
                        style: TextStyle(color: AppColors.textPrimary)),
                    content: const Text(
                        'This will delete all your learning progress. Cannot be undone.',
                        style: TextStyle(color: AppColors.textSecondary)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Reset',
                              style: TextStyle(color: AppColors.red))),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  context.read<AppService>().resetAllProgress();
                }
              },
              child: const Text('Reset Progress',
                  style: TextStyle(color: AppColors.red, fontSize: 13)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: color),
            ),
            Text(
              label,
              style:
                  const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback? onTap;
  final String? badge;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.5 : 1.0,
        duration: 200.ms,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient.last.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white70, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallModeCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SmallModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
