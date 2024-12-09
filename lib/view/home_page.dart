import 'package:flutter/material.dart';
import 'add_edit_page.dart';
import 'details_page.dart';
import '../service/firestore_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();

  /// Navega para a página de adicionar ou editar restaurante
  void _navigateToAddEditPage([Map<String, dynamic>? restaurant]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditPage(restaurant: restaurant),
      ),
    );
    setState(() {}); // Recarrega a interface após adicionar ou editar
  }

  /// Navega para a página de detalhes do restaurante
  void _navigateToDetailsPage(Map<String, dynamic> restaurant) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailsPage(restaurant: restaurant),
      ),
    );
    if (updated == true) {
      setState(() {}); // Atualiza a interface caso tenha alterações
    }
  }

  /// Constrói as estrelas de avaliação
  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.red,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/reviews_icon.png',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Reviews',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 28,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _firestoreService.readRestaurants(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Erro ao carregar os dados.'));
                  }

                  final restaurants = snapshot.data ?? [];

                  if (restaurants.isEmpty) {
                    return const Center(child: Text('Nenhum restaurante adicionado ainda.'));
                  }

                  return ListView.builder(
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: restaurant['imagem'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    restaurant['imagem'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.restaurant, size: 50, color: Colors.red),
                          title: Text(
                            restaurant['nome'] ?? 'Sem nome',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: _buildRatingStars(restaurant['nota']?.toDouble() ?? 0),
                          onTap: () => _navigateToDetailsPage(restaurant),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _navigateToAddEditPage(),
      ),
    );
  }
}
