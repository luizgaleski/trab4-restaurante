import 'package:flutter/material.dart';
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
      _selectedDate = widget.restaurant!['dataVisita'] != null
          ? DateFormat('dd/MM/yyyy').format(widget.restaurant!['dataVisita'].toDate())
          : null;
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null
          ? DateFormat('dd/MM/yyyy').parse(_selectedDate!)
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ),
          child: child!,
        );
      },
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
        'tipoComida': _selectedCategory ?? '',
        'dataVisita': _selectedDate != null
            ? DateFormat('dd/MM/yyyy').parse(_selectedDate!)
            : DateTime.now(),
        'pedido': _orderController.text,
        'comentario': _commentController.text,
      };

      try {
        if (widget.restaurant == null) {
          await _firestoreService.createRestaurant(
            nome: restaurantData['nome'] as String,
            nota: restaurantData['nota'] as double,
            imagem: '', // Definindo imagem vazia
            tipoComida: restaurantData['tipoComida'] as String,
            dataVisita: restaurantData['dataVisita'] as DateTime,
            pedido: restaurantData['pedido'] as String,
            comentario: restaurantData['comentario'] as String,
          );
        } else {
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
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.restaurant == null ? 'Adicionar Restaurante' : 'Editar Restaurante',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 2,
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
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Este campo é obrigatório' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _ratingController,
                  decoration: const InputDecoration(
                    labelText: 'Nota (0 a 5)',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
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
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Restaurante',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
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
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      controller: TextEditingController(text: _selectedDate),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Selecione uma data' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _orderController,
                  decoration: const InputDecoration(
                    labelText: 'Pedido',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: 'Comentário',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _saveRestaurant,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Salvar'),
                    ),
                    ElevatedButton(
                      onPressed: _cancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.red,
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
