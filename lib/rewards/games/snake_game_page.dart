import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SnakeGamePage extends StatefulWidget {
  const SnakeGamePage({super.key});
  @override
  State<SnakeGamePage> createState() => _SnakeGamePageState();
}

class _SnakeGamePageState extends State<SnakeGamePage>
    with TickerProviderStateMixin {
  static const int rows = 20;
  static const int cols = 20;
  static const Duration tick =
      Duration(milliseconds: 140); // slightly faster feels better

  // Directions
  static const up = Offset(0, -1);
  static const down = Offset(0, 1);
  static const left = Offset(-1, 0);
  static const right = Offset(1, 0);

  Timer? _timer;
  final Random _rng = Random();

  late List<Offset> _snake; // head first
  Offset _dir = right;
  Offset _food = const Offset(10, 10);
  bool _running = false;
  bool _paused = false;
  int _score = 0;

  final FocusNode _focusNode = FocusNode();

  // Subtle pulsing glow for the board title
  late final AnimationController _pulseCtl =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat(reverse: true);
  late final Animation<double> _pulse = Tween<double>(begin: 0.25, end: 0.75)
      .animate(CurvedAnimation(parent: _pulseCtl, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    _pulseCtl.dispose();
    super.dispose();
  }

  void _startNewGame() {
    _timer?.cancel();
    _running = true;
    _paused = false;
    _score = 0;
    _dir = right;
    final start =
        Offset((cols / 2).floorToDouble(), (rows / 2).floorToDouble());
    _snake = [start, start + left, start + left * 2];
    _spawnFood();
    _timer = Timer.periodic(tick, (_) => _step());
    setState(() {});
  }

  void _togglePause() {
    if (!_running) return;
    setState(() => _paused = !_paused);
  }

  void _spawnFood() {
    while (true) {
      final fx = _rng.nextInt(cols);
      final fy = _rng.nextInt(rows);
      final pos = Offset(fx.toDouble(), fy.toDouble());
      if (!_snake.contains(pos)) {
        _food = pos;
        return;
      }
    }
  }

  void _step() {
    if (!_running || _paused) return;
    final head = _snake.first;
    final next = head + _dir;

    // Wall/self collision
    if (next.dx < 0 || next.dx >= cols || next.dy < 0 || next.dy >= rows) {
      _gameOver();
      return;
    }
    if (_snake.contains(next)) {
      _gameOver();
      return;
    }

    _snake = [next, ..._snake];
    if (next == _food) {
      _score += 10;
      _spawnFood();
    } else {
      _snake.removeLast();
    }

    if (mounted) setState(() {});
  }

  void _changeDir(Offset d) {
    if (!_running || _paused) return;
    // Prevent reversing 180°
    if ((_dir.dx + d.dx).abs() == 0 && (_dir.dy + d.dy).abs() == 0) return;
    _dir = d;
  }

  void _onKey(KeyEvent event) {
    if (!_running || _paused) return;
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) _changeDir(up);
    if (key == LogicalKeyboardKey.arrowDown) _changeDir(down);
    if (key == LogicalKeyboardKey.arrowLeft) _changeDir(left);
    if (key == LogicalKeyboardKey.arrowRight) _changeDir(right);
  }

  Future<void> _gameOver() async {
    _running = false;
    _timer?.cancel();

    if (_score > 0) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final db = FirebaseFirestore.instance;
      final sumRef = db
          .collection('users')
          .doc(uid)
          .collection('rewardsSummary')
          .doc('summary');
      final txRef = db
          .collection('users')
          .doc(uid)
          .collection('rewardTransactions')
          .doc();

      await db.runTransaction((txn) async {
        txn.set(
          sumRef,
          {
            'totalPoints': FieldValue.increment(_score),
            'lifetimePoints': FieldValue.increment(_score),
          },
          SetOptions(merge: true),
        );
        txn.set(txRef, {
          'type': 'snake',
          'points': _score,
          'createdAt': Timestamp.now(),
          'meta': {'game': 'snake'},
        });
      });
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Score: $_score\nPoints added to rewards.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).maybePop();
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNewGame();
            },
            child: const Text('Play again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0F1115), Color(0xFF11131A)],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Chip(
              label: Text('Score: $_score',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              backgroundColor: scheme.surface.withOpacity(0.2),
              side: BorderSide(color: Colors.limeAccent.withOpacity(0.4)),
            ),
          ),
          IconButton(
            tooltip: _paused ? 'Resume' : 'Pause',
            onPressed: _togglePause,
            icon:
                Icon(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: bg),
        child: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _onKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellSize =
                  _calcCellSize(constraints.maxWidth, constraints.maxHeight);
              final boardWidth = cellSize * cols;
              final boardHeight = cellSize * rows;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Neon title with pulse glow
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, __) => Text(
                        _paused ? 'Paused' : 'Eat the apple!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.limeAccent,
                          shadows: [
                            Shadow(
                              blurRadius: 16 * (0.6 + _pulse.value),
                              color: Colors.limeAccent.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Board with soft neon edges
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.limeAccent.withOpacity(0.15),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                        border: Border.all(
                            color: Colors.limeAccent.withOpacity(0.2)),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            scheme.surface.withOpacity(0.25),
                            scheme.surfaceVariant.withOpacity(0.15),
                          ],
                        ),
                      ),
                      child: SizedBox(
                        width: boardWidth,
                        height: boardHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xFF0D1015),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CustomPaint(
                              painter: _SnakePainter(
                                rows: rows,
                                cols: cols,
                                snake: _snake,
                                food: _food,
                                gridColor: scheme.outline.withOpacity(0.15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),
                    _Controls(
                      enabled: _running && !_paused,
                      onUp: () => _changeDir(up),
                      onDown: () => _changeDir(down),
                      onLeft: () => _changeDir(left),
                      onRight: () => _changeDir(right),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _running ? _togglePause : null,
                          icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
                          label: Text(_paused ? 'Resume' : 'Pause'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _running ? null : _startNewGame,
                          icon: const Icon(Icons.replay_rounded),
                          label: const Text('Start'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  double _calcCellSize(double maxW, double maxH) {
    final cw = (maxW * 0.9 / cols).floorToDouble();
    final ch = (maxH * 0.5 / rows).floorToDouble();
    return min(cw, ch).clamp(10.0, 28.0);
  }
}

class _Controls extends StatelessWidget {
  final bool enabled;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  const _Controls({
    required this.enabled,
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    final base = ElevatedButton.styleFrom(
      minimumSize: const Size(72, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );

    ButtonStyle style(BuildContext _) => base.copyWith(
          shadowColor:
              WidgetStatePropertyAll(Colors.limeAccent.withOpacity(0.6)),
          elevation: const WidgetStatePropertyAll(6),
          backgroundColor: const WidgetStatePropertyAll(Color(0xFF1A1F27)),
          foregroundColor: const WidgetStatePropertyAll(Colors.limeAccent),
        );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 76),
            ElevatedButton(
              onPressed: enabled ? onUp : null,
              style: style(context),
              child: const Icon(Icons.keyboard_arrow_up),
            ),
            const SizedBox(width: 76),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: enabled ? onLeft : null,
              style: style(context),
              child: const Icon(Icons.keyboard_arrow_left),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: enabled ? onRight : null,
              style: style(context),
              child: const Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: enabled ? onDown : null,
              style: style(context),
              child: const Icon(Icons.keyboard_arrow_down),
            ),
          ],
        ),
      ],
    );
  }
}

