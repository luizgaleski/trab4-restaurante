import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importação necessária
import 'package:intl/intl.dart';
import '../service/firestore_service.dart';
import 'add_edit_page.dart';

class DetailsPage extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  DetailsPage({required this.restaurant});

  final FirestoreService _firestoreService = FirestoreService();

  /// Converte o `Timestamp` para uma string de data legível
  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(date.toDate());
    } else if (date is DateTime) {
      return DateFormat('dd/MM/yyyy').format(date);
    }
    return 'Data inválida'; // Caso não seja um formato válido
  }

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
      appBar: AppBar(
        backgroundColor: Colors.red, // Fundo vermelho
        iconTheme: const IconThemeData(color: Colors.white), // Ícones brancos
        title: const Text(
          'Detalhes do Restaurante',
          style: TextStyle(
            color: Colors.white, // Título em branco
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 2, // Sombra padrão para o AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Nome: ${restaurant['nome'] ?? 'Sem nome'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red, // Nome em vermelho
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Nota:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red, // Título "Nota" em vermelho
                ),
              ),
              _buildRatingStars(restaurant['nota']?.toDouble() ?? 0),
              const SizedBox(height: 10),
              Text(
                'Tipo de Restaurante: ${restaurant['tipoComida'] ?? "Não especificado"}',
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 10),
              if (restaurant['pedido'] != null && restaurant['pedido'].isNotEmpty)
                Text(
                  'Pedido: ${restaurant['pedido']}',
                  style: const TextStyle(color: Colors.black),
                ),
              const SizedBox(height: 10),
              if (restaurant['dataVisita'] != null)
                Text(
                  'Data de Visita: ${_formatDate(restaurant['dataVisita'])}', // Formatação correta
                  style: const TextStyle(color: Colors.black),
                ),
              const SizedBox(height: 10),
              if (restaurant['comentario'] != null && restaurant['comentario'].isNotEmpty)
                Text(
                  'Comentário: ${restaurant['comentario']}',
                  style: const TextStyle(color: Colors.black),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _editRestaurant(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Botão vermelho
                      foregroundColor: Colors.white, // Texto branco
                    ),
                    child: const Text('Editar'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _deleteRestaurant(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Botão vermelho
                      foregroundColor: Colors.white, // Texto branco
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
