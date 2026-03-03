// Nama : Qlio Amanda Febriany | Nim : 241511087 | Kelas : 2C
import 'package:flutter/material.dart';
import 'dart:math';
import 'log_controller.dart';
import 'models/log_model.dart';
import '../../auth/login_view.dart';
import 'widgets/log_item_widget.dart';
import '../../services/mongo_service.dart'; 

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late LogController _controller;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Variabel status loading
  bool _isLoading = true; 

  // Variabel Filter (Sekarang DIPAKAI lagi)
  String _selectedCategory = 'Pekerjaan';
  String _filterCategory = 'Semua'; 
  final List<String> _categories = ['Pekerjaan', 'Pribadi', 'Urgent'];
  final List<String> _filterCategories = ['Semua', 'Pekerjaan', 'Pribadi', 'Urgent'];

  int _currentPage = 0;
  final int _itemsPerPage = 10;

  final Color _bgPastel = const Color(0xFFE1F5FE);     
  final Color _themeColor = const Color(0xFF4DB6AC);   
  final Color _textNavy = const Color(0xFF37474F);     

  @override
  void initState() {
    super.initState();
    _controller = LogController(widget.username);
    
    _controller.filteredLogsNotifier.addListener(() {
      if (mounted) setState(() => _currentPage = 0);
    });

    Future.microtask(() => _initDatabase());
  }

  // Fungsi Koneksi dengan Error Handling Cantik (Homework Task 1)
  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    try {
      await MongoService().connect().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception("Koneksi Timeout. Cek Sinyal."),
      );
      await _controller.loadFromDisk();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.toString().contains('SocketException') || e.toString().contains('Timeout')
                      ? "Ups, sepertinya internetmu terputus! Pastikan koneksi menyala ya."
                      : "Gagal terhubung ke Cloud. Coba lagi nanti."
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: "Coba Lagi", textColor: Colors.white, onPressed: _initDatabase),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- DIALOGS (Tetap Sama) ---
  void _showDetailDialog(LogModel log) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _getCategoryColor(log.category).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(_getCategoryIcon(log.category), color: _getCategoryColor(log.category)),
                  const SizedBox(width: 10),
                  Text(log.category.toUpperCase(), style: TextStyle(color: _getCategoryColor(log.category), fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context))
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(log.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textNavy)),
                    const SizedBox(height: 8),
                    // Tanggal akan diformat oleh widget item, disini raw string
                    Text(log.date, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    const SizedBox(height: 20),
                    Text(log.description, style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade700, height: 1.6)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogDialog({LogModel? log, int? index}) {
    bool isEdit = log != null;
    if (isEdit) {
      _titleController.text = log.title;
      _descController.text = log.description;
      _selectedCategory = log.category; 
    } else {
      _titleController.clear();
      _descController.clear();
      _selectedCategory = 'Pekerjaan'; 
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: SingleChildScrollView(
              child: SizedBox(
                width: double.maxFinite,
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(isEdit ? "Edit Catatan" : "Tulis Baru", style: TextStyle(color: _textNavy, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 20),
                    _buildDialogTextField(_titleController, "Judul..."),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          items: _categories.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                          onChanged: (newValue) => setStateDialog(() => _selectedCategory = newValue!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDialogTextField(_descController, "Isi catatan...", maxLines: 5, minLines: 3),
                ]),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: Colors.grey.shade600))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _themeColor, foregroundColor: Colors.white),
                onPressed: () {
                  if (_titleController.text.trim().isEmpty) return;
                  if (isEdit) {
                    _controller.updateLog(index!, _titleController.text, _descController.text, _selectedCategory);
                    _showSnackBar("Berhasil diupdate!", isError: false);
                  } else {
                    _controller.addLog(_titleController.text, _descController.text, _selectedCategory);
                    _showSnackBar("Tersimpan!", isError: false);
                  }
                  Navigator.pop(context);
                },
                child: Text(isEdit ? "Update" : "Simpan"),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Keluar?"), content: const Text("Sesi Anda akan berakhir."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView())); },
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField(TextEditingController ctrl, String hint, {int maxLines = 1, int minLines = 1}) {
    return TextField(controller: ctrl, maxLines: maxLines, minLines: minLines, decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))));
  }

  Color _getCategoryColor(String cat) {
    if (cat == 'Pribadi') return const Color(0xFFAB47BC);
    if (cat == 'Urgent') return const Color(0xFFEF5350);
    return const Color(0xFF1565C0);
  }

  IconData _getCategoryIcon(String cat) {
    if (cat == 'Pribadi') return Icons.favorite_border;
    if (cat == 'Urgent') return Icons.warning_amber_rounded;
    return Icons.work_outline;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : _themeColor));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPastel, 
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("LOGBOOK", style: TextStyle(fontSize: 14, color: Colors.white70)),
            Text(widget.username, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
        backgroundColor: _themeColor, elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white), onPressed: _showLogoutConfirmation),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _themeColor, foregroundColor: Colors.white,
        onPressed: () => _showLogDialog(),
        icon: const Icon(Icons.edit_outlined), label: const Text("Tulis Baru"),
      ),
      body: Column(
        children: [
          // 1. AREA SEARCH & FILTER (KEMBALI LENGKAP)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                // SEARCH BAR
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _controller.searchLog(query: value), 
                    decoration: InputDecoration(
                      hintText: "Cari...",
                      prefixIcon: Icon(Icons.search, color: _themeColor),
                      filled: true, fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // FILTER DROPDOWN (YANG HILANG TADI, SEKARANG KEMBALI)
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  clipBehavior: Clip.antiAlias, 
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterCategory,
                      icon: Icon(Icons.filter_list_rounded, color: _themeColor),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      items: _filterCategories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 13, color: _textNavy)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() => _filterCategory = newValue!);
                        _controller.searchLog(category: newValue!);
                      },
                    ),
                  ),
                ),
                
                // TOMBOL RESET
                if (_searchController.text.isNotEmpty || _filterCategory != 'Semua') 
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: CircleAvatar(
                      backgroundColor: Colors.red.shade100,
                      radius: 24,
                      child: IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Colors.red, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _filterCategory = 'Semua');
                          _controller.resetFilter();
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 2. LIST DATA (DENGAN LOADING & REFRESH)
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: _themeColor))
              : ValueListenableBuilder<List<LogModel>>(
                  valueListenable: _controller.filteredLogsNotifier, 
                  builder: (context, allLogs, child) {
                    if (allLogs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off_rounded, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
                            const SizedBox(height: 10),
                            const Text("Belum ada data di Cloud", style: TextStyle(fontSize: 16, color: Colors.grey)),
                              TextButton.icon(
                                // Panggil _initDatabase biar proses koneksi & cek error diulang dari awal
                                onPressed: _initDatabase, 
                                icon: const Icon(Icons.refresh), 
                                label: const Text("Coba Refresh")
                              )
                          ],
                        ),
                      );
                    }

                    // Pagination
                    final totalItems = allLogs.length;
                    final startIndex = _currentPage * _itemsPerPage;
                    final endIndex = min(startIndex + _itemsPerPage, totalItems);
                    final safeEndIndex = endIndex > totalItems ? totalItems : endIndex;
                    final safeStartIndex = startIndex > safeEndIndex ? 0 : startIndex;
                    final paginatedLogs = allLogs.sublist(safeStartIndex, safeEndIndex);

                    // Pull-to-Refresh Widget
                    return RefreshIndicator(
                      onRefresh: () async {
                        await _controller.loadFromDisk();
                        _showSnackBar("Data Cloud Diperbarui!");
                      },
                      color: _themeColor,
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              itemCount: paginatedLogs.length,
                              itemBuilder: (context, index) {
                                final realIndex = safeStartIndex + index; 
                                return LogItemWidget(
                                  log: paginatedLogs[index],
                                  onTap: () => _showDetailDialog(paginatedLogs[index]), 
                                  onEdit: () => _showLogDialog(log: paginatedLogs[index], index: realIndex), 
                                  onDelete: () {
                                    _controller.deleteLog(realIndex);
                                    _showSnackBar("Catatan dihapus.", isError: true);
                                  },
                                );
                              },
                            ),
                          ),
                          // Pagination Controls
                          if (totalItems > _itemsPerPage) 
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null, icon: const Icon(Icons.chevron_left)),
                                  Text("Halaman ${_currentPage + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: _textNavy)),
                                  IconButton(onPressed: safeEndIndex < totalItems ? () => setState(() => _currentPage++) : null, icon: const Icon(Icons.chevron_right)),
                                ],
                              ),
                            ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}