class _SnakePainter extends CustomPainter {
  final int rows;
  final int cols;
  final List<Offset> snake;
  final Offset food;
  final Color gridColor;

  _SnakePainter({
    required this.rows,
    required this.cols,
    required this.snake,
    required this.food,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    // Grid
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int c = 0; c <= cols; c++) {
      final x = c * cellW;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int r = 0; r <= rows; r++) {
      final y = r * cellH;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Food (glossy pill)
    final foodRect =
        Rect.fromLTWH(food.dx * cellW, food.dy * cellH, cellW, cellH)
            .deflate(min(cellW, cellH) * 0.18);
    final foodGrad = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF7043), Color(0xFFFFC107)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(foodRect);
    canvas.drawRRect(
        RRect.fromRectAndRadius(foodRect, const Radius.circular(6)), foodGrad);

    // Snake (head brighter with soft highlight)
    final headPaint = Paint()..color = const Color(0xFF6BFF7F);
    final bodyPaint = Paint()..color = const Color(0xFF2ED573);
    final hiPaint = Paint()..color = Colors.white.withOpacity(0.15);

    for (int i = 0; i < snake.length; i++) {
      final s = snake[i];
      final r = Rect.fromLTWH(s.dx * cellW, s.dy * cellH, cellW, cellH)
          .deflate(min(cellW, cellH) * 0.12);
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(6));
      canvas.drawRRect(rr, i == 0 ? headPaint : bodyPaint);

      // small sheen on segments
      final sheen = Rect.fromLTWH(r.left + r.width * 0.15,
          r.top + r.height * 0.15, r.width * 0.15, r.height * 0.15);
      canvas.drawRRect(
          RRect.fromRectAndRadius(sheen, const Radius.circular(4)), hiPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnakePainter old) {
    return old.snake != snake || old.food != food;
  }
}
