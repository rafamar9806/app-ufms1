import 'dart:io';
import 'package:app1/models/%20%20%20%20%20%20cftv_info.dart';
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'add_edit_cftv_screen.dart';

class CftvListScreen extends StatefulWidget {
  const CftvListScreen({super.key});

  @override
  State<CftvListScreen> createState() => _CftvListScreenState();
}

class _CftvListScreenState extends State<CftvListScreen> {
  late Future<List<CftvInfo>> _cftvListFuture;

  @override
  void initState() {
    super.initState();
    _refreshCftvList();
  }

  void _refreshCftvList() {
    setState(() {
      _cftvListFuture = DatabaseHelper.instance.readAllCftvs();
    });
  }

  void _navigateToAddEditScreen([CftvInfo? cftv]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditCftvScreen(cftv: cftv)),
    );
    if (result == true) {
      _refreshCftvList();
    }
  }

  void _deleteCftv(int id) async {
    await DatabaseHelper.instance.delete(id);
    _refreshCftvList();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro CFTV deletado com sucesso!')),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(CftvInfo cftv) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Você tem certeza que deseja excluir o registro de "${cftv.nome}"?',
                ),
                const Text('Esta ação não pode ser desfeita.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
              onPressed: () {
                _deleteCftv(cftv.id!);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registros CFTV')),
      body: FutureBuilder<List<CftvInfo>>(
        future: _cftvListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nenhum registro CFTV encontrado.'),
            );
          }

          final cftvs = snapshot.data!;
          return ListView.builder(
            itemCount: cftvs.length,
            itemBuilder: (context, index) {
              final cftv = cftvs[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: ListTile(
                  leading:
                      cftv.imagePath != null &&
                          File(cftv.imagePath!).existsSync()
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Image.file(
                            File(cftv.imagePath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 50);
                            },
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey,
                        ),
                  title: Text(
                    cftv.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'IP: ${cftv.ip}\nMAC: ${cftv.mac}\nS/N: ${cftv.numeroSerie}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _navigateToAddEditScreen(cftv),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _showDeleteConfirmationDialog(cftv),
                      ),
                    ],
                  ),
                  onTap: () => _navigateToAddEditScreen(cftv),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
