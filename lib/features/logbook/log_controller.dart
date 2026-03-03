// Nama : Qlio Amanda Febriany | Nim : 241511087 | Kelas : 2C
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'models/log_model.dart';
import '../../services/mongo_service.dart';
import '../../helpers/log_helper.dart'; // Import LogHelper

class LogController {
  // --- STATE (JANGAN UBAH AGAR UI AMAN) ---
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogsNotifier = ValueNotifier([]);
  final String username;
  
  String _currentQuery = ""; 
  String _currentCategoryFilter = "Semua";
  
  // Panggil Service
  final MongoService _mongoService = MongoService();

  LogController(this.username); // Constructor tidak perlu panggil load dulu, nanti dipanggil UI

  // --- LOGIKA CLOUD (Sesuai Modul 4) ---
  
  // [MODUL 4] Mengambil Data (Dulu fetchLogs, sekarang loadFromDisk sesuai modul)
  Future<void> loadFromDisk() async {
    try {
      // Ambil data dari Cloud via Service
      final cloudData = await _mongoService.getLogs();
      logsNotifier.value = cloudData;
      
      // [PENTING] Refresh Filter agar data muncul di Search/List UI kamu
      _refreshFilter(); 
      
      await LogHelper.writeLog("UI: Data berhasil dimuat ke Notifier.", source: "log_controller.dart");
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal load data - $e", level: 1);
    }
  }

  // Tambah Data
  Future<void> addLog(String title, String description, String category) async {
    try {
      final newLog = LogModel(
        id: ObjectId(), 
        title: title,
        description: description,
        date: DateTime.now().toString(),
        category: category,
      );
      
      await _mongoService.insertLog(newLog);
      await loadFromDisk(); // Refresh data
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal tambah data - $e", level: 1);
      rethrow;
    }
  }

  // Update Data
  Future<void> updateLog(int index, String newTitle, String newDesc, String newCategory) async {
    try {
      // Cari data asli dari filtered list (biar ga salah edit pas lagi searching)
      LogModel targetLog = filteredLogsNotifier.value[index];
      if (targetLog.id == null) return;

      final updatedLog = LogModel(
        id: targetLog.id, 
        title: newTitle,
        description: newDesc,
        date: targetLog.date, 
        category: newCategory,
      );

      await _mongoService.updateLog(updatedLog);
      await loadFromDisk(); // Refresh
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal update - $e", level: 1);
    }
  }

  // [MODUL 4] Hapus Data
  Future<void> deleteLog(int index) async {
    try {
      LogModel targetLog = filteredLogsNotifier.value[index];
      if (targetLog.id == null) return;

      await _mongoService.deleteLog(targetLog.id!);
      await loadFromDisk(); // Refresh
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal hapus - $e", level: 1);
    }
  }

  // --- LOGIKA FILTER & SEARCH (TETAP PERTAHANKAN INI) ---
  void searchLog({String? query, String? category}) {
    if (query != null) _currentQuery = query;
    if (category != null) _currentCategoryFilter = category;
    _refreshFilter();
  }

  void resetFilter() {
    _currentQuery = "";
    _currentCategoryFilter = "Semua";
    _refreshFilter();
  }

  void _refreshFilter() {
    List<LogModel> results = logsNotifier.value;

    if (_currentCategoryFilter != "Semua") {
      results = results.where((log) => log.category == _currentCategoryFilter).toList();
    }

    if (_currentQuery.isNotEmpty) {
      final queryLower = _currentQuery.toLowerCase();
      results = results.where((log) {
        final titleMatch = log.title.toLowerCase().contains(queryLower);
        final descMatch = log.description.toLowerCase().contains(queryLower);
        return titleMatch || descMatch;
      }).toList();
    }
    filteredLogsNotifier.value = results;
  }
}