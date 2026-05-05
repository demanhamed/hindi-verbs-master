import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/verb_model.dart';
import '../../services/app_service.dart';

/// Multi-state audio widget:
///  - No audio: shows "Record Your Voice" button
///  - Has audio + not recording: shows Play + Re-record + Delete
///  - Recording active: shows animated mic + Stop button
class AudioButton extends StatelessWidget {
  final VerbModel verb;
  final AppService? svc;

  const AudioButton({super.key, required this.verb, this.svc});

  @override
  Widget build(BuildContext context) {
    final service = svc ?? context.watch<AppService>();
    final isRecordingThis =
        service.isRecording && service.recordingVerbId == verb.id;
    final isPlayingThis = service.isPlaying && service.playingVerbId == verb.id;
    final hasAudio = verb.audioPath != null;

    if (isRecordingThis) {
      return _buildRecordingState(context, service);
    }

    if (!hasAudio) {
      return _buildNoAudioState(context, service);
    }

    return _buildHasAudioState(context, service, isPlayingThis);
  }

  // ─── No Audio ────────────────────────────────────────────────────────────────

  Widget _buildNoAudioState(BuildContext context, AppService service) {
    return GestureDetector(
      onTap: () => service.startRecording(verb.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.mic_rounded, color: AppColors.accent, size: 22),
            SizedBox(width: 8),
            Text(
              'Record Your Voice',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
          duration: 2.seconds, color: AppColors.accent.withValues(alpha: 0.2)),
    );
  }

  // ─── Recording Active ────────────────────────────────────────────────────────

  Widget _buildRecordingState(BuildContext context, AppService service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated mic pulse
          const Icon(Icons.mic_rounded, color: AppColors.red, size: 22)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(end: 1.3, duration: 600.ms),
          const SizedBox(width: 8),
          const Text(
            'Recording...',
            style: TextStyle(
              color: AppColors.red,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => service.stopRecording(verb.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Stop',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Has Audio ───────────────────────────────────────────────────────────────

  Widget _buildHasAudioState(
      BuildContext context, AppService service, bool isPlayingThis) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play / Stop
        GestureDetector(
          onTap: () {
            if (isPlayingThis) {
              service.stopAudio();
            } else {
              service.playAudio(verb.id, verb.audioPath!);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isPlayingThis
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                    key: ValueKey(isPlayingThis),
                    color: AppColors.green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isPlayingThis ? 'Stop' : 'Play Voice',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Re-record button
        GestureDetector(
          onTap: () => _showReplaceDialog(context, service),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.mic_rounded,
                color: AppColors.textSecondary, size: 20),
          ),
        ),
      ],
    );
  }

  void _showReplaceDialog(BuildContext context, AppService service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  verb.hindi,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '· ${verb.english}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SheetOption(
              icon: Icons.fiber_manual_record_rounded,
              label: 'Re-record Voice',
              color: AppColors.accent,
              onTap: () {
                Navigator.pop(context);
                service.startRecording(verb.id);
              },
            ),
            const SizedBox(height: 10),
            _SheetOption(
              icon: Icons.delete_outline_rounded,
              label: 'Delete Recording',
              color: AppColors.red,
              onTap: () {
                Navigator.pop(context);
                service.deleteRecording(verb.id);
              },
            ),
            const SizedBox(height: 10),
            _SheetOption(
              icon: Icons.close_rounded,
              label: 'Cancel',
              color: AppColors.textSecondary,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 15)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
