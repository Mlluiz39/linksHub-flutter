import 'package:flutter/material.dart';
import '../../../models/social_link.dart';
import '../../../services/database_service.dart';

class AddEditScreen extends StatefulWidget {
  final SocialLink? socialLink;

  const AddEditScreen({super.key, this.socialLink});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _platformController = TextEditingController();
  final _urlController = TextEditingController();
  final _nameController = TextEditingController(); // Controlador para o nome do link
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  final List<String> _popularPlatforms = [
    'Instagram',
    'Facebook',
    'Twitter/X',
    'LinkedIn',
    'YouTube',
    'TikTok',
    'GitHub',
    'WhatsApp',
    'Telegram',
    'Snapchat',
    'Pinterest',
    'Discord',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.socialLink != null) {
      _platformController.text = widget.socialLink!.platform;
      _urlController.text = widget.socialLink!.url;
      _nameController.text = widget.socialLink!.name;
    }
  }

  @override
  void dispose() {
    _platformController.dispose();
    _urlController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onPlatformChanged(String platform) {
    _platformController.text = platform;
  }

  Future<void> _saveSocialLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final socialLink = SocialLink(
        id: widget.socialLink?.id,
        platform: _platformController.text.trim(),
        username: "",
        url: _urlController.text.trim(),
        name: _nameController.text.trim(),
        createdAt: widget.socialLink?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.socialLink == null) {
        await _databaseService.insertSocialLink(socialLink);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link adicionado com sucesso!')),
          );
        }
      } else {
        await _databaseService.updateSocialLink(socialLink);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link atualizado com sucesso!')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.socialLink == null ? 'Adicionar Link' : 'Editar Link'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Plataforma',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _platformController.text),
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return _popularPlatforms;
                }
                return _popularPlatforms.where((platform) =>
                    platform.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: _onPlatformChanged,
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                _platformController.text = controller.text;
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  decoration: const InputDecoration(
                    hintText: 'Ex: Instagram, Facebook, Twitter...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.public),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe a plataforma';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _platformController.text = value;
                    _onPlatformChanged(value);
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Nome do link',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Ex: Meu Instagram, GitHub Pessoal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, informe um nome para o link';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'URL do link',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'https://...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, informe a URL';
                }
                final uri = Uri.tryParse(value.trim());
                if (uri == null || !uri.hasScheme) {
                  return 'Por favor, informe uma URL válida';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveSocialLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.socialLink == null ? 'Adicionar Link' : 'Atualizar Link',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: const Text('Voltar para Home'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.blue),
                foregroundColor: Colors.blue,
              ),
            ),
            if (widget.socialLink == null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Dica',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'A URL será gerada automaticamente com base no link, você pode editá-la manualmente se necessário.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
