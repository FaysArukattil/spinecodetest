import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_keys.dart';
import '../models/vegetable_model.dart';

class VegetableRemoteDataSource {
  final FirebaseFirestore _db;
  VegetableRemoteDataSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestoreKeys.vegetables);

  Stream<List<VegetableModel>> watchAll() => _col.snapshots().map((snap) {
        final list = snap.docs.map(VegetableModel.fromDoc).toList();
        list.sort((a, b) => a.sortNumber.compareTo(b.sortNumber));
        return list;
      });

  Future<void> add(VegetableModel v) => _col.add(v.toMap());

  Future<void> update(VegetableModel v) => _col.doc(v.id).update(v.toMap());

  Future<void> delete(String id) => _col.doc(id).delete();
}
