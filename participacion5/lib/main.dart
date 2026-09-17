import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Usuarios con vocal inicial',
      home: const UsersScreen(),
    );
  }
}

/// Pantalla única e intencionalmente monolítica:
/// aquí conviven la llamada HTTP, el jsonDecode, el filtrado
/// y la construcción de la UI, sin repositorios ni capas.
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  static const _vowels = ['a', 'e', 'i', 'o', 'u'];

  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // --- Llamada HTTP + jsonDecode + filtrado, todo junto ---
  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/users'),
      );

      if (response.statusCode != 200) {
        setState(() {
          _errorMessage = 'Error del servidor: ${response.statusCode}';
          _isLoading = false;
        });
        return;
      }

      final List<dynamic> data = jsonDecode(response.body);

      final filtered = data.where((user) {
        final String name = (user['name'] as String? ?? '').trim();
        if (name.isEmpty) return false;
        return _vowels.contains(name[0].toLowerCase());
      }).toList();

      setState(() {
        _filteredUsers = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo obtener la lista de usuarios: $e';
        _isLoading = false;
      });
    }
  }

  // --- Construcción de la interfaz, en el mismo archivo/clase ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios (nombre inicia con vocal)'),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          setState(() => _isLoading = true);
          return _fetchUsers();
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Center(child: Text(_errorMessage!, textAlign: TextAlign.center)),
        ],
      );
    }

    if (_filteredUsers.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(child: Text('No hay usuarios cuyo nombre empiece con vocal.')),
        ],
      );
    }

    return ListView.builder(
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        final name = user['name'] as String? ?? '';
        return ListTile(
          leading: CircleAvatar(
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
          ),
          title: Text(name),
          subtitle: Text(user['email'] as String? ?? ''),
        );
      },
    );
  }
}