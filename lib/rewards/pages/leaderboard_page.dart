import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  DateTime _day = _stripTime(DateTime.now());
  static DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  String _dayKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Query<Map<String, dynamic>> _queryForDay(DateTime d) {
    final key = _dayKey(d);
    return FirebaseFirestore.instance
        .collection('leaderboardDaily')
        .doc(key)
        .collection('users')
        .orderBy('itemsPurchased', descending: true)
        .limit(100);
  }

  void _goPrevDay() =>
      setState(() => _day = _day.subtract(const Duration(days: 1)));
  void _goNextDay() => setState(() => _day = _day.add(const Duration(days: 1)));

  @override
  Widget build(BuildContext context) {
    final q = _queryForDay(_day);
    final titleText = 'Leaderboard (${_dayKey(_day)})';

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: q.snapshots(),
      builder: (ctx, snap) {
        final scheme = Theme.of(context).colorScheme;

        PreferredSizeWidget appBar = AppBar(
          title: Text(titleText),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withOpacity(0.25),
                  Colors.amber.withOpacity(0.25)
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          actions: [
            IconButton(
                onPressed: _goPrevDay, icon: const Icon(Icons.chevron_left)),
            IconButton(
                onPressed: _goNextDay, icon: const Icon(Icons.chevron_right)),
          ],
        );

        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
              appBar: appBar,
              body: const Center(child: CircularProgressIndicator()));
        }

        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Scaffold(
              appBar: appBar,
              body: const Center(child: Text('No stats yet for this day.')));
        }

        final docs = snap.data!.docs;

        return Scaffold(
          appBar: appBar,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF0F1115), const Color(0xFF12151C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final d = docs[i].data();
                final rank = i + 1;
                final name = (d['displayName'] ?? 'User').toString();
                final photoUrl = d['photoUrl'] as String?;
                final items = (d['itemsPurchased'] as num?)?.toInt() ?? 0;
                final orders = (d['ordersCount'] as num?)?.toInt() ?? 0;
                final pts = (d['pointsEarned'] as num?)?.toInt() ?? 0;

                final isTop1 = rank == 1;
                final isTop2 = rank == 2;
                final isTop3 = rank == 3;

                Color cardBg =
                    Theme.of(context).colorScheme.surface.withOpacity(0.15);
                if (isTop1)
                  cardBg = Colors.amber.withOpacity(0.18);
                else if (isTop2)
                  cardBg = Colors.blueGrey.withOpacity(0.18);
                else if (isTop3) cardBg = Colors.deepOrange.withOpacity(0.18);

                final rankChip = Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isTop1
                        ? Colors.amber
                        : isTop2
                            ? Colors.blueGrey.shade200
                            : isTop3
                                ? Colors.deepOrangeAccent
                                : Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      if (isTop1 || isTop2 || isTop3)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isTop1 || isTop2 || isTop3)
                        Icon(
                          Icons.emoji_events_rounded,
                          size: 16,
                          color: Colors.black87,
                        ),
                      if (isTop1 || isTop2 || isTop3) const SizedBox(width: 6),
                      Text(
                        '#$rank',
                        style: TextStyle(
                          color: (isTop1 || isTop2 || isTop3)
                              ? Colors.black87
                              : Colors.white70,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ); // rank badge using chips per Material guidance [web:329][web:328]

                return Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    leading: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              (photoUrl != null && photoUrl.isNotEmpty)
                                  ? NetworkImage(photoUrl)
                                  : null,
                          child: (photoUrl == null || photoUrl.isEmpty)
                              ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                )
                              : null,
                        ),
                        // small corner chip with rank
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: rankChip,
                        ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text('Orders: $orders',
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(width: 12),
                        Icon(Icons.inventory_2_outlined,
                            size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text('Items: $items',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ), // uses ListTile patterns and icons per Material widgets [web:331][web:336]
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$pts pts',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Today',
                            style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
