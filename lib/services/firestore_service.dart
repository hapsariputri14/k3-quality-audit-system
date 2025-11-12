
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference audits = FirebaseFirestore.instance.collection('audits');
  final CollectionReference hazards = FirebaseFirestore.instance.collection('hazards');

  // --- AUDIT METHODS ---
  Future<void> addAudit(Map<String, dynamic> data) async {
    await audits.add(data);
  }

  Stream<QuerySnapshot> getAuditsStream() {
    return audits.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updateAudit(String id, Map<String, dynamic> data) async {
    await audits.doc(id).update(data);
  }

  Future<void> deleteAudit(String id) async {
    await audits.doc(id).delete();
  }

  // --- HAZARD METHODS ---
  Stream<QuerySnapshot> getHazardsStream() {
    return hazards.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addHazard(Map<String, dynamic> data) async {
    await hazards.add(data);
  }

  Future<void> updateHazard(String id, Map<String, dynamic> data) async {
    await hazards.doc(id).update(data);
  }

  Future<void> deleteHazard(String id) async {
    await hazards.doc(id).delete();
  }
}

