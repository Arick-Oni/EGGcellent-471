import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:poultry_app/screens/widgets/notification_popup.dart';
import '../models/alert_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _alertSubscription;
  final Set<String> _shownAlerts = <String>{};
  OverlayEntry? _currentOverlay;
  BuildContext? _context;

  void initialize(BuildContext context) {
    _context = context;
    _startListening();
  }

  void _startListening() {
    _alertSubscription = _firestore
        .collection('eggcellent360')
        .doc('alerts')
        .collection('alerts')
        .snapshots()
        .listen(_handleAlertsSnapshot);
  }

  void _handleAlertsSnapshot(QuerySnapshot snapshot) async {
    List<AlertModel> recentAlerts = [];

    // Get all alert collections
    for (var doc in snapshot.docs) {
      final alertName = doc.id;
      final alertDocs = await _firestore
          .collection('eggcellent360')
          .doc('alerts')
          .collection(alertName)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (alertDocs.docs.isNotEmpty) {
        final alertData = alertDocs.docs.first;
        final alert = AlertModel.fromFirestore(
          alertData.data(),
          alertData.id,
          alertName,
        );

        if (alert.isRecent() && !_shownAlerts.contains(alert.id)) {
          recentAlerts.add(alert);
        }
      }
    }

    // Show the latest alert
    if (recentAlerts.isNotEmpty) {
      recentAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _showNotification(recentAlerts.first);
    }
  }

  void _showNotification(AlertModel alert) {
    if (_context == null) return;

    _shownAlerts.add(alert.id);
    _removeCurrentOverlay();

    _currentOverlay = OverlayEntry(
      builder: (context) => NotificationPopup(
        alert: alert,
        onDismiss: _removeCurrentOverlay,
      ),
    );

    Overlay.of(_context!).insert(_currentOverlay!);

    // Auto dismiss after 5 seconds
    Timer(const Duration(seconds: 5), () {
      _removeCurrentOverlay();
    });
  }

  void _removeCurrentOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  void dispose() {
    _alertSubscription?.cancel();
    _removeCurrentOverlay();
  }
}
