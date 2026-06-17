<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/GetX-State_Management-8B5CF6?style=for-the-badge" />
  <img src="https://img.shields.io/badge/AI_Powered-NLP_%26_OCR-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white" />
  <img src="https://img.shields.io/badge/Google_Drive-Cloud_Sync-4285F4?style=for-the-badge&logo=googledrive&logoColor=white" />
</p>

# 🏛️ Arcliva AI — Aplikasi Pengelolaan Dokumen Sekretariat Berbasis AI

**Arcliva AI** adalah aplikasi mobile berbasis **Flutter** yang dirancang khusus untuk mendigitalkan, mengelola, dan mengarsipkan dokumen persuratan sekretariat secara cerdas menggunakan teknologi **Artificial Intelligence**. Aplikasi ini menggabungkan fitur OCR (Optical Character Recognition), NLP (Natural Language Processing), klasifikasi dokumen otomatis, AI chatbot kontekstual, serta integrasi **Google Drive** untuk penyimpanan awan yang aman — semuanya dalam satu platform yang elegan dan mudah digunakan.

---

## 📋 Daftar Isi

- [Gambaran Umum](#-gambaran-umum)
- [Arsitektur Aplikasi](#-arsitektur-aplikasi)
- [Tech Stack & Dependencies](#-tech-stack--dependencies)
- [Struktur Folder Proyek](#-struktur-folder-proyek)
- [Fitur-Fitur Utama](#-fitur-fitur-utama)
- [Halaman Aplikasi (Detail)](#-halaman-aplikasi-detail)
  - [1. Login Page](#1--login-page)
  - [2. Register Page](#2--register-page)
  - [3. Forgot Password Page](#3--forgot-password-page)
  - [4. Home Page](#4--home-page)
  - [5. Archive (Document List) Page](#5--archive-document-list-page)
  - [6. Archive Detail Page](#6--archive-detail-page)
  - [7. Assignment Letter Form Page](#7--assignment-letter-form-page-buat-surat-tugas)
  - [8. AI Chat Page (ArclivaAI)](#8--ai-chat-page-arclivaai)
  - [9. Insight & Analytics Page](#9--insight--analytics-page)
  - [10. Profile & Settings Page](#10--profile--settings-page)
  - [11. Manage Enterprise Page](#11--manage-enterprise-page-manajemen-organisasi)
  - [12. Security & Password Page](#12--security--password-page)
  - [13. Notification Settings Page](#13--notification-settings-page)
- [Flow Penggunaan Aplikasi](#-flow-penggunaan-aplikasi)
- [Fitur-Fitur Cerdas AI](#-fitur-fitur-cerdas-ai)
- [Sistem Role & Akses](#-sistem-role--akses)
- [Integrasi Google Drive](#-integrasi-google-drive)
- [Cara Menjalankan Proyek](#-cara-menjalankan-proyek)
- [Konfigurasi Backend](#-konfigurasi-backend)

---

## 🌟 Gambaran Umum

Arcliva AI lahir dari kebutuhan nyata sekretariat organisasi/gereja/perusahaan yang masih mengelola surat-menyurat secara manual. Dengan Arcliva AI, seluruh proses — mulai dari **pemindaian surat masuk**, **ekstraksi teks otomatis**, **klasifikasi jenis surat**, **ringkasan AI**, hingga **pembuatan surat tugas balasan** — diotomatisasi menggunakan pipeline kecerdasan buatan.

### Masalah yang Diselesaikan

| Masalah Tradisional | Solusi Arcliva AI |
|---|---|
| Arsip surat fisik rawan hilang/rusak | Digitalisasi & cloud backup otomatis ke Google Drive |
| Pencarian dokumen manual memakan waktu | Semantic Search berbasis AI embeddings |
| Klasifikasi surat manual oleh staff | Klasifikasi otomatis (Surat, Undangan, Kontrak, Laporan) |
| Tidak ada ringkasan cepat isi surat | AI Summary otomatis setiap dokumen |
| Disposisi surat tanpa rekomendasi | AI Disposition Suggestion berdasarkan konten |
| Pembuatan surat tugas manual | Auto-generate surat tugas dari undangan referensi |
| Tidak ada insight beban kerja | Dashboard analitik prediktif beban kerja |

---

## 🏗️ Arsitektur Aplikasi

```
┌──────────────────────────────────────────────────────┐
│                   FLUTTER APP (Client)                │
│  ┌─────────┐ ┌──────────┐ ┌────────┐ ┌────────────┐ │
│  │  Views  │ │Controllers│ │ Models │ │  Widgets   │ │
│  └────┬────┘ └─────┬─────┘ └───┬────┘ └─────┬──────┘ │
│       └──────┬─────┘           │             │        │
│         ┌────▼──────────────────▼─────────────▼──┐    │
│         │           API Service (GetConnect)      │    │
│         │    + Notification Service               │    │
│         └──────────────┬─────────────────────────┘    │
└────────────────────────┼─────────────────────────────┘
                         │  HTTPS/REST API
                         ▼
┌──────────────────────────────────────────────────────┐
│              BACKEND SERVER (REST API)                │
│  ┌────────────────────────────────────────────────┐  │
│  │  /auth     - Authentication & Organization     │  │
│  │  /document - Upload, OCR, Classification       │  │
│  │  /ai       - Chat, Summarize, Semantic Search  │  │
│  │  /reminder - Agenda & Reminders                │  │
│  │  /insight  - Analytics & Predictive Trends     │  │
│  │  /generator- Surat Tugas PDF Generator         │  │
│  └────────────────────────────────────────────────┘  │
│        ┌──────────┐ ┌──────────┐ ┌──────────────┐    │
│        │ MongoDB  │ │  AI/NLP  │ │ Google Drive │    │
│        │ Database │ │  Models  │ │   API        │    │
│        └──────────┘ └──────────┘ └──────────────┘    │
└──────────────────────────────────────────────────────┘
```

Aplikasi menggunakan arsitektur **GetX Pattern** (MVC) dengan state management reaktif:

- **Model** → Data class (`Document`, `AgendaItem`, `ChatMessage`, `ChatSession`)
- **View** → Widget Flutter untuk tampilan UI
- **Controller** → Logika bisnis & state management
- **Service** → `ApiService` (komunikasi REST API), `NotificationService` (push notif lokal)
- **Routes** → Navigasi berbasis named routes dengan lazy-loading bindings

---

## 🛠️ Tech Stack & Dependencies

| Kategori | Teknologi | Deskripsi |
|---|---|---|
| **Framework** | Flutter 3.x + Dart 3.x | Cross-platform mobile development |
| **State Management** | GetX `^4.6.6` | Reactive state, dependency injection, routing |
| **Local Storage** | GetStorage `^2.1.1` | Persistent key-value store |
| **UI Icons** | Lucide Icons `0.257.0` | Ikon modern konsisten |
| **Typography** | Google Fonts `^6.2.1` | Font Inter & Public Sans |
| **Animation** | Flutter Staggered Animations `^1.0.0` | Animasi list staggered |
| **File Handling** | Image Picker `^1.0.7`, File Picker `^8.0.0` | Pemilihan file & gambar |
| **Document Scanner** | Google ML Kit Document Scanner `^0.2.1` | Scan dokumen via kamera |
| **Date/Time** | intl `^0.19.0` | Format tanggal bahasa Indonesia |
| **WebView** | webview_flutter `^4.8.0` | Preview dokumen Google Drive |
| **URL Launcher** | url_launcher `^6.3.2` | Buka link eksternal |
| **Markdown** | flutter_markdown `^0.7.7+1` | Render respons AI dalam Markdown |
| **Sharing** | share_plus `^12.0.2` | Bagikan dokumen antar aplikasi |
| **Path Provider** | path_provider `^2.1.5` | Akses direktori lokal |
| **Notifications** | flutter_local_notifications `^21.0.0` | Notifikasi push lokal |
| **Text-to-Speech** | flutter_tts `^4.2.5` | Baca respons AI dengan suara |
| **Testing** | integration_test, flutter_driver | Automated UI testing |

---

## 📂 Struktur Folder Proyek

```
ambanotes/
├── lib/
│   ├── main.dart                          # Entry point aplikasi
│   └── app/
│       ├── data/
│       │   ├── models/
│       │   │   └── models.dart            # AgendaItem, Document, ChatMessage, ChatSession
│       │   └── services/
│       │       ├── api_service.dart        # REST API client (Auth, Document, AI, Insight, Generator)
│       │       └── notification_service.dart # Local push notification handler
│       ├── modules/
│       │   ├── login/                     # Halaman login
│       │   ├── register/                  # Halaman registrasi (2-step)
│       │   ├── forgot_password/           # Reset password via OTP
│       │   ├── home/                      # Dashboard utama + agenda + quick actions
│       │   ├── archive/                   # Daftar dokumen arsip
│       │   ├── archive_detail/            # Detail dokumen + AI summary + disposisi
│       │   ├── assignment_form/           # Form pembuatan surat tugas
│       │   ├── chat/                      # AI Chat (AmbaAI) dengan histori & TTS
│       │   ├── insight/                   # Dashboard analitik & prediksi beban kerja
│       │   ├── dashboard/                 # Shell layout (IndexedStack)
│       │   ├── add/                       # Quick create (scan, upload, note, folder)
│       │   └── profile/                   # Profil, settings, enterprise management
│       │       └── views/
│       │           ├── profile_view.dart
│       │           ├── security_view.dart
│       │           ├── notification_settings_view.dart
│       │           └── manage_enterprise_view.dart
│       ├── routes/
│       │   ├── app_pages.dart             # Route definitions + bindings
│       │   └── app_routes.dart            # Named route constants
│       ├── theme/
│       │   └── app_theme.dart             # Design system (warna, tipografi, tema Material 3)
│       └── widgets/
│           ├── custom_bottom_navbar.dart   # Bottom navigation bar glassmorphism
│           └── drive_preview_widget.dart   # Preview dokumen Google Drive (WebView)
├── integration_test/                      # Automated integration tests
├── test_driver/                           # Flutter driver test configs
├── pubspec.yaml                           # Project configuration & dependencies
└── README.md                              # Dokumentasi ini
```

---

## ✨ Fitur-Fitur Utama

### 📄 Manajemen Dokumen
- **Scan Dokumen** — Pemindaian dokumen fisik via kamera dengan ML Kit Document Scanner
- **Upload File** — Upload manual file JPG, PNG, PDF dari galeri/file manager
- **OCR Otomatis** — Ekstraksi teks dari gambar/PDF secara otomatis di server
- **Klasifikasi AI** — Kategori otomatis (Surat/Letter, Undangan/Invitation, Kontrak/Contract, Laporan/Report)
- **Preview Dokumen** — Pratinjau gambar fullscreen dengan pinch-to-zoom, atau preview PDF via WebView

### 🤖 Fitur AI (AmbaAI)
- **AI Summary** — Ringkasan otomatis setiap dokumen yang diunggah
- **AI Chat (Kontekstual)** — Tanya jawab tentang dokumen spesifik
- **AI Chat (Global)** — Chatbot umum tentang semua dokumen dalam organisasi
- **Semantic Search** — Pencarian dokumen berdasarkan makna/konteks, bukan hanya kata kunci
- **AI Disposition Suggestion** — Rekomendasi divisi penerima disposisi berdasarkan konten surat
- **AI Task Extraction** — Ekstraksi tugas/agenda dari isi surat masuk
- **AI Generate Reply** — Draft balasan surat otomatis
- **Text-to-Speech (TTS)** — Baca respons AI dengan suara
- **Referensi Dokumen** — Chatbot menampilkan sumber dokumen yang dirujuk

### 📊 Analitik & Insight
- **Statistik Dokumen** — Total surat masuk vs keluar dengan donut chart
- **Prediksi Beban Kerja** — Proyeksi 3 bulan menggunakan regresi linier historis
- **Instagram Event Insights** — Analisis engagement event dari media sosial
- **Top Akun Aktif** — Chart bar akun paling aktif
- **Hari Publikasi Teraktif** — Statistik hari paling aktif
- **Word Cloud** — Visualisasi kata kunci terpopuler dari dokumen
- **AI Weekly Summary** — Ringkasan mingguan otomatis dari AI

### 🔐 Keamanan & Cloud
- **Integrasi Google Drive** — Sinkronisasi otomatis dokumen ke cloud
- **Migrasi Berkas** — Migrasi batch dokumen lokal ke Google Drive
- **Cybersecurity Alert** — Peringatan AI jika dokumen belum di-backup ke cloud
- **Change Password** — Ubah kata sandi dengan validasi lama
- **OTP Reset Password** — Reset kata sandi via kode OTP email
- **Delete Account** — Hapus akun pengguna secara permanen

### 🏢 Manajemen Organisasi (Owner)
- **Multi-Organization** — Buat atau gabung organisasi
- **Invitation Code** — Undang anggota dengan kode 6-digit
- **Delegation/Divisi** — Buat, edit, hapus divisi internal
- **Staff Management** — Lihat & pindahkan anggota antar divisi
- **Asset Management** — Upload/kelola kop surat & tanda tangan digital per divisi
- **Disposisi Surat** — Kirim/disposisi surat ke divisi tertentu

### 📝 Generator Surat
- **Surat Tugas Otomatis** — Generate surat tugas dari undangan referensi
- **Kop Surat Dinamis** — Pilih kop surat sesuai divisi
- **Tanda Tangan Digital** — TTD digital otomatis terpasang

### 🔔 Notifikasi
- **Push Notification Lokal** — Notifikasi selesai proses AI
- **Pengaturan Notifikasi** — Kontrol jenis notifikasi yang diterima
- **Reminder/Agenda** — Pengingat agenda dari dokumen

---

## 📱 Halaman Aplikasi (Detail)

### 1. 🔑 Login Page

**Route:** `/login` (Initial Route)

Halaman pertama yang ditampilkan saat aplikasi dibuka. Menampilkan branding "AmbaNotes" dengan tagline _"Smart Secretariat & Archive Management"_.

**Komponen:**
- **Logo & Branding** — Ikon aplikasi dengan lingkaran aksen primer
- **Welcome Back** — Judul & subtitle sambutan
- **Email Field** — Input email dengan ikon mail dan validasi format
- **Password Field** — Input password dengan toggle visibility (eye icon)
- **Forgot Password Link** — Navigasi ke halaman reset password
- **Login Button** — Tombol login full-width dengan loading indicator
- **Register Link** — Link navigasi ke halaman registrasi

**Flow:**
1. User memasukkan email & password
2. Tekan tombol Login → loading indicator muncul
3. API `/auth/login` dipanggil
4. Jika berhasil → token JWT disimpan, profil di-load, navigasi ke Home
5. Jika gagal → snackbar error muncul di bagian bawah

---

### 2. 📝 Register Page

**Route:** `/register`

Proses registrasi 2-step dengan step indicator visual.

**Step 1 — User Info:**
- **Full Name** — Input nama lengkap pengguna
- **Email Address** — Input email dengan validasi
- **Password** — Input password (min. 8 karakter) dengan toggle visibility
- **Continue Button** — Lanjut ke step 2

**Step 2 — Organization Setup:**
- **Create Organization** — Pilihan untuk membuat organisasi baru (role: Owner)
  - Input nama organisasi
- **Use Invitation Code** — Pilihan untuk gabung organisasi existing (role: Staff)
  - Input kode undangan 6-digit dari Owner
- **Finish Registration Button** — Submit registrasi ke API

**Flow:**
1. Step 1: Isi data diri → klik Continue
2. Step 2: Pilih buat organisasi baru ATAU gunakan kode undangan
3. Finish Registration → API `/auth/register` dipanggil
4. Berhasil → redirect ke Login Page dengan notifikasi sukses

---

### 3. 🔓 Forgot Password Page

**Route:** `/forgot-password`

Halaman reset password menggunakan OTP via email.

**Flow:**
1. Masukkan email terdaftar → API `/auth/forgot-password` mengirim OTP
2. Masukkan kode OTP yang diterima via email
3. Masukkan password baru
4. Submit → API `/auth/reset-password` memvalidasi & mengubah password
5. Redirect ke Login Page

---

### 4. 🏠 Home Page

**Route:** `/home` | **Bottom Nav Index:** 0

Dashboard utama yang menampilkan greeting personal, quick actions, dan agenda hari ini.

**Komponen:**

| Komponen | Deskripsi |
|---|---|
| **AppBar** | Judul "AmbaNotes" + menu icon + notification bell |
| **Greeting** | "Good Morning, {Username}" — sapaan personal berdasarkan nama user |
| **Search Bar** | Pencarian cepat agenda, file, atau tanya AmbaAI |
| **Quick Actions Grid** | 4 tombol aksi cepat dalam grid 4 kolom |
| **Today's Agenda** | Daftar agenda/pengingat hari ini dengan animasi staggered |

**Quick Actions:**
1. **SCAN** — Membuka kamera scanner ML Kit untuk memindai dokumen fisik
2. **UPLOAD** — Membuka file picker untuk upload manual (JPG, PNG, PDF)
3. **AMBAAI** — Navigasi langsung ke halaman AI Chat
4. **ARCHIVE** — Navigasi ke halaman daftar dokumen arsip

**Agenda List:**
- Setiap item agenda menampilkan:
  - **Judul tugas** — Nama agenda/reminder
  - **Priority Badge** — HIGH (merah), REVIEW (kuning), NORMAL (hijau)
  - **Waktu** — Jam mulai - tanggal berakhir
  - **Lokasi** — Ikon pin + nama lokasi
  - **Delete Button** — Tombol hapus dengan konfirmasi dialog
- Prioritas otomatis ditentukan AI berdasarkan kata kunci (penting, segera, rapat = HIGH; evaluasi, kontrak = REVIEW)
- Animasi **slide-in** dari kanan dengan **fade** untuk setiap item

**Upload Document Flow:**
1. Tombol SCAN → ML Kit Document Scanner membuka kamera → capture → auto-crop
2. Tombol UPLOAD → File picker membuka galeri → pilih file
3. Dokumen sementara (processing) muncul di daftar dengan spinner
4. Upload berjalan di background secara **non-blocking**
5. Snackbar informatif muncul saat upload dimulai
6. Saat selesai → notifikasi push lokal + snackbar sukses dengan tombol "BUKA DETAIL"

---

### 5. 📁 Archive (Document List) Page

**Route:** `/archive` | **Bottom Nav Index:** 1

Halaman daftar semua dokumen yang telah diarsipkan dengan fitur pencarian dan filter.

**Komponen:**

| Komponen | Deskripsi |
|---|---|
| **Search Bar** | Pencarian teks + tombol Semantic Search (AI ✨) + tombol Sort |
| **Category Filters** | Chip horizontal scroll: All Documents, Letters, Invitations, Contracts, Reports |
| **Document List** | ListView dokumen dengan card modern |

**Setiap Document Card menampilkan:**
- **Ikon dokumen** — FileText icon (atau spinner jika masih processing)
- **Judul dokumen** — Nama file asli
- **Type Badge** — Label kategori (LETTER, INVITATION, CONTRACT, REPORT, PROCESSING)
- **AI Summary Preview** — 1-line ringkasan AI dengan ikon sparkle ✨
- **Status Badge** — Processed ✓ (hijau) / Processing ⏳ (biru)
- **Tanggal arsip** — Waktu upload
- **Menu Options** (⋮) — Edit, Replace, Delete

**Fitur Pencarian:**
- **Text Search** — Filter real-time berdasarkan keyword
- **AI Semantic Search** — Tombol sparkle ✨ mencari berdasarkan _makna_ via API `/ai/semantic-search`
- **Sort Toggle** — Toggle urutan dokumen

**Interaksi:**
- Tap dokumen → navigasi ke Archive Detail
- Tap dokumen processing → snackbar "Sedang Diproses"
- Category chip → filter dokumen berdasarkan tipe klasifikasi

---

### 6. 🔍 Archive Detail Page

**Route:** `/archive-detail`

Halaman detail lengkap sebuah dokumen dengan semua fitur AI terintegrasi.

**Komponen Detail:**

| Section | Deskripsi |
|---|---|
| **AppBar Actions** | Tombol Download + Share |
| **Header Card** | Tipe dokumen, judul, status badge, tanggal arsip, ukuran file |
| **AI Summary Card** | Gradient card dengan ringkasan AI + tombol "Ask AI for More" |
| **Cybersecurity Alert** | Peringatan keamanan jika belum terhubung Google Drive |
| **Disposition Card** | (Hanya Owner) Kirim/ubah disposisi surat ke divisi |
| **NER Metadata** | Entitas yang diekstrak: Nomor Surat, Perihal, Pengirim/Organisasi, Uploaded By |
| **Reminder Button** | (Muncul untuk undangan/rapat) Tombol tambah pengingat ke kalender |
| **Document Preview** | Pratinjau gambar/PDF (lokal atau Google Drive) |
| **Buat Surat Tugas** | (Hanya untuk tipe undangan) Tombol navigasi ke form surat tugas |

**AI Summary Card:**
- Gradient background biru lembut → putih
- Ikon sparkle ✨ dengan label "AI Summary"
- Ringkasan konten dokumen yang dihasilkan AI secara otomatis
- Tombol **"Ask AI for More"** → navigasi ke Chat AI dengan konteks dokumen ini

**Cybersecurity Alert Card:**
- **Jika Google Drive belum terhubung** → peringatan oranye + tombol "Integrate Google Drive Cloud"
- **Jika Google Drive terhubung** → badge hijau "Secured in Google Drive"

**Disposition Card (Owner Only):**
- Informasi disposisi surat saat ini
- **Jika belum didisposisi** → status "Draf (Hanya Owner yang dapat melihat)"
- Tombol **"Kirim / Disposisi Surat"** → dialog pilihan divisi dengan AI suggestion
- AI menyarankan divisi yang paling relevan berdasarkan konten surat via `/ai/suggest-disposition`

**Document Preview:**
- Jika terhubung Google Drive & file tersedia → tampil gambar langsung atau WebView PDF
- Jika file lokal → decode base64 & tampilkan gambar
- **Tap gambar** → fullscreen interactive viewer (pinch-to-zoom, pan)

**NER Extracted Entities:**
Metadata yang diekstrak otomatis dari teks dokumen menggunakan Named Entity Recognition:
- **Nomor Surat** — Nomor referensi surat
- **Perihal** — Subject/topik surat
- **Pengirim/Organisasi** — Organisasi penerbit surat
- **Uploaded By** — User yang mengunggah

---

### 7. 📋 Assignment Letter Form Page (Buat Surat Tugas)

**Route:** `/assignment-letter-form`

Form untuk membuat surat tugas otomatis berdasarkan undangan masuk sebagai referensi.

**Komponen:**
- **Reference Card** — Menampilkan judul dokumen undangan referensi
- **Missing Assets Warning** — Banner peringatan jika kop/TTD belum tersedia
- **Kop Surat Dropdown** — (Owner) Pilih kop surat aktif per divisi
- **TTD Dropdown** — (Owner) Pilih tanda tangan digital aktif
- **Read-Only Asset Tiles** — (Staff) Tampilan kop/TTD yang sudah diset oleh Owner
- **Nomor Surat** — Input manual nomor surat tugas
- **Tanggal Penugasan** — Date picker
- **Waktu Penugasan** — Time picker
- **Tempat/Lokasi** — Input lokasi penugasan
- **Konfirmasi Surat Jalan** — Submit button (disabled jika aset belum lengkap)

**Flow:**
1. Buka dari Archive Detail (hanya untuk tipe undangan)
2. Data referensi (nomor surat, perihal, organisasi) otomatis terisi dari undangan
3. Owner memilih kop surat & TTD dari dropdown per divisi
4. Isi nomor surat tugas, tanggal, waktu, lokasi
5. Klik **"Konfirmasi Surat Jalan"**
6. API `/generator/surat-tugas` memproses dan menghasilkan PDF surat tugas

---

### 8. 💬 AI Chat Page (AmbaAI)

**Route:** `/chat` | **Bottom Nav Index:** 3

Halaman chatbot AI dengan dukungan konteks dokumen, histori percakapan, dan text-to-speech.

**Komponen:**

| Komponen | Deskripsi |
|---|---|
| **AppBar** | Judul "Ask AmbaAI" + menu drawer untuk histori |
| **Context Banner** | (Opsional) Label dokumen yang sedang menjadi konteks chat |
| **Chat Messages** | ListView bubble chat user vs AI |
| **Typing Indicator** | Animasi titik-titik saat AI memproses respons |
| **Suggestion Chips** | Quick-action chips: "Cari undangan masuk", "Kontrak habis?", "Ringkas dokumen" |
| **Chat Input** | Glassmorphism input bar + paperclip + send button |
| **History Drawer** | Side drawer berisi semua sesi chat sebelumnya |

**Chat Modes:**
1. **Contextual Chat** — Chat tentang dokumen spesifik (dipicu dari "Ask AI for More" di detail)
   - API: `/ai/chat` dengan `doc_id` dan `context` teks dokumen
2. **Global Chat** — Chat umum tentang seluruh dokumen organisasi
   - API: `/ai/chat-global` dengan semantic search di semua dokumen

**Message Bubble Features:**
- **User messages** — Bubble hijau tua di kanan
- **AI messages** — Bubble abu-abu di kiri dengan ikon sparkle ✨
- **Markdown rendering** — Bold, italic, heading, list, code block
- **Text-to-Speech (TTS)** — Tombol speaker 🔊 untuk mendengarkan respons AI
- **Copy to Clipboard** — Tombol salin pesan
- **Document References** — Chip referensi dokumen yang bisa di-tap untuk navigasi langsung

**History Drawer:**
- Daftar semua sesi percakapan sebelumnya
- Ikon berbeda untuk chat kontekstual (✨) vs umum (💬)
- Info dokumen sumber untuk chat kontekstual
- Tombol "Percakapan Baru" di bagian atas
- Tombol hapus (🗑️) per sesi dengan konfirmasi dialog

**Suggestion Chips:**
- "Cari undangan masuk" — Semantic search undangan
- "Apakah ada kontrak yang habis?" — Query AI tentang kontrak
- "Tolong ringkas dokumen terbaru" — Minta ringkasan dokumen

---

### 9. 📊 Insight & Analytics Page

**Route:** `/insight` | **Bottom Nav Index:** 2

Dashboard analitik komprehensif dengan visualisasi data dan prediksi AI.

**Komponen Cards:**

#### a. Statistik Dokumen (Hero Card)
- **Gradient card** hijau tua premium
- **Donut chart** persentase surat masuk vs total
- Statistik: Surat Masuk, Surat Keluar, Reminders
- Ikon & styling infografik profesional

#### b. Instagram Event Insights
- Statistik engagement: KIRIMAN, AVG LIKES, ENGAGEMENT
- **LIVE badge** indikator data real-time
- **Tren Kepadatan Event** dengan horizontal progress bar per event
- Persentase perubahan per event

#### c. Top Akun Paling Aktif (Bar Chart)
- Grafik batang vertikal scrollable horizontal
- Y-axis label otomatis berdasarkan nilai maksimum
- Gradient bar hijau tua → teal
- Label akun rotated di X-axis
- Shadow & styling premium

#### d. Hari Publikasi Paling Aktif (Bar Chart)
- Grafik batang vertikal per hari (Senin-Minggu)
- Sorted descending berdasarkan jumlah
- Nama hari dalam Bahasa Indonesia

#### e. Word Cloud
- Visualisasi kata kunci terpopuler dari dokumen
- Ukuran font bervariasi berdasarkan frekuensi

#### f. Beban Kerja 3 Bulan (Predictive)
- **Speedometer circular** dial (0-10)
- Indeks beban kerja: Rendah (hijau), Sedang (kuning), Tinggi (merah)
- **Proyeksi tren** (meningkat/menurun/stabil) berdasarkan regresi linier
- Ikon tren (trending_up/down/flat)
- Segmented bar visual status

#### g. AmbaAI Insight (AI Summary)
- Ringkasan mingguan yang di-generate AI
- Analisis tren & rekomendasi berdasarkan data administrasi

---

### 10. ⚙️ Profile & Settings Page

**Route:** `/profile` | **Bottom Nav Index:** 4

Halaman profil pengguna dan pengaturan aplikasi.

**Komponen:**

#### Header Card
- **Avatar** — Foto profil dari URL
- **Username** — Nama user (uppercase)
- **Email** — Alamat email
- **Organization Badge** — Nama organisasi + role badge (OWNER/STAFF)
- **Invite Code** (Owner only) — Kode undangan organisasi yang bisa disalin

#### Google Drive Integration Card
- **Status badge** — Connected (hijau) / Disconnected (kuning)
- **Deskripsi** integrasi cloud storage
- Jika belum terhubung → **"Otorisasi Google Drive"** button
- Jika sudah terhubung:
  - **"Migrasikan Berkas Lokal ke Drive"** — Migrasi batch semua dokumen
  - **"Putuskan Koneksi Google Drive"** — Disconnect dengan konfirmasi

#### General Settings Card
- **Pengaturan Notifikasi** → NotificationSettingsView
- **Keamanan & Sandi** → SecurityView
- **Manajemen Organisasi** (Owner only) → ManageEnterpriseView
- **Pusat Bantuan AmbaNotes**
- **Logout Button** (di AppBar) — merah, logout dengan clear state

---

### 11. 🏢 Manage Enterprise Page (Manajemen Organisasi)

**Route:** In-app navigation (Owner only)

Halaman manajemen organisasi komprehensif hanya untuk role Owner.

**Komponen:**

#### a. Undang Anggota Baru
- Input email staff → kirim undangan via API `/auth/invite`
- Tombol "Kirim Undangan" berwarna ungu

#### b. Daftar Anggota & Staff
- Preview 4 anggota pertama + tombol "Lihat Semua"
- Setiap anggota menampilkan: Avatar inisial, username, email, divisi, role badge
- **Pindahkan Divisi** — Icon git-pull-request → dialog dropdown divisi → API `/auth/change-delegation`
- Dialog fullscreen daftar semua anggota

#### c. Struktur Delegasi / Divisi
- Counter divisi aktif
- **Form tambah divisi** — Input nama + tombol Tambah
- **Daftar divisi** (preview 3) + "Lihat Semua"
- Setiap divisi: nama, jumlah anggota, tombol Edit ✏️ & Delete 🗑️
- **Edit** → dialog rename divisi
- **Delete** → dialog konfirmasi hapus
- Tap divisi → dialog daftar anggota divisi tersebut

#### d. Aset Kop & TTD per Divisi
- Upload kop surat & tanda tangan digital per divisi
- Rule: Hanya 1 kop dan 1 TTD aktif per divisi
- Toggle aktifkan/nonaktifkan aset
- Preview gambar aset yang diupload
- Upload via image picker → konversi base64 → API `/auth/assets`

---

### 12. 🔒 Security & Password Page

**Route:** In-app navigation

Halaman keamanan dan perubahan kata sandi.

**Fitur:**
- **Change Password** — Input password lama + password baru → API `/auth/change-password`
- **Delete Account** — Hapus akun permanen dengan konfirmasi → API `/auth/delete-account`

---

### 13. 🔔 Notification Settings Page

**Route:** In-app navigation

Pengaturan jenis notifikasi yang diterima pengguna.

**Toggle Options:**
- **Enable/Disable All Notifications** — Master toggle
- **Processing Complete** — Notifikasi saat analisis AI dokumen selesai
- **Reminder Alerts** — Notifikasi pengingat agenda
- **Security Alerts** — Notifikasi peringatan keamanan

---

## 🔄 Flow Penggunaan Aplikasi

### Flow Lengkap End-to-End

```
┌─────────────────────────────────────────────────────────────┐
│                    ONBOARDING FLOW                          │
│                                                             │
│  ① Login ──→ Sudah punya akun? ──→ Home Dashboard          │
│     │                                                       │
│     └─→ Register ──→ Step 1: Data Diri                     │
│                     ──→ Step 2: Buat Org / Kode Undangan    │
│                     ──→ Login                               │
│                                                             │
│  ② Forgot Password ──→ Email OTP ──→ Reset ──→ Login       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   DOCUMENT LIFECYCLE                         │
│                                                             │
│  ① Upload/Scan Dokumen                                     │
│     Home (SCAN/UPLOAD) ──→ Capture/Pick File               │
│     ──→ Placeholder "Processing" muncul di list            │
│     ──→ Background: Upload ke server                       │
│     ──→ Server: OCR + NER + Klasifikasi + Summarize        │
│     ──→ Push Notification "Analisis AI Selesai"            │
│     ──→ Dokumen lengkap muncul di Archive                  │
│                                                             │
│  ② Lihat Detail Dokumen                                    │
│     Archive List ──→ Tap dokumen ──→ Archive Detail         │
│     ──→ AI Summary, NER Entities, Preview                  │
│     ──→ Ask AI for More (Chat kontekstual)                 │
│     ──→ Disposisi ke divisi (Owner)                        │
│     ──→ Buat Surat Tugas (jika undangan)                   │
│     ──→ Tambah Reminder (jika rapat/undangan)              │
│                                                             │
│  ③ Disposisi Surat (Owner Flow)                            │
│     Archive Detail ──→ "Kirim / Disposisi Surat"           │
│     ──→ AI menyarankan divisi yang sesuai                  │
│     ──→ Owner memilih/mengubah divisi                      │
│     ──→ Staff divisi tersebut dapat mengakses dokumen      │
│                                                             │
│  ④ Buat Surat Tugas (dari Undangan)                        │
│     Archive Detail ──→ "Buat Surat Tugas"                  │
│     ──→ Form terisi otomatis dari data undangan            │
│     ──→ Pilih kop surat & TTD (Owner) / Auto (Staff)      │
│     ──→ Submit ──→ PDF surat tugas di-generate server      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    AI CHAT FLOW                              │
│                                                             │
│  ① Chat Kontekstual (dari Dokumen)                         │
│     Archive Detail ──→ "Ask AI for More"                   │
│     ──→ Chat dibuka dengan konteks dokumen terpilih        │
│     ──→ AI menjawab berdasarkan konten dokumen spesifik    │
│                                                             │
│  ② Chat Global (Chatbot Umum)                              │
│     Bottom Nav ──→ Chat tab ──→ Percakapan Baru            │
│     ──→ AI mencari semua dokumen via semantic search       │
│     ──→ Respons disertai referensi dokumen yang relevan    │
│                                                             │
│  ③ Fitur Chat Lanjutan                                     │
│     ──→ TTS: Baca respons AI dengan suara                  │
│     ──→ Copy: Salin pesan ke clipboard                     │
│     ──→ History: Buka drawer ──→ lihat/pilih sesi lama     │
│     ──→ Delete: Hapus sesi yang tidak diperlukan           │
│     ──→ References: Tap chip dokumen ──→ buka detail       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                 ORGANIZATION MANAGEMENT                      │
│                                                             │
│  ① Setup Awal (Owner)                                      │
│     Register ──→ Create Organization                        │
│     ──→ Profile ──→ Manage Enterprise                      │
│     ──→ Buat Divisi (HRD, IT, Keuangan, dll)              │
│     ──→ Upload Kop Surat & TTD per divisi                  │
│     ──→ Bagikan Kode Undangan ke staff                     │
│                                                             │
│  ② Gabung Organisasi (Staff)                               │
│     Register ──→ Use Invitation Code                        │
│     ──→ Masukkan kode 6-digit dari Owner                   │
│     ──→ Login ──→ Akses dokumen divisi sendiri             │
│                                                             │
│  ③ Kelola Anggota (Owner)                                  │
│     Manage Enterprise ──→ Undang Anggota (via email)       │
│     ──→ Lihat Daftar Staff                                 │
│     ──→ Pindahkan Staff antar Divisi                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 🧠 Fitur-Fitur Cerdas AI

### 1. Pipeline Ingesti Dokumen Otomatis
Saat dokumen di-upload/scan, pipeline berikut berjalan otomatis di server:

```
Input (Image/PDF)
    ↓
[OCR Engine] → Ekstraksi teks dari gambar/PDF
    ↓
[NER Model] → Ekstraksi entitas: Nomor Surat, Perihal, Organisasi
    ↓
[Document Classifier] → Klasifikasi: Letter/Invitation/Contract/Report
    ↓
[Summarizer AI] → Ringkasan otomatis isi dokumen
    ↓
[Embedding Generator] → Vector embedding untuk semantic search
    ↓
Output: Dokumen terindeks, ringkasan, metadata, searchable
```

### 2. Semantic Search (Pencarian Cerdas)
- Tidak hanya mencocokkan kata kunci, tetapi memahami **makna** query
- Contoh: Query "surat tentang rapat tahunan" akan menemukan dokumen berjudul "Undangan Pertemuan Akhir Tahun 2024"
- Menggunakan vector embedding dan cosine similarity

### 3. AI Disposition Suggestion
- Menganalisis konten surat dan daftar divisi yang tersedia
- Merekomendasikan divisi penerima yang paling relevan
- Contoh: Surat tentang "anggaran keuangan" → AI menyarankan divisi "Keuangan"

### 4. AI Task Extraction
- Mengekstrak tugas/action item dari isi surat
- Otomatis mendeteksi tanggal, waktu, dan lokasi
- Bisa langsung dikonversi menjadi reminder/agenda

### 5. AI Generate Reply
- Membuat draft balasan surat berdasarkan konten surat masuk
- Menyesuaikan bahasa formal Indonesia

### 6. Predictive Workload Analysis
- Menggunakan regresi linier pada data historis dokumen
- Memprediksi indeks beban kerja 3 bulan ke depan
- Tren: Meningkat / Menurun / Stabil

---

## 👥 Sistem Role & Akses

| Fitur | Owner | Staff |
|---|:---:|:---:|
| Lihat semua dokumen organisasi | ✅ | ❌ (hanya divisi sendiri) |
| Upload/scan dokumen | ✅ | ✅ |
| Disposisi surat ke divisi | ✅ | ❌ |
| Kelola divisi (CRUD) | ✅ | ❌ |
| Kelola anggota & pindah divisi | ✅ | ❌ |
| Upload kop surat & TTD | ✅ | ❌ |
| Pilih kop/TTD saat buat surat | ✅ (dropdown) | ❌ (read-only) |
| Undang anggota baru | ✅ | ❌ |
| Lihat kode undangan | ✅ | ❌ |
| AI Chat | ✅ | ✅ |
| Insight & Analytics | ✅ | ✅ |
| Google Drive Integration | ✅ | ✅ |
| Buat surat tugas | ✅ | ✅ |
| Ubah password | ✅ | ✅ |
| Hapus akun | ✅ | ✅ |

---

## ☁️ Integrasi Google Drive

Arcliva AI mendukung integrasi penuh dengan Google Drive untuk keamanan dan aksesibilitas dokumen.

### Alur Integrasi:

```
Profile → Google Drive Card → "Otorisasi Google Drive"
    ↓
Server menghasilkan OAuth2 URL → WebView terbuka
    ↓
User login Google & otorisasi akses
    ↓
Token OAuth disimpan di server → Status: Connected ✅
    ↓
Semua dokumen baru otomatis disinkronkan ke Drive
    ↓
[Opsional] "Migrasikan Berkas Lokal ke Drive" → batch migrate
```

### Fitur Google Drive:
- **Auto-sync** — Dokumen baru otomatis diupload ke Drive
- **Batch Migration** — Migrasi semua dokumen lokal existing ke Drive
- **Drive Preview** — Preview dokumen langsung dari Google Drive via WebView
- **Security Alert** — AI mengingatkan jika dokumen belum di-backup ke cloud
- **Disconnect** — Putuskan koneksi dengan konfirmasi dialog

---

## 🚀 Cara Menjalankan Proyek

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio / VS Code
- Android device atau emulator (API 21+)
- Backend server running (lihat [Konfigurasi Backend](#-konfigurasi-backend))

### Langkah-langkah

```bash
# 1. Clone repository
git clone <repository-url>
cd ambanotes

# 2. Install dependencies
flutter pub get

# 3. Pastikan device/emulator terhubung
flutter devices

# 4. Jalankan aplikasi
flutter run

# 5. (Opsional) Build APK release
flutter build apk --release
```

### Catatan Penting
- Pastikan backend server berjalan dan dapat diakses dari device
- Untuk physical device, pastikan device dan server berada di jaringan yang sama

---

## ⚙️ Konfigurasi Backend

Base URL backend dikonfigurasi di `lib/app/data/services/api_service.dart`:

```dart
final baseUrl = 'https://notes.bimazznxt.my.id'.obs;
```

### API Endpoints yang Digunakan

| Service | Endpoint | Method | Deskripsi |
|---|---|---|---|
| **Auth** | `/auth/login` | POST | Login user |
| | `/auth/register` | POST | Registrasi user baru |
| | `/auth/profile` | GET | Ambil profil user |
| | `/auth/forgot-password` | POST | Request OTP reset password |
| | `/auth/reset-password` | POST | Reset password dengan OTP |
| | `/auth/change-password` | POST | Ubah password |
| | `/auth/delete-account` | DELETE | Hapus akun |
| | `/auth/members` | GET | Daftar anggota organisasi |
| | `/auth/invite` | POST | Undang anggota baru |
| | `/auth/delegations` | GET/POST | CRUD divisi/delegasi |
| | `/auth/change-delegation` | POST | Pindahkan anggota ke divisi lain |
| | `/auth/assets` | GET/POST/PUT/DELETE | CRUD aset kop & TTD |
| | `/auth/google/connect` | GET | URL otorisasi Google OAuth |
| | `/auth/google/disconnect` | POST | Putuskan koneksi Google |
| **Document** | `/document/upload` | POST | Upload & proses dokumen |
| | `/document/list` | GET | Daftar semua dokumen |
| | `/document/{id}` | GET | Detail dokumen |
| | `/document/{id}` | DELETE | Hapus dokumen |
| | `/document/disposition/{id}` | POST | Disposisi ke divisi |
| | `/document/replace/{id}` | POST | Ganti file dokumen |
| | `/document/migrate-to-drive` | POST | Migrasi ke Google Drive |
| **AI** | `/ai/summarize` | POST | Ringkasan AI |
| | `/ai/chat` | POST | Chat kontekstual per dokumen |
| | `/ai/chat-global` | POST | Chat global + semantic search |
| | `/ai/chats` | GET | Daftar histori chat |
| | `/ai/chat/{docId}` | GET | Detail sesi chat |
| | `/ai/generate-reply` | POST | Generate balasan surat |
| | `/ai/extract-tasks` | POST | Ekstrak tugas dari teks |
| | `/ai/suggest-disposition` | POST | Saran disposisi AI |
| | `/ai/semantic-search` | POST | Pencarian semantik |
| **Reminder** | `/reminder/` | GET/POST | CRUD pengingat/agenda |
| | `/reminder/{id}` | DELETE | Hapus pengingat |
| **Insight** | `/insight/weekly-summary` | GET | Ringkasan mingguan |
| | `/insight/predictive-trends` | GET | Prediksi tren beban kerja |
| | `/insight/api/insights` | GET | Event insights analytics |
| **Generator** | `/generator/surat-tugas` | POST | Generate PDF surat tugas |

---

## 🎨 Design System

Arcliva AI menggunakan **Material Design 3** dengan palet warna kustom:

| Token | Hex | Penggunaan |
|---|---|---|
| `primary` | `#004D40` | Warna utama (hijau tua) |
| `primaryContainer` | `#AFEFDD` | Background aksen |
| `secondary` | `#526069` | Warna sekunder |
| `aiAccent` | `#42A5F5` | Fitur AI (biru) |
| `aiSoft` | `#E3F2FD` | Background AI lembut |
| `surface` | `#F9F9F9` | Background utama |
| `onSurface` | `#1A1C1C` | Teks di atas surface |

**Typography:** Google Fonts **Inter** (body) + **Public Sans** (heading)

---

## 📄 Lisensi

Proyek ini dikembangkan sebagai bagian dari tugas **Capstone Project Semester 6**.

---

<p align="center">
  <strong>Arcliva AI</strong> — Digitalisasi Cerdas untuk Sekretariat Modern 🏛️✨
</p>
