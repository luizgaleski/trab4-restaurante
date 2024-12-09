import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Referência para a coleção de restaurantes
  CollectionReference get restaurants => _firestore.collection('restaurants');

  /// Cria um novo restaurante associado ao usuário autenticado
  Future<DocumentReference> createRestaurant({
    required String nome,
    required double nota,
    required String imagem,
    required String tipoComida,
    required DateTime dataVisita,
    required String pedido,
    required String comentario,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    return await restaurants.add({
      'nome': nome,
      'nota': nota,
      'imagem': imagem,
      'tipoComida': tipoComida,
      'dataVisita': Timestamp.fromDate(dataVisita),
      'pedido': pedido,
      'comentario': comentario,
      'uid': user.uid, // Associa o restaurante ao usuário autenticado
    });
  }

  /// Retorna os restaurantes associados ao usuário autenticado
  Stream<List<Map<String, dynamic>>> readRestaurants() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    return restaurants
        .where('uid', isEqualTo: user.uid) // Filtra pelo ID do usuário
        .orderBy('dataVisita', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                ...data,
                'id': doc.id, // Inclui o ID do documento para futuras operações
              };
            }).toList());
  }

  /// Atualiza um restaurante do usuário autenticado
  Future<void> updateRestaurant({
    required String docID,
    required Map<String, dynamic> updatedData,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final doc = await restaurants.doc(docID).get();
    if (doc.exists && (doc.data() as Map<String, dynamic>)['uid'] == user.uid) {
      await restaurants.doc(docID).update(updatedData);
    } else {
      throw Exception('Você não tem permissão para atualizar este restaurante');
    }
  }

  /// Exclui um restaurante do usuário autenticado
  Future<void> deleteRestaurant(String docID) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final doc = await restaurants.doc(docID).get();
    if (doc.exists && (doc.data() as Map<String, dynamic>)['uid'] == user.uid) {
      await restaurants.doc(docID).delete();
    } else {
      throw Exception('Você não tem permissão para excluir este restaurante');
    }
  }
}
