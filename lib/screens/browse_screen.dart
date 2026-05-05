import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/verb_model.dart';
import '../../services/app_service.dart';
import '../../widgets/audio_button.dart';

class BrowseScreen extends StatefulWidget {
  final VerbCategory? filterCategory;

  const BrowseScreen({super.key, this.filterCategory});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String _search = '';
  VerbCategory? _selectedCategory;
  String _sortBy = 'order'; // 'order' | 'accuracy' | 'due'
  bool _masteredOnly = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.filterCategory;
  }

  List<VerbModel> _filtered(List<VerbModel> all) {
    var list = all.where((v) {
      final q = _search.toLowerCase();
      final matchSearch = q.isEmpty ||
          v.hindi.contains(q) ||
          v.english.toLowerCase().contains(q) ||
          v.romanized.toLowerCase().contains(q);
      final matchCat =
          _selectedCategory == null || v.category == _selectedCategory;
      final matchMastered = !_masteredOnly || v.isMastered;
      return matchSearch && matchCat && matchMastered;
    }).toList();

    switch (_sortBy) {
      case 'accuracy':
        list.sort((a, b) => b.accuracy.compareTo(a.accuracy));
        break;
      case 'due':
        list.sort((a, b) {
          if (a.isDueForReview != b.isDueForReview) {
            return a.isDueForReview ? -1 : 1;
          }
          return a.id.compareTo(b.id);
        });
        break;
      default:
        list.sort((a, b) => a.id.compareTo(b.id));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<AppService>();
    final filtered = _filtered(svc.verbs);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Browse Verbs'),
        actions: [
          _SortButton(
            current: _sortBy,
            onChanged: (v) => setState(() => _sortBy = v),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search Hindi, English, romanized…',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Category filter chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _CatChip(
                  label: 'All',
                  selected: _selectedCategory == null,
                  color: AppColors.primary,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 6),
                ...VerbCategory.values.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _CatChip(
                        label: '${cat.emoji} ${cat.label}',
                        selected: _selectedCategory == cat,
                        color: cat.color,
                        onTap: () => setState(() => _selectedCategory =
                            _selectedCategory == cat ? null : cat),
                      ),
                    )),
              ],
            ),
          ),

          // Mastered toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${filtered.length} verbs',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  'Mastered only',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(width: 6),
                Switch(
                  value: _masteredOnly,
                  onChanged: (v) => setState(() => _masteredOnly = v),
                  activeColor: AppColors.gold,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No verbs found',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final verb = filtered[i];
                      return _VerbListTile(
                        verb: verb,
                        svc: svc,
                        delay: (i * 20).clamp(0, 300),
                        onTap: () => _showVerbDetail(context, verb, svc),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showVerbDetail(BuildContext context, VerbModel verb, AppService svc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: svc,
        child: _VerbDetailSheet(verb: verb),
      ),
    );
  }
}

// ─── Verb Detail Bottom Sheet ─────────────────────────────────────────────────

class _VerbDetailSheet extends StatelessWidget {
  final VerbModel verb;

  const _VerbDetailSheet({required this.verb});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<AppService>();
    // Get live version of the verb from service
    final live =
        svc.verbs.firstWhere((v) => v.id == verb.id, orElse: () => verb);
    final cat = live.category;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => SingleChildScrollView(
        controller: controller,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Category + Number
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: cat.color.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '${cat.emoji}  ${cat.label}',
                      style: TextStyle(
                          color: cat.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '#${live.id}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  if (live.isMastered)
                    const Text('🏅', style: TextStyle(fontSize: 20)),
                ],
              ),

              const SizedBox(height: 20),

              // Hindi large
              Text(
                live.hindi,
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                live.romanized,
                style: TextStyle(
                  fontSize: 18,
                  color: cat.color,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // English meaning
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Text(
                  live.english,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Audio section
              const Text(
                'Your Voice Recording',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 10),
              AudioButton(verb: live, svc: svc),

              const SizedBox(height: 28),

              // Progress stats
              const Text(
                'Learning Progress',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _StatBox(
                          label: 'Status',
                          value: live.difficultyLabel,
                          color: live.difficultyColor)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _StatBox(
                          label: 'Accuracy',
                          value: '${live.accuracy}%',
                          color: live.accuracy >= 70
                              ? AppColors.green
                              : AppColors.accent)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _StatBox(
                          label: 'Interval',
                          value: '${live.intervalDays}d',
                          color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _StatBox(
                          label: 'Correct',
                          value: '${live.correctCount}',
                          color: AppColors.green)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _StatBox(
                          label: 'Missed',
                          value: '${live.incorrectCount}',
                          color: AppColors.red)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _StatBox(
                          label: 'Reviews',
                          value: '${live.totalReviews}',
                          color: const Color(0xFF00BCD4))),
                ],
              ),

              if (live.nextReview != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Next review: ${_formatDate(live.nextReview!)}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.isNegative || diff.inHours < 1) return 'Now';
    if (diff.inHours < 24) return 'In ${diff.inHours}h';
    if (diff.inDays == 1) return 'Tomorrow';
    return 'In ${diff.inDays} days';
  }
}

// ─── Verb List Tile ──────────────────────────────────────────────────────────

class _VerbListTile extends StatelessWidget {
  final VerbModel verb;
  final AppService svc;
  final int delay;
  final VoidCallback onTap;

  const _VerbListTile({
    required this.verb,
    required this.svc,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cat = verb.category;
    final isPlayingThis = svc.isPlaying && svc.playingVerbId == verb.id;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: verb.isDueForReview
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // Category color bar
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: cat.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // Hindi + English
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        verb.hindi,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (verb.isMastered)
                        const Text('🏅', style: TextStyle(fontSize: 14)),
                      if (verb.isDueForReview && !verb.isNew)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Due',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    verb.english,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Number + audio icon
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '#${verb.id}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 6),
                if (verb.audioPath != null)
                  GestureDetector(
                    onTap: () {
                      if (isPlayingThis) {
                        svc.stopAudio();
                      } else {
                        svc.playAudio(verb.id, verb.audioPath!);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isPlayingThis
                            ? AppColors.green.withValues(alpha: 0.2)
                            : AppColors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlayingThis
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.green,
                        size: 16,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.mic_none_rounded,
                      color: AppColors.border, size: 16),
              ],
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: delay), duration: 200.ms),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _CatChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : AppColors.border, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _SortButton({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      icon: const Icon(Icons.sort_rounded, color: AppColors.textSecondary),
      onSelected: onChanged,
      itemBuilder: (_) => [
        _menuItem('order', '🔢 By Number', current),
        _menuItem('accuracy', '📊 By Accuracy', current),
        _menuItem('due', '⏰ By Due Date', current),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(String value, String label, String current) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  color: current == value
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontSize: 14)),
          if (current == value) ...[
            const Spacer(),
            const Icon(Icons.check_rounded, color: AppColors.primary, size: 16),
          ]
        ],
      ),
    );
  }
}
