import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SpinWheelPage extends StatefulWidget {
  const SpinWheelPage({super.key});
  @override
  State createState() => _SpinWheelPageState();
}

class _SpinWheelPageState extends State<SpinWheelPage>
    with SingleTickerProviderStateMixin {
  bool _spinning = false;
  late AnimationController _controller;
  Animation<double>? _animation;
  double _currentRotation = 0.0;
  int? _lastPrize;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  final List<int> _prizes = [0, 10, 20, 30, 50];
  final _random = Random();

  static const int kDailySpinLimit = 10;

  @override
  void initState() {
    super.initState();
    // Target: 5 full turns in 1.0s (very fast) [Curves docs]
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // exactly 1 second
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) _onSpinEnd();
      });
    _resetSpinsIfNeeded();
  }

  Future<void> _resetSpinsIfNeeded() async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('gamesSummary')
        .doc('summary');

    final doc = await userRef.get();
    final now = DateTime.now();

    if (!doc.exists) {
      await userRef.set({
        'spinsToday': 0,
        'lastSpinAt': Timestamp.fromDate(DateTime(2000)),
        'tickets': 0,
      });
      return;
    }

    final data = doc.data()!;
    final last = (data['lastSpinAt'] as Timestamp?)?.toDate();
    if (last == null ||
        last.year != now.year ||
        last.month != now.month ||
        last.day != now.day) {
      await userRef.set(
        {'spinsToday': 0, 'lastSpinAt': Timestamp.fromDate(DateTime(2000))},
        SetOptions(merge: true),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startSpin() async {
    if (_spinning) return;

    setState(() {
      _spinning = true;
      _lastPrize = null;
    });

    final db = FirebaseFirestore.instance;
    final userRef = db.collection('users').doc(uid);
    final gamesRef = userRef.collection('gamesSummary').doc('summary');

    try {
      final prize = await db.runTransaction<int>((txn) async {
        final g = await txn.get(gamesRef);
        int tickets = (g.data()?['tickets'] as num?)?.toInt() ?? 0;
        int spinsToday = (g.data()?['spinsToday'] as num?)?.toInt() ?? 0;
        final last = (g.data()?['lastSpinAt'] as Timestamp?)?.toDate();

        final now = DateTime.now();
        if (last == null ||
            last.year != now.year ||
            last.month != now.month ||
            last.day != now.day) {
          spinsToday = 0;
        }

        if (tickets <= 0) throw StateError('No tickets left.');
        if (spinsToday >= kDailySpinLimit) {
          throw StateError('Daily spin limit reached ($kDailySpinLimit).');
        }

        // Weighted draw
        final r = _random.nextDouble();
        int selectedPrize;
        if (r < 0.40) {
          selectedPrize = 10;
        } else if (r < 0.65) {
          selectedPrize = 20;
        } else if (r < 0.85) {
          selectedPrize = 30;
        } else if (r < 0.95) {
          selectedPrize = 50;
        } else {
          selectedPrize = 0;
        }

        tickets -= 1;

        // Update counters atomically
        txn.set(
          gamesRef,
          {
            'tickets': tickets,
            'spinsToday': FieldValue.increment(1),
            'lastSpinAt': Timestamp.fromDate(now),
          },
          SetOptions(merge: true),
        );

        if (selectedPrize > 0) {
          final rewardsRef =
              userRef.collection('rewardsSummary').doc('summary');
          final rewardTxRef = userRef.collection('rewardTransactions').doc();

          txn.set(
            rewardsRef,
            {
              'totalPoints': FieldValue.increment(selectedPrize),
              'lifetimePoints': FieldValue.increment(selectedPrize),
            },
            SetOptions(merge: true),
          );
          txn.set(rewardTxRef, {
            'type': 'spinPrize',
            'points': selectedPrize,
            'createdAt': Timestamp.fromDate(now),
            'meta': {'game': 'spin'},
          });
        }

        return selectedPrize;
      });

      await _animateSpin(prize);
      if (!mounted) return;

      setState(() => _lastPrize = prize);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(prize > 0 ? 'You won $prize points!' : 'Try again!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _spinning = false);
    }
  }

  Future<void> _animateSpin(int prize) async {
    final sectionCount = _prizes.length;
    final sectionAngle = 2 * pi / sectionCount;
    final prizeIndex = _prizes.indexOf(prize).clamp(0, sectionCount - 1);
    final baseAngle = sectionAngle * prizeIndex + sectionAngle / 2;
    final pointerAngle = 3 * pi / 2; // top pointer

    final from = _currentRotation;

    // Exactly 5 full rotations in the set duration (1 second)
    final to = (from + (5 * 2 * pi) + (pointerAngle - baseAngle)) % (2 * pi);

    _animation = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic, // fast ramp, sharp decel [Curves docs]
      ),
    )..addListener(() => setState(() {}));

    _controller.reset();
    await _controller.forward();

    _currentRotation = to % (2 * pi);
  }

  void _onSpinEnd() {
    setState(() {
      _spinning = false;
    });
  }

  Widget _buildWheel(double size) {
    final sectionCount = _prizes.length;
    final sectionAngle = 2 * pi / sectionCount;
    final rotationValue = _animation?.value ?? _currentRotation;

    final labels = List.generate(sectionCount, (i) {
      final angle = sectionAngle * i;
      final labelRadius = size * 0.35;
      return Transform.rotate(
        angle: rotationValue + angle + sectionAngle / 2,
        child: Transform.translate(
          offset: Offset(0, -labelRadius),
          child: SizedBox(
            width: size * 0.22,
            child: Center(
              child: Text(
                '${_prizes[i]} pts',
                style: TextStyle(
                  fontSize: size * 0.06,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  shadows: const [
                    Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.white)
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    });

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size + 36,
          height: size + 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.orangeAccent.withOpacity(0.25),
                  blurRadius: 36,
                  spreadRadius: 8),
            ],
          ),
        ),
        Transform.rotate(
          angle: rotationValue,
          child: CustomPaint(
              size: Size.square(size), painter: _WheelPainter(_prizes)),
        ),
        ...labels,
        Positioned(top: 6, child: _buildPointer()),
      ],
    );
  }

  Widget _buildPointer() {
    return Column(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.redAccent.withOpacity(0.7),
                  blurRadius: 10,
                  spreadRadius: 2)
            ],
          ),
        ),
        SizedBox(
            width: 30,
            height: 34,
            child: CustomPaint(painter: _PointerPainter())),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    final gamesStream = db
        .collection('users')
        .doc(uid)
        .collection('gamesSummary')
        .doc('summary')
        .snapshots();

    final scheme = Theme.of(context).colorScheme;
    final bg = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0F1115), Color(0xFF12151C)],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Spin the Wheel')),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: bg),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: gamesStream,
          builder: (context, snapshot) {
            final data = snapshot.data?.data() ?? {};
            final tickets = (data['tickets'] as num?)?.toInt() ?? 0;
            final spinsToday = (data['spinsToday'] as num?)?.toInt() ?? 0;

            return Center(
              child: LayoutBuilder(
                builder: (context, cons) {
                  final wheelSize =
                      (min(cons.maxWidth, 520.0)).clamp(280.0, 420.0);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      _buildWheel(wheelSize),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.confirmation_num,
                                size: 18, color: Colors.black),
                            label: Text('Tickets: $tickets',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            backgroundColor: Colors.amberAccent,
                          ),
                          Chip(
                            avatar: const Icon(Icons.refresh,
                                size: 18, color: Colors.white),
                            label: Text('Spins: $spinsToday / $kDailySpinLimit',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            backgroundColor: scheme.surface.withOpacity(0.15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: (_spinning ||
                                tickets <= 0 ||
                                spinsToday >= kDailySpinLimit)
                            ? null
                            : _startSpin,
                        icon: _spinning
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.casino_rounded),
                        label: Text(_spinning ? 'Spinning...' : 'Spin'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          shadowColor: Colors.deepOrangeAccent,
                          elevation: 8,
                        ),
                      ),
                      if (tickets <= 0)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('No tickets left',
                              style: TextStyle(color: Colors.redAccent)),
                        ),
                      if (spinsToday >= kDailySpinLimit)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                              'Daily spin limit reached ($kDailySpinLimit)',
                              style: const TextStyle(color: Colors.redAccent)),
                        ),
                      if (_lastPrize != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 18),
                          child: Text(
                            _lastPrize! > 0
                                ? '🎉 You won ${_lastPrize!} pts!'
                                : 'Try again!',
                            style: TextStyle(
                              fontSize: 18,
                              color: _lastPrize! > 0
                                  ? Colors.deepOrange
                                  : Colors.white70,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<int> prizes;
  _WheelPainter(this.prizes);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sectionCount = prizes.length;
    final sweep = 2 * pi / sectionCount;

    final rimPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawCircle(rect.center, size.width / 2, rimPaint);

    final innerRect =
        Rect.fromCircle(center: rect.center, radius: size.width * 0.48);
    final bgPaint = Paint()..color = const Color(0xFFFFF8E1);
    canvas.drawCircle(rect.center, size.width * 0.48, bgPaint);

    for (int i = 0; i < sectionCount; i++) {
      final start = sweep * i;
      final segRect = innerRect;
      final grad = SweepGradient(
        startAngle: start,
        endAngle: start + sweep,
        colors: i.isEven
            ? [const Color(0xFFFFCC80), const Color(0xFFFFB74D)]
            : [const Color(0xFFFFE0B2), const Color(0xFFFFCC80)],
      );
      final segPaint = Paint()..shader = grad.createShader(segRect);
      canvas.drawArc(segRect, start, sweep, true, segPaint);
    }

    final capPaint = Paint()..color = const Color(0xFFFFA726);
    canvas.drawCircle(rect.center, size.width * 0.06, capPaint);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 2 - 12, size.height)
      ..lineTo(size.width / 2 + 12, size.height)
      ..close();

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, paint);

    final glow = Paint()..color = const Color(0xFFFF5252).withOpacity(0.35);
    canvas.drawCircle(Offset(size.width / 2, 0), 8, glow);
  }

  @override
  bool shouldRepaint(_PointerPainter oldDelegate) => false;
}
