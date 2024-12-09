import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../service/firestore_service.dart';

class AddEditPage extends StatefulWidget {
  final Map<String, dynamic>? restaurant;

  AddEditPage({this.restaurant});

  @override
  _AddEditPageState createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ratingController = TextEditingController();
  final _orderController = TextEditingController();
  final _commentController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  String? _selectedCategory;
  String? _imagePath;
  String? _selectedDate;

  final List<String> _categories = [
    'Comida Italiana',
    'Comida Brasileira',
    'Comida Japonesa',
    'Fast Food',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.restaurant != null) {
      _nameController.text = widget.restaurant!['nome'] ?? '';
      _ratingController.text = widget.restaurant!['nota']?.toString() ?? '';
      _orderController.text = widget.restaurant!['pedido'] ?? '';
      _commentController.text = widget.restaurant!['comentario'] ?? '';
      _selectedCategory = widget.restaurant!['tipoComida'];
      _imagePath = widget.restaurant!['imagem'];
      _selectedDate = widget.restaurant!['dataVisita'] != null
          ? DateFormat('dd/MM/yyyy').format(widget.restaurant!['dataVisita'].toDate())
          : null;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
    });
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null
          ? DateFormat('dd/MM/yyyy').parse(_selectedDate!)
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _saveRestaurant() async {
    if (_formKey.currentState!.validate()) {
      final restaurantData = {
        'nome': _nameController.text,
        'nota': double.tryParse(_ratingController.text) ?? 0.0,
        'imagem': _imagePath ?? '',
        'tipoComida': _selectedCategory ?? '',
        'dataVisita': _selectedDate != null
            ? DateFormat('dd/MM/yyyy').parse(_selectedDate!)
            : DateTime.now(),
        'pedido': _orderController.text,
        'comentario': _commentController.text,
      };

      try {
        if (widget.restaurant == null) {
          // Adicionar novo restaurante
          await _firestoreService.createRestaurant(
            nome: restaurantData['nome'] as String,
            nota: restaurantData['nota'] as double,
            imagem: restaurantData['imagem'] as String,
            tipoComida: restaurantData['tipoComida'] as String,
            dataVisita: restaurantData['dataVisita'] as DateTime,
            pedido: restaurantData['pedido'] as String,
            comentario: restaurantData['comentario'] as String,
          );
        } else {
          // Atualizar restaurante existente
          await _firestoreService.updateRestaurant(
            docID: widget.restaurant!['id'],
            updatedData: restaurantData,
          );
        }
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar restaurante: $e')),
        );
      }
    }
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant == null
            ? 'Adicionar Restaurante'
            : 'Editar Restaurante'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) =>
                      value!.isEmpty ? 'Este campo é obrigatório' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _ratingController,
                  decoration: const InputDecoration(labelText: 'Nota (0 a 5)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final rating = double.tryParse(value!);
                    if (rating == null || rating < 0 || rating > 5) {
                      return 'Insira uma nota válida (0 a 5)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Tipo de Restaurante'),
                  value: _selectedCategory,
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Por favor, selecione uma categoria' : null,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Data de Visita',
                        hintText: 'Selecione a data',
                      ),
                      controller: TextEditingController(text: _selectedDate),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Por favor, selecione uma data'
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _orderController,
                  decoration: const InputDecoration(labelText: 'Pedido'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(labelText: 'Comentário'),
                ),
                const SizedBox(height: 20),
                _imagePath == null
                    ? TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image, color: Colors.red),
                        label: const Text('Selecionar Imagem'),
                      )
                    : Column(
                        children: [
                          Image.file(File(_imagePath!), height: 200),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.image, color: Colors.red),
                                label: const Text('Alterar Imagem'),
                              ),
                              TextButton.icon(
                                onPressed: _removeImage,
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: const Text('Remover Imagem'),
                              ),
                            ],
                          ),
                        ],
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _saveRestaurant,
                      child: const Text('Salvar'),
                    ),
                    ElevatedButton(
                      onPressed: _cancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
