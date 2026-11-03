import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_keys.dart';
import '../models/staff_model.dart';

class StaffRemoteDataSource {
  final FirebaseFirestore _db;
  StaffRemoteDataSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _staff =>
      _db.collection(FirestoreKeys.staff);

  Stream<List<StaffModel>> watchAll() => _staff.snapshots().map((snap) {
        final list = snap.docs.map(StaffModel.fromDoc).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  Future<void> add(StaffModel staff) => _staff.add(staff.toMap());

  Future<void> update(StaffModel staff) =>
      _staff.doc(staff.id).update(staff.toMap());

  Future<void> delete(String id) => _staff.doc(id).delete();
}
