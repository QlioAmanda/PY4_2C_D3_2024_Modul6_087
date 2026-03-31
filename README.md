<<<<<<< HEAD
# 📔 Resilient & Collaborative Logbook - Modul 5

Aplikasi **Logbook digital tingkat lanjut** yang mengimplementasikan arsitektur **Offline-First** dan **Collaborative Intelligence**.  
Versi ini memastikan aplikasi tetap dapat digunakan **tanpa koneksi internet** dengan **sinkronisasi biner otomatis ke MongoDB Atlas**.

---

## 👤 Identitas Mahasiswa

**Nama** : Qlio Amanda Febriany  
**NIM** : 241511087  
**Kelas** : 2C - D3 Teknik Informatika  

---

## 🚀 Fitur Unggulan (Modul 5)

### 1. Offline-First Persistence
Menggunakan **Hive (Local Storage Biner)** untuk akses data instan tanpa delay internet.

### 2. Hybrid Sync Manager
Sinkronisasi cerdas yang menyimpan data ke **local storage terlebih dahulu**, lalu mengunggahnya ke **Cloud** saat koneksi tersedia.

### 3. Markdown Workspace
Editor teks kaya yang mendukung format **Markdown** (Bold, Header, Code Blocks) untuk dokumentasi teknis yang profesional.

### 4. Data Sovereignty & RBAC
Kontrol akses tingkat lanjut di mana hanya **pemilik catatan** yang dapat mengubah atau menghapus datanya sendiri, serta fitur privasi (**Private vs Public Log**).

### 5. Collaborative Team-ID
Isolasi data berbasis **kelompok**, sehingga antar tim tidak dapat melihat data satu sama lain walaupun menggunakan database yang sama.

---

## 🛠️ Stack Teknologi

- **Flutter & Dart** — Core framework aplikasi
- **Hive & Hive Flutter** — Basis data NoSQL lokal berbasis biner untuk performa tinggi
- **MongoDB Atlas** — Repositori pusat sebagai *Global Truth* data tim
- **flutter_markdown** — Rendering engine untuk visualisasi dokumen Markdown
- **connectivity_plus** — Pemantauan status jaringan secara real-time untuk pemicu sinkronisasi

---

## 🧠 Lesson Learned (Refleksi Modul 5)

### 1. Kecepatan Biner vs Latensi Cloud
Saya mempelajari bahwa memberikan pengalaman **Instant UI** hanya mungkin dilakukan jika kita memprioritaskan penyimpanan lokal.  
Mengintegrasikan **Hive dengan TypeAdapter otomatis melalui build_runner** mengajarkan saya cara menangani **serialisasi data biner** yang jauh lebih efisien dibandingkan JSON biasa.

### 2. Keamanan Terpusat (Gatekeeper Pattern)
Tantangan terbesar di modul ini adalah memindahkan logika keamanan dari tombol UI ke dalam **Access Control Service**.  
Saya belajar bahwa dengan memusatkan kebijakan akses (**RBAC**), aplikasi menjadi lebih **scalable** dan aman dari upaya manipulasi data ilegal oleh user yang tidak berwenang.

### 3. Kedaulatan Data (Data Sovereignty)
Melalui implementasi fitur privasi, saya memahami perbedaan antara **hak akses berdasarkan peran (Role-Based)** dan **hak akses berdasarkan kepemilikan (Owner-Based)**.  
Memastikan bahwa **ketua tim sekalipun tidak dapat menghapus catatan privat anggota** merupakan penerapan **etika privasi data** yang krusial dalam dunia industri.
=======
# PY4_2C_D3_2024_Modul6_087
>>>>>>> 39fc7c7c105dfbbd09fe20525b29dac3d84bf726
