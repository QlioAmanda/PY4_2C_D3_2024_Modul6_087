// Nama : Qlio Amanda Febriany | Nim : 241511087 | Kelas : 2C
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'models/log_model.dart';
import '../../services/mongo_service.dart';
import '../../helpers/log_helper.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogsNotifier = ValueNotifier([]);
  final String username;
  
  String _currentQuery = ""; 
  String _currentCategoryFilter = "Semua";
  
  final MongoService _mongoService = MongoService();

  LogController(this.username); 

  Future<void> loadFromDisk() async {
    try {
      // [PERBAIKAN] Kirim variabel username agar Service memfilter data yang tepat
      final cloudData = await _mongoService.getLogs(username);
      logsNotifier.value = cloudData;
      _refreshFilter(); 
      await LogHelper.writeLog("UI: Data milik $username berhasil dimuat ke Notifier.", source: "log_controller.dart");
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal load data - $e", level: 1);
    }
  }

  Future<void> addLog(String title, String description, String category) async {
    try {
      final newLog = LogModel(
        id: ObjectId(), 
        title: title,
        description: description,
        date: DateTime.now().toString(),
        category: category,
        author: username, 
      );
      
      await _mongoService.insertLog(newLog);
      await loadFromDisk(); 
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal tambah data - $e", level: 1);
      rethrow;
    }
  }

  Future<void> updateLog(int index, String newTitle, String newDesc, String newCategory) async {
    try {
      LogModel targetLog = filteredLogsNotifier.value[index];
      if (targetLog.id == null) return;

      final updatedLog = LogModel(
        id: targetLog.id, 
        title: newTitle,
        description: newDesc,
        date: targetLog.date, 
        category: newCategory,
        author: targetLog.author, 
      );

      await _mongoService.updateLog(updatedLog);
      await loadFromDisk(); 
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal update - $e", level: 1);
    }
  }

  Future<void> deleteLog(int index) async {
    try {
      LogModel targetLog = filteredLogsNotifier.value[index];
      if (targetLog.id == null) return;

      await _mongoService.deleteLog(targetLog.id!);
      await loadFromDisk(); 
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal hapus - $e", level: 1);
    }
  }

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
        final authorMatch = log.author.toLowerCase().contains(queryLower); 
        return titleMatch || descMatch || authorMatch; 
      }).toList();
    }
    filteredLogsNotifier.value = results;
  }
}