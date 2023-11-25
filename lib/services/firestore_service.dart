import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  Stream<QuerySnapshot> eventos() {
    return FirebaseFirestore.instance.collection('eventos').snapshots();
  }


  Future<void> eventoAgregar(String nombre, String lugar, DateTime fechaHora, String tipo, String descripcion, int likes, String imagenUrl) async {
    return FirebaseFirestore.instance.collection('eventos').doc().set({
      'nombre': nombre,
      'lugar': lugar,
      'fechaHora': fechaHora,
      'tipo': tipo,
      'descripcion': descripcion,
      'likes': likes,
      'imagenUrl': imagenUrl,
    });
  }


  Future<void> eventoBorrar(String docId) async {
    return FirebaseFirestore.instance.collection('eventos').doc(docId).delete();
  }
 
  Future<void> incrementarLikes(String docId, int nuevosLikes) async {
    return FirebaseFirestore.instance
        .collection('eventos')
        .doc(docId)
        .update({'likes': nuevosLikes});
    }

}
