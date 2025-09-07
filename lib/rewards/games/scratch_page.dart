import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

class ScratchPage extends StatelessWidget {
  const ScratchPage({super.key});
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scratchCards')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Scratch Cards')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No scratch cards yet'));
          }

          return LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth >= 1000
                  ? 4
                  : c.maxWidth >= 760
                      ? 3
                      : 2;
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i];
                  final used = d.data()['used'] == true;
                  final prize = (d.data()['prize'] as num?)?.toInt() ?? 0;
                  return _CardTile(
                    id: d.id,
                    used: used,
                    prize: prize,
                    onOpen: () => Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => _AutoScratchPlay(
                          cardDoc: d,
                          alreadyUsed: used,
                          existingPrize: prize,
                        ),
                        transitionsBuilder: (_, a, __, child) =>
                            FadeTransition(opacity: a, child: child),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final String id;
  final bool used;
  final int prize;
  final VoidCallback onOpen;
  const _CardTile({
    required this.id,
    required this.used,
    required this.prize,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onOpen,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.surfaceVariant.withOpacity(0.35),
              scheme.surface.withOpacity(0.1)
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 12,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Card #${id.substring(0, 6)}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            Center(
              child: Icon(
                used ? Icons.check_circle : Icons.style_rounded,
                size: 52,
                color: used ? Colors.greenAccent : Colors.amber,
              ),
            ),
            const Spacer(),
            Text(
              used ? 'Used • Prize: $prize pts' : 'Unused • Tap to reveal',
              style: TextStyle(
                color: used ? Colors.greenAccent : Colors.amberAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AutoScratchPlay extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> cardDoc;
  final bool alreadyUsed;
  final int existingPrize;
  const _AutoScratchPlay({
    required this.cardDoc,
    required this.alreadyUsed,
    required this.existingPrize,
  });

  @override
  State<_AutoScratchPlay> createState() => _AutoScratchPlayState();
}

class _AutoScratchPlayState extends State<_AutoScratchPlay>
    with TickerProviderStateMixin {
  final Path _mask = Path();
  int? _prizeWon;
  bool _claimed = false;

  late final AnimationController _strokeCtl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400));
  final int _strokes = 10;

  late final AnimationController _winCtl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
  late final Animation<double> _winScale =
      CurvedAnimation(parent: _winCtl, curve: Curves.elasticOut);
  late final Animation<double> _winFade =
      CurvedAnimation(parent: _winCtl, curve: Curves.easeIn);

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    if (widget.alreadyUsed) {
      _prizeWon = widget.existingPrize;
    }
  }

  @override
  void dispose() {
    _strokeCtl.dispose();
    _winCtl.dispose();
    super.dispose();
  }

  Future<void> _claimIfNeeded() async {
    if (_claimed) return;
    _claimed = true;

    if (widget.alreadyUsed) {
      if (!mounted) return;
      _winCtl.forward();
      return;
    }

    final db = FirebaseFirestore.instance;
    await db.runTransaction((txn) async {
      final snap = await txn.get(widget.cardDoc.reference);
      final data = snap.data()!;
      if (data['used'] == true) {
        _prizeWon = (data['prize'] as num?)?.toInt() ?? 0;
        return;
      }

      final r = Random().nextDouble();
      int p = 5;
      if (r < 0.50) {
        p = 5;
      } else if (r < 0.80) {
        p = 10;
      } else if (r < 0.95) {
        p = 20;
      } else {
        p = 50;
      }

      final rewardsRef = db
          .collection('users')
          .doc(uid)
          .collection('rewardsSummary')
          .doc('summary');
      final rewardTx = db
          .collection('users')
          .doc(uid)
          .collection('rewardTransactions')
          .doc();

      txn.update(widget.cardDoc.reference, {'used': true, 'prize': p});
      txn.set(
        rewardsRef,
        {
          'totalPoints': FieldValue.increment(p),
          'lifetimePoints': FieldValue.increment(p),
        },
        SetOptions(merge: true),
      );
      txn.set(rewardTx, {
        'type': 'scratchReward',
        'points': p,
        'createdAt': Timestamp.now(),
        'meta': {'cardId': widget.cardDoc.id},
      });

      _prizeWon = p;
    });

    if (!mounted) return;
    _winCtl.forward();
  }

  void _startAutoScratch(Size size) {
    final rand = Random();
    final stripeGap = size.height / (_strokes + 1);
    final strokes = List.generate(_strokes, (i) {
      final y = stripeGap * (i + 1) +
          rand.nextDouble() * stripeGap * 0.2 -
          stripeGap * 0.1;
      final thickness = 24.0 + rand.nextDouble() * 10;
      final tilt = pi / 10 * (rand.nextBool() ? 1 : -1);
      final delay = i * 0.05;
      return _StrokeSpec(
        y: y.clamp(0, size.height - 1),
        thickness: thickness,
        tilt: tilt,
        delay: delay,
      );
    });

    _strokeCtl
      ..addListener(() {
        final t = _strokeCtl.value;
        setState(() {
          _mask.reset();
          for (final s in strokes) {
            final localT = ((t - s.delay) / 0.75).clamp(0.0, 1.0);
            if (localT <= 0) continue;

            final eased = Curves.easeInOut.transform(localT);
            final len = size.width * (0.15 + 0.85 * eased);

            final cx = len;
            final cy = s.y;
            final rect = RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(cx / 2, cy), width: len, height: s.thickness),
              const Radius.circular(12),
            );

            // Build stroke and rotate with a Float64List matrix, then add with Offset.zero
            final Path p = Path()..addRRect(rect);
            final Matrix4 m = Matrix4.identity()
              ..translate(cx / 2, cy)
              ..rotateZ(s.tilt)
              ..translate(-cx / 2, -cy);
            final Float64List mat = m.storage;
            final Path rp = p.transform(mat);
            _mask.addPath(rp, Offset.zero); // <-- 2 args required
          }
        });

        if (!_claimed && t > 0.7) {
          _claimIfNeeded();
        }
      })
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scratch to Reveal')),
      body: LayoutBuilder(
        builder: (context, cons) {
          final boardW = min(cons.maxWidth * 0.88, 520.0);
          final boardH = min(cons.maxHeight * 0.55, 360.0);
          final size = Size(boardW, boardH);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_strokeCtl.isDismissed && mounted) {
              _startAutoScratch(size);
            }
          });

          return Column(
            children: [
              const SizedBox(height: 18),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Prize panel
                    Container(
                      width: size.width,
                      height: size.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.deepOrange.shade400,
                            Colors.amber.shade400
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _winCtl,
                          builder: (context, _) {
                            final pts = _prizeWon ?? 0;
                            return Opacity(
                              opacity: _winFade.value,
                              child: Transform.scale(
                                scale: max(1.0, _winScale.value),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _prizeWon == null
                                          ? Icons.card_giftcard
                                          : Icons.emoji_events_rounded,
                                      size: 68,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _prizeWon == null
                                          ? 'Revealing…'
                                          : '+$pts pts!',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                              offset: Offset(1, 1),
                                              blurRadius: 4,
                                              color: Colors.black87),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Foil (base − animated mask)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: CustomPaint(
                          size: size, painter: _FoilPainter(mask: _mask)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _prizeWon == null ? 'Revealing…' : 'You won $_prizeWon points!',
                style: TextStyle(
                  color: _prizeWon == null
                      ? Colors.white70
                      : Colors.lightGreenAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Done'),
                  onPressed: () => Navigator.of(context).pop(_prizeWon),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StrokeSpec {
  final double y;
  final double thickness;
  final double tilt;
  final double delay;
  _StrokeSpec({
    required this.y,
    required this.thickness,
    required this.tilt,
    required this.delay,
  });
}

// Painter that avoids BlendMode: draws foil as rounded-rect minus mask.
class _FoilPainter extends CustomPainter {
  final Path mask;
  _FoilPainter({required this.mask});

  @override
  void paint(Canvas canvas, Size size) {
    final rr =
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18));
    final base = Path()..addRRect(rr);
    final visible = Path.combine(PathOperation.difference, base, mask);

    final foil = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(size.width, size.height),
        const [Color(0xFF9E9E9E), Color(0xFFBDBDBD), Color(0xFFE0E0E0)],
      );
    canvas.drawPath(visible, foil);
  }

  @override
  bool shouldRepaint(covariant _FoilPainter oldDelegate) =>
      oldDelegate.mask != mask;
}
