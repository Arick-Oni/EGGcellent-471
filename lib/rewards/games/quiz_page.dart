import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  static final List<_Q> _q = <_Q>[
    const _Q('What temp should fresh eggs be stored at?',
        ['4°C', '10–12°C', 'Room temp'], 0),
    const _Q('Ideal broiler age for market?',
        ['2–3 weeks', '5–7 weeks', '10–12 weeks'], 1),
    const _Q('Which improves listing trust?',
        ['Blurry photos', 'Clear photos & details', 'No price info'], 1),
    const _Q('Normal hatchability for good eggs?',
        ['20–30%', '60–70%', '80–90%'], 2),
    const _Q('A sign of healthy chicks:',
        ['Active & bright eyes', 'Wet feathers', 'Lethargic'], 0),
  ];

  final List<int?> _chosen = List<int?>.filled(_q.length, null);

  bool _submitting = false;

  // Cooldown
  bool _loadingCooldown = true;
  bool _isTodayAlreadyPlayed = false;
  DateTime? _lastQuizDay;

  // Simple animation for submit button
  late final AnimationController _btnCtl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 380));
  late final Animation<double> _btnScale = Tween<double>(begin: 1.0, end: 0.98)
      .animate(CurvedAnimation(parent: _btnCtl, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    _loadCooldown();
  }

  @override
  void dispose() {
    _btnCtl.dispose();
    super.dispose();
  }

  Future<void> _loadCooldown() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _loadingCooldown = false;
        _isTodayAlreadyPlayed = false;
        _lastQuizDay = null;
      });
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('gamesSummary')
          .doc('summary')
          .get();

      final ts = snap.data()?['lastQuizAt'];
      if (ts is Timestamp) {
        final d = ts.toDate();
        final day = DateTime(d.year, d.month, d.day);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        setState(() {
          _lastQuizDay = day;
          _isTodayAlreadyPlayed = day == today;
          _loadingCooldown = false;
        });
      } else {
        setState(() {
          _lastQuizDay = null;
          _isTodayAlreadyPlayed = false;
          _loadingCooldown = false;
        });
      }
    } catch (_) {
      setState(() {
        _loadingCooldown = false;
        _isTodayAlreadyPlayed = false;
        _lastQuizDay = null;
      });
    }
  }

  bool get _allAnswered => !_chosen.any((c) => c == null);

  Future<void> _submit() async {
    if (_submitting) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      messenger
          .showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      return;
    }
    if (!_allAnswered) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Please answer all questions.')));
      return;
    }
    if (_isTodayAlreadyPlayed) {
      messenger.showSnackBar(
          const SnackBar(content: Text('You already played the quiz today.')));
      return;
    }

    setState(() => _submitting = true);

    String msg;
    try {
      int correct = 0;
      for (int i = 0; i < _q.length; i++) {
        if (_chosen[i] == _q[i].correctIndex) correct++;
      }
      final int pts = correct * 5;

      final db = FirebaseFirestore.instance;
      final userRef = db.collection('users').doc(uid);
      final summaryRef = userRef.collection('rewardsSummary').doc('summary');
      final gamesSummaryRef = userRef.collection('gamesSummary').doc('summary');
      final txRef = userRef.collection('rewardTransactions').doc();

      await db.runTransaction((txn) async {
        txn.set(
          summaryRef,
          {
            'totalPoints': FieldValue.increment(pts),
            'lifetimePoints': FieldValue.increment(pts),
          },
          SetOptions(merge: true),
        );
        txn.set(txRef, {
          'type': 'quiz',
          'points': pts,
          'createdAt': Timestamp.now(),
          'meta': {'correct': correct, 'total': _q.length},
        });
        txn.set(
          gamesSummaryRef,
          {'lastQuizAt': Timestamp.fromDate(DateTime.now())},
          SetOptions(merge: true),
        );
      });

      msg = 'You scored $pts pts ($correct/${_q.length}).';
    } catch (e, st) {
      msg = 'Quiz submit failed: $e';
      if (kDebugMode) {
        debugPrint('quiz submit error: $e');
        debugPrintStack(stackTrace: st);
      }
    }

    if (!mounted) return;
    setState(() => _submitting = false);
    messenger.showSnackBar(SnackBar(content: Text(msg)));

    if (msg.startsWith('You scored')) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_loadingCooldown) {
      return Scaffold(
        appBar: AppBar(title: const Text('Poultry Quiz')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Poultry Quiz')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [scheme.surface, scheme.surfaceVariant.withOpacity(0.3)],
          ),
        ), // soft page gradient background [cards keep M3 look] [1][5]
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _HeaderBanner(
                isLocked: _isTodayAlreadyPlayed, lastDay: _lastQuizDay),
            const SizedBox(height: 12),
            for (int i = 0; i < _q.length; i++)
              _QuestionCard(
                index: i,
                data: _q[i],
                selected: _chosen[i],
                enabled: !_isTodayAlreadyPlayed,
                onPick: (v) => setState(() => _chosen[i] = v),
              ),
            const SizedBox(height: 8),
            ScaleTransition(
              scale: _btnScale,
              child: GestureDetector(
                onTapDown: (_) => _btnCtl.forward(),
                onTapCancel: () => _btnCtl.reverse(),
                onTapUp: (_) => _btnCtl.reverse(),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade600,
                        Colors.deepOrange.shade400,
                      ],
                    ), // gradient button look [18][14]
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed:
                        (_submitting || _isTodayAlreadyPlayed || !_allAnswered)
                            ? null
                            : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline),
                    label: const Text('Submit'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text('• +5 pts per correct answer  •  1 quiz attempt per day',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  final bool isLocked;
  final DateTime? lastDay;
  const _HeaderBanner({required this.isLocked, required this.lastDay});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final last = lastDay != null
        ? ' (${lastDay!.toIso8601String().substring(0, 10)})'
        : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            scheme.primary.withOpacity(0.25),
            Colors.amber.withOpacity(0.25)
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(isLocked ? Icons.lock_clock : Icons.quiz_outlined,
              color: isLocked ? Colors.orangeAccent : Colors.lightGreenAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isLocked
                  ? 'You already played today$last. Come back tomorrow!'
                  : 'Answer all questions to earn points.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final _Q data;
  final int? selected;
  final bool enabled;
  final ValueChanged<int> onPick;

  const _QuestionCard({
    required this.index,
    required this.data,
    required this.selected,
    required this.enabled,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.surfaceVariant.withOpacity(0.18),
                scheme.surface.withOpacity(0.0),
              ],
            ), // soft card gradient [2][1]
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with small tinted stripe
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: LinearGradient(
                            colors: [Colors.amber, Colors.deepOrangeAccent]),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Q${index + 1}. ${data.title}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (int opt = 0; opt < data.options.length; opt++)
                  RadioListTile<int>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(data.options[opt]),
                    value: opt,
                    groupValue: selected,
                    onChanged: enabled ? (v) => onPick(v!) : null,
                    activeColor: Colors.orangeAccent,
                    fillColor: MaterialStateColor.resolveWith(
                      (states) => states.contains(MaterialState.selected)
                          ? Colors.orangeAccent
                          : Colors.white30,
                    ), // custom radio color [6][12]
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Q {
  final String title;
  final List<String> options;
  final int correctIndex;
  const _Q(this.title, this.options, this.correctIndex);
}
