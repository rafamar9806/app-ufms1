import 'dart:io';
import 'package:app1/models/%20%20%20%20%20%20cftv_info.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../helpers/database_helper.dart';

class AddEditCftvScreen extends StatefulWidget {
  final CftvInfo? cftv;

  const AddEditCftvScreen({super.key, this.cftv});

  @override
  State<AddEditCftvScreen> createState() => _AddEditCftvScreenState();
}

class _AddEditCftvScreenState extends State<AddEditCftvScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _ipController;
  late TextEditingController _macController;
  late TextEditingController _numeroSerieController;
  XFile? _imageFile;
  String? _currentImagePath;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.cftv?.nome ?? '');
    _ipController = TextEditingController(text: widget.cftv?.ip ?? '');
    _macController = TextEditingController(text: widget.cftv?.mac ?? '');
    _numeroSerieController = TextEditingController(
      text: widget.cftv?.numeroSerie ?? '',
    );
    _currentImagePath = widget.cftv?.imagePath;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _ipController.dispose();
    _macController.dispose();
    _numeroSerieController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          _currentImagePath = null;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Erro ao selecionar imagem: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
    }
  }

  Future<String?> _saveImageToFileSystem(XFile imageFile) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = p.basename(imageFile.path);
      final String newPath = p.join(appDir.path, fileName);

      final File newImage = await File(imageFile.path).copy(newPath);
      return newImage.path;
    } catch (e) {
      // ignore: avoid_print
      print("Erro ao salvar imagem: $e");
      return null;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String? finalImagePath = _currentImagePath;

      if (_imageFile != null) {
        if (widget.cftv?.imagePath != null &&
            widget.cftv?.imagePath != _currentImagePath) {
          try {
            final oldImageFile = File(widget.cftv!.imagePath!);
            if (await oldImageFile.exists()) {
              await oldImageFile.delete();
            }
          } catch (e) {
            // ignore: avoid_print
            print("Erro ao deletar imagem antiga: $e");
          }
        }
        finalImagePath = await _saveImageToFileSystem(_imageFile!);
      } else if (_currentImagePath == null && widget.cftv?.imagePath != null) {
        try {
          final oldImageFile = File(widget.cftv!.imagePath!);
          if (await oldImageFile.exists()) {
            await oldImageFile.delete();
            print(
              "Imagem antiga ${widget.cftv!.imagePath!} deletada pois foi removida.",
            );
          }
        } catch (e) {
          print("Erro ao deletar imagem antiga que foi removida: $e");
        }
        finalImagePath = null;
      }

      final cftvInfo = CftvInfo(
        id: widget.cftv?.id,
        nome: _nomeController.text,
        ip: _ipController.text,
        mac: _macController.text,
        numeroSerie: _numeroSerieController.text,
        imagePath: finalImagePath,
      );

      if (widget.cftv == null) {
        await DatabaseHelper.instance.create(cftvInfo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro CFTV adicionado com sucesso!'),
            ),
          );
        }
      } else {
        await DatabaseHelper.instance.update(cftvInfo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro CFTV atualizado com sucesso!'),
            ),
          );
        }
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Câmera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              if (_currentImagePath != null || _imageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Remover Imagem',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    setState(() {
                      _imageFile = null;
                      _currentImagePath = null;
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Imagem removida. Salve para confirmar a remoção do arquivo.',
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cftv == null ? 'Adicionar CFTV' : 'Editar CFTV'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _submitForm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GestureDetector(
                onTap: () => _showImageSourceActionSheet(context),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageFile != null
                      ? Image.file(File(_imageFile!.path), fit: BoxFit.contain)
                      : (_currentImagePath != null &&
                                File(_currentImagePath!).existsSync()
                            ? Image.file(
                                File(_currentImagePath!),
                                fit: BoxFit.contain,
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Toque para adicionar imagem',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.image_search),
                label: const Text('Selecionar Imagem'),
                onPressed: () => _showImageSourceActionSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Cliente/Local',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ipController,
                decoration: const InputDecoration(
                  labelText: 'Endereço IP da Câmera',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.settings_ethernet),
                ),
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o IP';
                  }
                  final parts = value.split('.');
                  if (parts.length != 4 ||
                      parts.any(
                        (p) =>
                            int.tryParse(p) == null ||
                            int.parse(p) < 0 ||
                            int.parse(p) > 255,
                      )) {
                    return 'Formato de IP inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _macController,
                decoration: const InputDecoration(
                  labelText: 'Endereço MAC',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.device_hub),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o MAC';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numeroSerieController,
                decoration: const InputDecoration(
                  labelText: 'Número de Série',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o número de série';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save_alt),
                label: Text(
                  widget.cftv == null ? 'Salvar Novo' : 'Atualizar Registro',
                  style: const TextStyle(fontSize: 16),
                ),
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
