import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../models/social_link.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'social_links.db');
    
    // Não deletamos mais o banco para permitir persistência
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adiciona a coluna name na versão 2
      try {
        await db.execute('ALTER TABLE social_links ADD COLUMN name TEXT DEFAULT ""');
      } catch (e) {
        print('Erro ao adicionar coluna name: $e');
        // Se falhar, tenta recriar a tabela com todos os dados
        await _recreateTableWithName(db);
      }
    }
  }
  
  Future<void> _recreateTableWithName(Database db) async {
    await db.transaction((txn) async {
      // 1. Renomear a tabela atual
      await txn.execute('ALTER TABLE social_links RENAME TO social_links_old');
      
      // 2. Criar a nova tabela com a estrutura atualizada
      await txn.execute('''
        CREATE TABLE social_links (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          platform TEXT NOT NULL,
          username TEXT NOT NULL,
          url TEXT NOT NULL,
          name TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      
      // 3. Copiar os dados da tabela antiga para a nova, definindo name como platform
      await txn.execute('''
        INSERT INTO social_links (id, platform, username, url, name, created_at, updated_at)
        SELECT id, platform, username, url, platform, created_at, updated_at
        FROM social_links_old
      ''');
      
      // 4. Excluir a tabela antiga
      await txn.execute('DROP TABLE social_links_old');
    });
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE social_links (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        platform TEXT NOT NULL,
        username TEXT NOT NULL,
        url TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertSocialLink(SocialLink link) async {
    final db = await database;
    return await db.insert('social_links', link.toMap());
  }

  Future<List<SocialLink>> getAllSocialLinks() async {
    final db = await database;
    final maps = await db.query('social_links', orderBy: 'created_at DESC');
    
    return List.generate(maps.length, (i) {
      return SocialLink.fromMap(maps[i]);
    });
  }

  Future<SocialLink?> getSocialLink(int id) async {
    final db = await database;
    final maps = await db.query(
      'social_links',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return SocialLink.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSocialLink(SocialLink link) async {
    final db = await database;
    return await db.update(
      'social_links',
      link.toMap(),
      where: 'id = ?',
      whereArgs: [link.id],
    );
  }

  Future<int> deleteSocialLink(int id) async {
    final db = await database;
    return await db.delete(
      'social_links',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<SocialLink>> searchSocialLinks(String query) async {
    final db = await database;
    final maps = await db.query(
      'social_links',
      where: 'platform LIKE ? OR username LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return SocialLink.fromMap(maps[i]);
    });
  }
}
