# Migration from Realtime Database to Firestore

## Tasks to Complete

### 1. Update live_monitoring_page.dart
- [ ] Replace `firebase_database` import with `cloud_firestore`
- [ ] Change `DatabaseReference _dbRef` to `FirebaseFirestore _firestore`
- [ ] Update `_loadInitialData()` method to use Firestore streams
- [ ] Modify environment data fetching from Firestore
- [ ] Modify actuator states fetching from Firestore

### 2. Update manual_controls_page.dart
- [ ] Replace `firebase_database` import with `cloud_firestore`
- [ ] Change `DatabaseReference _dbRef` to `FirebaseFirestore _firestore`
- [ ] Update `_loadInitialData()` method to use Firestore streams
- [ ] Update `_toggleActuator()` method to update Firestore documents
- [ ] Update emergency control buttons to use Firestore

### 3. Testing
- [ ] Test live monitoring page with Firestore data
- [ ] Test manual controls page with Firestore updates
- [ ] Verify real-time updates work correctly

## Current Progress
- Plan approved by user
- Starting migration process

## Notes
- Firestore collections should be structured as:
  - `environment` collection for sensor data
  - `actuators` collection for control states
- Use document IDs that match the existing Realtime Database structure for compatibility
