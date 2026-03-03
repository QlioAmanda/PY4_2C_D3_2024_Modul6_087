import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_087/features/logbook/models/log_model.dart';
import 'package:logbook_app_087/helpers/log_helper.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  Db? _db;
  DbCollection? _collection;
  final String _source = "mongo_service.dart";

  factory MongoService() => _instance;
  MongoService._internal();

  Future<DbCollection> _getSafeCollection() async {
    if (_db == null || !_db!.isConnected || _collection == null) {
      await LogHelper.writeLog("INFO: Koleksi belum siap, mencoba rekoneksi...", source: _source, level: 3);
      await connect();
    }
    return _collection!;
  }

  Future<void> connect() async {
    try {
      final dbUri = dotenv.env['MONGODB_URI'];
      if (dbUri == null) throw Exception("MONGODB_URI tidak ditemukan di .env");

      _db = await Db.create(dbUri);
      await _db!.open().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception("Koneksi Timeout. Cek IP Whitelist atau Sinyal HP."),
      );

      _collection = _db!.collection('logs');
      await LogHelper.writeLog("DATABASE: Terhubung & Koleksi Siap", source: _source, level: 2);
    } catch (e) {
      await LogHelper.writeLog("DATABASE: Gagal Koneksi - $e", source: _source, level: 1);
      rethrow;
    }
  }

  // [PERBAIKAN] Menambahkan parameter author untuk memfilter data milik user tertentu
  Future<List<LogModel>> getLogs(String author) async {
    try {
      final collection = await _getSafeCollection();
      await LogHelper.writeLog("INFO: Fetching data from Cloud for author: $author...", source: _source, level: 3);
      
      // Mengambil data yang hanya memiliki author sesuai username yang login
      final data = await collection.find(
        where.eq('author', author).sortBy('date', descending: true)
      ).toList();
      
      return data.map((json) => LogModel.fromMap(json)).toList();
    } catch (e) {
      await LogHelper.writeLog("ERROR: Fetch Failed - $e", source: _source, level: 1);
      return [];
    }
  }

  Future<void> insertLog(LogModel log) async {
    try {
      final collection = await _getSafeCollection();
      await collection.insertOne(log.toMap());
      await LogHelper.writeLog("SUCCESS: Data '${log.title}' Saved to Cloud", source: _source, level: 2);
    } catch (e) {
      await LogHelper.writeLog("ERROR: Insert Failed - $e", source: _source, level: 1);
      rethrow;
    }
  }

  Future<void> updateLog(LogModel log) async {
    try {
      final collection = await _getSafeCollection();
      if (log.id == null) throw Exception("ID Log tidak ditemukan untuk update");

      var modifier = ModifierBuilder()
        .set('title', log.title)
        .set('description', log.description)
        .set('category', log.category)
        .set('date', log.date)
        .set('author', log.author); 

      await collection.update(where.id(log.id!), modifier);
      await LogHelper.writeLog("DATABASE: Update '${log.title}' Berhasil", source: _source, level: 2);
    } catch (e) {
      await LogHelper.writeLog("DATABASE: Update Gagal - $e", source: _source, level: 1);
      rethrow;
    }
  }

  Future<void> deleteLog(ObjectId id) async {
    try {
      final collection = await _getSafeCollection();
      await collection.remove(where.id(id));
      await LogHelper.writeLog("DATABASE: Hapus ID $id Berhasil", source: _source, level: 2);
    } catch (e) {
      await LogHelper.writeLog("DATABASE: Hapus Gagal - $e", source: _source, level: 1);
      rethrow;
    }
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      await LogHelper.writeLog("DATABASE: Koneksi ditutup", source: _source, level: 2);
    }
  }
}