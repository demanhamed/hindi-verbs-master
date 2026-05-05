import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../main.dart';
import '../../models/verb_model.dart';
import '../../services/app_service.dart';
import 'audio_button.dart';

// ─── Front Face (Hindi + hint) ────────────────────────────────────────────────

class VerbCardFront extends StatelessWidget {
  final VerbModel verb;

  const VerbCardFront({super.key, required this.verb});

  @override
  Widget build(BuildContext context) {
    final cat = verb.category;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cat.color.withValues(alpha: 0.18),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cat.color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: cat.color.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cat.color.withValues(alpha: 0.4)),
            ),
            child: Text(
              '${cat.emoji}  ${cat.label}',
              style: TextStyle(
                  color: cat.color, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 32),

          // Number badge
          Text(
            '#${verb.id}',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),

          // Main Hindi text
          Text(
            verb.hindi,
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 200.ms),

          const SizedBox(height: 12),

          // Romanization
          Text(
            verb.romanized,
            style: TextStyle(
              fontSize: 18,
              color: cat.color.withValues(alpha: 0.85),
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 40),

          // Tap hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_rounded,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  size: 16),
              const SizedBox(width: 6),
              Text(
                'Tap to flip',
                style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Back Face (English meaning + audio + stats) ──────────────────────────────

class VerbCardBack extends StatelessWidget {
  final VerbModel verb;
  final AppService svc;

  const VerbCardBack({super.key, required this.verb, required this.svc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark.withValues(alpha: 0.25),
            AppColors.card,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hindi (smaller)
            Text(
              verb.hindi,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              verb.romanized,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),

            // English meaning
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                verb.english,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ).animate().scale(duration: 250.ms, curve: Curves.easeOut),

            const SizedBox(height: 28),

            // Audio button
            AudioButton(verb: verb, svc: svc),

            const SizedBox(height: 24),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoTile(
                  label: 'Accuracy',
                  value: '${verb.accuracy}%',
                  icon: Icons.analytics_rounded,
                  color:
                      verb.accuracy >= 70 ? AppColors.green : AppColors.accent,
                ),
                _InfoTile(
                  label: 'Reviews',
                  value: '${verb.totalReviews}',
                  icon: Icons.loop_rounded,
                  color: AppColors.primary,
                ),
                _InfoTile(
                  label: 'Interval',
                  value: '${verb.intervalDays}d',
                  icon: Icons.calendar_today_rounded,
                  color: const Color(0xFF00BCD4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 15, fontWeight: FontWeight.w700)),
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}
