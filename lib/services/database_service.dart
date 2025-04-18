import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:re_mind/models/tip.dart';

const String TIP_COLLECTION = 'tips';
class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _tipsReference;

  DatabaseService(){
    _tipsReference = _firestore.collection(TIP_COLLECTION).withConverter<Tip>(fromFirestore: (snapshots, _) => Tip.fromJson(snapshots.data()!), 
    toFirestore: (tip, _) => tip.toJson());



  Stream<QuerySnapshot> getTips() {
    return _tipsReference.snapshots();
    }
    
  }
}