import 'package:flutter/material.dart';
import '../service/firestore_service.dart';
import 'add_edit_page.dart';

class DetailsPage extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  DetailsPage({required this.restaurant});

  final FirestoreService _firestoreService = FirestoreService();

  /// Função para excluir restaurante
  void _deleteRestaurant(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: Colors.white,
          colorScheme: const ColorScheme.light(
            primary: Colors.red,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: AlertDialog(
          title: const Text(
            'Excluir Restaurante',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text(
            'Tem certeza que deseja excluir este restaurante?',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed ?? false) {
      try {
        await _firestoreService.deleteRestaurant(restaurant['id']);
        Navigator.pop(context, true); // Retorna à página anterior e sinaliza sucesso
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir restaurante: $e')),
        );
      }
    }
  }

  /// Função para editar restaurante
  void _editRestaurant(BuildContext context) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditPage(restaurant: restaurant),
      ),
    );
    if (updated == true) {
      Navigator.pop(context, true); // Retorna à página anterior após atualização
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
      appBar: AppBar(title: const Text('Detalhes do Restaurante')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (restaurant['imagem'] != null && restaurant['imagem'].isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    restaurant['imagem'],
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Nome: ${restaurant['nome']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Nota:', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildRatingStars(restaurant['nota']?.toDouble() ?? 0),
              const SizedBox(height: 10),
              Text('Tipo de Restaurante: ${restaurant['tipoComida'] ?? "Não especificado"}'),
              const SizedBox(height: 10),
              if (restaurant['pedido'] != null && restaurant['pedido'].isNotEmpty)
                Text('Pedido: ${restaurant['pedido']}'),
              const SizedBox(height: 10),
              if (restaurant['dataVisita'] != null)
                Text('Data de Visita: ${restaurant['dataVisita']}'),
              const SizedBox(height: 10),
              if (restaurant['comentario'] != null && restaurant['comentario'].isNotEmpty)
                Text('Comentário: ${restaurant['comentario']}'),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _editRestaurant(context),
                    child: const Text('Editar'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _deleteRestaurant(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Excluir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
