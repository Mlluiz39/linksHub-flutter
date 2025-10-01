import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/social_link.dart';
import '../services/api_service.dart';
import '../../screens/add_edit_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _databaseService = ApiService();
  List<SocialLink> _socialLinks = [];
  List<SocialLink> _filteredLinks = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSocialLinks();
    _searchController.addListener(_filterLinks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSocialLinks() async {
    setState(() => _isLoading = true);
    final links = await _databaseService.getAllSocialLinks();
    setState(() {
      _socialLinks = links;
      _filteredLinks = links;
      _isLoading = false;
    });
  }

  void _filterLinks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLinks = _socialLinks.where((link) {
        return link.platform.toLowerCase().contains(query) ||
            link.username.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _launchUrl(String url) async {
    // Garantir que a URL tenha o prefixo http:// ou https://
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir: $url')),
        );
      }
    }
  }

  Future<void> _deleteSocialLink(SocialLink link) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir o link do ${link.platform}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _databaseService.deleteSocialLink(link.id!);
      await _loadSocialLinks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link excluído com sucesso!')),
        );
      }
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'twitter':
      case 'x':
        return FontAwesomeIcons.twitter;
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'tiktok':
        return FontAwesomeIcons.tiktok;
      case 'github':
        return FontAwesomeIcons.github;
      case 'whatsapp':
        return FontAwesomeIcons.whatsapp;
      case 'telegram':
        return FontAwesomeIcons.telegram;
      default:
        return FontAwesomeIcons.link;
    }
  }
  
  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return const Color(0xFFE1306C); // Rosa Instagram
      case 'facebook':
        return const Color(0xFF1877F2); // Azul Facebook
      case 'twitter':
      case 'x':
        return const Color(0xFF1DA1F2); // Azul Twitter
      case 'linkedin':
        return const Color(0xFF0A66C2); // Azul LinkedIn
      case 'youtube':
        return const Color(0xFFFF0000); // Vermelho YouTube
      case 'tiktok':
        return const Color(0xFF000000); // Preto TikTok
      case 'github':
        return const Color(0xFF333333); // Cinza escuro GitHub
      case 'whatsapp':
        return const Color(0xFF25D366); // Verde WhatsApp
      case 'telegram':
        return const Color(0xFF0088CC); // Azul Telegram
      case 'snapchat':
        return const Color(0xFFFFFC00); // Amarelo Snapchat
      case 'pinterest':
        return const Color(0xFFE60023); // Vermelho Pinterest
      case 'discord':
        return const Color(0xFF5865F2); // Roxo Discord
      default:
        return Colors.blue; // Cor padrão
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Links Redes Sociais'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/welcome');
          },
          tooltip: 'Voltar para Welcome',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar links...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredLinks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.link_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Nenhum link cadastrado'
                                  : 'Nenhum resultado encontrado',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Adicione seus links favoritos das redes sociais.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredLinks.length,
                        itemBuilder: (context, index) {
                          final link = _filteredLinks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: FaIcon(
                                _getPlatformIcon(link.platform),
                                color: _getPlatformColor(link.platform),
                              ),
                              title: Text(
                                link.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(link.platform),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'open',
                                    child: Row(
                                      children: [
                                        Icon(Icons.open_in_new),
                                        SizedBox(width: 8),
                                        Text('Abrir link'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 8),
                                        Text('Editar'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Excluir',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) async {
                                  switch (value) {
                                    case 'open':
                                      await _launchUrl(link.url);
                                      break;
                                    case 'edit':
                                      final result =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddEditScreen(socialLink: link),
                                        ),
                                      );
                                      if (result == true) {
                                        await _loadSocialLinks();
                                      }
                                      break;
                                    case 'delete':
                                      await _deleteSocialLink(link);
                                      break;
                                  }
                                },
                              ),
                              onTap: () => _launchUrl(link.url),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditScreen(),
            ),
          );
          if (result == true) {
            await _loadSocialLinks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
