import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/firestore_quests_repository.dart';

class QuestsPage extends StatefulWidget {
  const QuestsPage({super.key});
  @override
  State createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage> {
  final _repo = FirestoreQuestsRepository();
  bool _loading = false;
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    // Make sure the weekly doc exists
    _repo.ensureWeek();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Quests')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complete quests to earn tickets and points.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _StatusLine(uid: _uid),
            const SizedBox(height: 16),
            // Each row is tappable now; during development it updates progress.
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Browse 5 listings'),
              onTap: () async {
                await _repo.updateBrowse(); // dev/test tap
              }, // Make row interactive [2][3][5]
              trailing: const Icon(Icons.circle_outlined, color: Colors.grey),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Post 1 ad'),
              onTap: () async {
                await _repo.updatePost(); // dev/test tap
              }, // [2][3]
              trailing: const Icon(Icons.circle_outlined, color: Colors.grey),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Purchase ≥ 300tk'),
              onTap: () async {
                // dev/test tap simulates a 300tk order
                await _repo
                    .updatePurchase(300); // increments purchaseTk [16][6][8]
              },
              trailing: const Icon(Icons.circle_outlined, color: Colors.grey),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Leave 1 rating'),
              onTap: () async {
                await _repo.updateRating(); // dev/test tap [2][3]
              },
              trailing: const Icon(Icons.circle_outlined, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      List<String> granted = const [];
                      try {
                        granted = await _repo.claimEligibleQuests();
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Claim failed: $e')),
                        );
                      } finally {
                        if (!mounted) return;
                        setState(() => _loading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(granted.isEmpty
                                ? 'Nothing to claim yet'
                                : 'Claimed: ${granted.join(', ')}'),
                          ),
                        );
                      }
                    },
              child: Text(_loading ? 'Checking…' : 'Claim eligible rewards'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  final String uid;
  const _StatusLine({required this.uid});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('questsSummary')
        .doc('summary');

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: ref.snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) {
          return const SizedBox.shrink();
        }
        final d = snap.data!.data()!;
        final completed = (d['completed'] is List)
            ? List<String>.from(d['completed'] as List)
            : <String>[];
        final browse =
            (d['browseCount'] is num) ? (d['browseCount'] as num).toInt() : 0;
        final post =
            (d['postCount'] is num) ? (d['postCount'] as num).toInt() : 0;
        final pur =
            (d['purchaseTk'] is num) ? (d['purchaseTk'] as num).toInt() : 0;
        final rate =
            (d['ratingCount'] is num) ? (d['ratingCount'] as num).toInt() : 0;

        return Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Chip(label: Text('Completed: ${completed.length}')),
            Chip(label: Text('Browse: $browse/5')),
            Chip(label: Text('Post: $post/1')),
            Chip(label: Text('Purchase: $pur/300')),
            Chip(label: Text('Rating: $rate/1')),
          ],
        );
      },
    );
  }
}
