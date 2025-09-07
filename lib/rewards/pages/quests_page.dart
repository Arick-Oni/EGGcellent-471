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
  final _questsRepo = FirestoreQuestsRepository();
  bool _loading = false;
  List<String> _lastGranted = <String>[];
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
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
            _buildQuestRow('Browse 5 listings', 'browse5'),
            _buildQuestRow('Post 1 ad', 'post1'),
            _buildQuestRow('Purchase ≥ 300tk', 'purchase300'),
            _buildQuestRow('Leave 1 rating', 'rate1'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      List<String> granted = <String>[];
                      try {
                        granted = await _questsRepo.claimEligibleQuests();
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Claim failed: $e')),
                        );
                      } finally {
                        if (!mounted) return;
                        setState(() {
                          _loading = false;
                          _lastGranted = granted;
                        });
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

  Widget _buildQuestRow(String title, String questId) {
    final bool grantedNow = _lastGranted.contains(questId);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: grantedNow
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
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

    return StreamBuilder<DocumentSnapshot>(
      stream: ref.snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snap.data!.data() as Map<String, dynamic>;
        final completed = (data['completed'] is List)
            ? List<String>.from(data['completed'] as List)
            : <String>[];

        final tickets = data['tickets'] ?? 0;
        final weekId = data['weekId'] ?? '(no week)';

        return Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _simpleChip('Completed: ${completed.length}'),
            _simpleChip('Week: $weekId'),
            _simpleChip('Tickets: $tickets'),
          ],
        );
      },
    );
  }

  Widget _simpleChip(String text) => Chip(
        label: Text(text),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
}
