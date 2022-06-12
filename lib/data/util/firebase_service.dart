import 'package:cloud_firestore/cloud_firestore.dart';

typedef Json = Map<String, dynamic>;
typedef JsonEncoder<T> = Json Function(T entry);
typedef JsonDecoder<T> = T Function(Json data);

abstract class DatabaseService<T> {
  const DatabaseService({
    required this.fromJson,
    required this.toJson,
  });

  final JsonDecoder<T> fromJson;
  final JsonEncoder<T> toJson;

  Future<T?> fetchSingle(String id);
  Stream<T?> streamSingle(String id);
  Stream<List<T>> streamCollection();

  Future createEntry(Json data, {String? id});
  Future updateEntry(Json data, {required String id});
  Future deleteEntry(String id);
}

class CloudDatabaseService<T> extends DatabaseService<T> {
  CloudDatabaseService({
    required this.collection,
    required JsonDecoder<T> fromJson,
    required JsonEncoder<T> toJson,
  })  : _database = FirebaseFirestore.instance,
        super(fromJson: fromJson, toJson: toJson);

  final String collection;

  final FirebaseFirestore _database;
  FirebaseFirestore get database => _database;

  @override
  Future createEntry(Json data, {String? id}) async {
    final collRef = _database.collection(collection);
    id != null ? await collRef.doc(id).set(data) : await collRef.add(data);
  }

  @override
  Future deleteEntry(String id) async {
    await _database.collection(collection).doc(id).delete();
  }

  @override
  Future<T?> fetchSingle(String id) async {
    final snapshot = await _database.collection(collection).doc(id).get();
    return snapshot.exists ? fromJson(snapshot.data()!) : null;
  }

  @override
  Stream<List<T>> streamCollection() {
    final reference = _database.collection(collection);
    return reference.snapshots().map((list) => list.docs.map((item) => fromJson(item.data())).toList());
  }

  @override
  Stream<T?> streamSingle(String id) {
    return _database
        .collection(collection)
        .doc(id)
        .snapshots()
        .map((snapshot) => snapshot.exists ? fromJson(snapshot.data()!) : null);
  }

  @override
  Future updateEntry(Json data, {required String id}) async {
    await _database.collection(collection).doc(id).update(data);
  }
}
