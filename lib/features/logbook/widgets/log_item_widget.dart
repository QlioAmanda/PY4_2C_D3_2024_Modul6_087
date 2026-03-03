// File: lib/features/logbook/widgets/log_item_widget.dart
// Nama : Qlio Amanda Febriany | Nim : 241511087 | Kelas : 2C

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_model.dart';

class LogItemWidget extends StatelessWidget {
  final LogModel log;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LogItemWidget({
    super.key,
    required this.log,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('d MMM yyyy, HH:mm').format(dt);
    } catch (e) {
      return isoDate;
    }
  }

  Color get _categoryColor {
    switch (log.category) {
      case 'Pribadi': return const Color(0xFFAB47BC);
      case 'Urgent': return const Color(0xFFEF5350);
      case 'Pekerjaan': 
      default: return const Color(0xFF1565C0);
    }
  }
  
  IconData get _categoryIcon {
    switch (log.category) {
      case 'Pribadi': return Icons.favorite_rounded;
      case 'Urgent': return Icons.warning_rounded;
      case 'Pekerjaan': 
      default: return Icons.work_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = _categoryColor;

    return Dismissible(
      key: ValueKey(log.date + log.title),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async => await _showConfirmDialog(context),
      onDismissed: (direction) => onDelete(),

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: themeColor, width: 6)),
          boxShadow: [
            BoxShadow(color: Colors.blueGrey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap, 
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. IKON (Kiri)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(_categoryIcon, color: themeColor, size: 24),
                  ),
                  
                  const SizedBox(width: 12),

                  // 2. AREA KONTEN (Tengah - DIBUNGKUS EXPANDED UNTUK CEGAH OVERFLOW)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BARIS ATAS: Kategori & Author
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                log.category.toUpperCase(),
                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: themeColor),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(4)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person, size: 10, color: Colors.blueGrey.shade600),
                                  const SizedBox(width: 2),
                                  Text(log.author, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Judul
                        Text(
                          log.title,
                          style: const TextStyle(color: Color(0xFF37474F), fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        // Deskripsi Singkat
                        Text(
                          log.description,
                          style: const TextStyle(color: Color(0xFF757575), fontSize: 12),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 3. INFO WAKTU & TOMBOL EDIT (Kanan)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(log.date),
                        style: TextStyle(fontSize: 9, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 8),
                      _buildActionButton(Icons.edit_rounded, themeColor, onEdit, "Edit"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap, String tooltip) {
    return Container(
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: color, size: 18),
        onPressed: onTap,
        tooltip: tooltip,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(6),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Hapus Catatan?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Yakin ingin menghapus catatan ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}