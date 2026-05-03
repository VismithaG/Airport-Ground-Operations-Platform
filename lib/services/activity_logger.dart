import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ActivityLogger {
  static Future<void> logEvent({
    required String action,
    required String user,
    required String details,
    required String severity,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('activityLogs').add({
        'action': action,
        'user': user,
        'details': details,
        'severity': severity,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to log activity: $e');
    }
  }
}
