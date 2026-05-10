# 📔 AmbaNotes - AI-Powered Secretariat Dashboard

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![GetX](https://img.shields.io/badge/-GetX-blue?style=for-the-badge)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

**AmbaNotes** adalah aplikasi manajemen dokumen dan dashboard sekretariat cerdas yang dirancang untuk meningkatkan produktivitas melalui integrasi AI. Dengan antarmuka yang modern, clean, dan responsif, AmbaNotes memudahkan Anda mengelola agenda, mengarsipkan dokumen penting, dan berinteraksi dengan asisten AI untuk analisis dokumen yang lebih cepat.

---

## ✨ Fitur Utama

-   **🤖 AmbaAI Assistant**: Tanya jawab cerdas mengenai isi dokumen Anda. Summarize laporan panjang atau cari poin penting hanya dalam hitungan detik.
-   **📅 Smart Agenda**: Kelola jadwal harian dengan sistem prioritas (High, Review, Normal) yang terintegrasi dengan notifikasi.
-   **📂 Advanced Archiving**: Simpan dan kelola arsip dokumen digital dengan rapi. Mendukung berbagai format file dan pencarian cepat.
-   **📝 Assignment Forms**: Pembuatan dan pengiriman formulir penugasan yang terstruktur untuk kebutuhan sekretariat.
-   **🔍 Global Search**: Cari agenda, file, atau instruksi AI melalui satu kolom pencarian yang intuitif.
-   **🎨 Premium UI/UX**: Menggunakan desain modern dengan animasi halus (*Staggered Animations*), Lucide Icons, dan tipografi dari Google Fonts.

---

## 🛠️ Tech Stack

Aplikasi ini dibangun menggunakan teknologi terkini:

-   **Framework:** [Flutter](https://flutter.dev/) (Cross-platform)
-   **State Management:** [GetX](https://pub.dev/packages/get)
-   **Icons:** [Lucide Icons](https://lucide.dev/)
-   **Animations:** [Flutter Staggered Animations](https://pub.dev/packages/flutter_staggered_animations)
-   **Typography:** [Google Fonts (Outfit/Inter)](https://fonts.google.com/)
-   **UI Patterns:** Clean Architecture dengan Modular structure.

---

## 📸 Preview Aplikasi

| Home Dashboard | AmbaAI Chat | Archive List |
| :---: | :---: | :---: |
| ![Home](https://via.placeholder.com/200x400?text=Home+View) | ![Chat](https://via.placeholder.com/200x400?text=AmbaAI+Chat) | ![Archive](https://via.placeholder.com/200x400?text=Archive+List) |

---

## 🚀 Cara Menjalankan Project

1.  **Clone repositori ini**
    ```bash
    git clone https://github.com/username/ambanotes.git
    ```
2.  **Masuk ke direktori project**
    ```bash
    cd ambanotes
    ```
3.  **Install dependencies**
    ```bash
    flutter pub get
    ```
4.  **Jalankan aplikasi**
    ```bash
    flutter run
    ```

---

## 📁 Struktur Folder

```text
lib/
├── app/
│   ├── data/          # Models & Providers
│   ├── modules/       # UI (View, Controller, Binding) per modul
│   ├── routes/        # Navigasi & App Pages
│   └── theme/         # Design System (Colors, Typography)
└── main.dart          # Entry Point
```

---

## 🤝 Kontribusi

Kontribusi selalu terbuka! Jika Anda memiliki saran atau menemukan bug, silakan buat *issue* atau kirimkan *pull request*.

1. Fork Project ini
2. Buat Branch Fitur (`git checkout -b fitur/FiturKeren`)
3. Commit Perubahan (`git commit -m 'Menambahkan Fitur Keren'`)
4. Push ke Branch (`git push origin fitur/FiturKeren`)
5. Open Pull Request

---

<p align="center">
  Dibuat dengan ❤️ untuk efisiensi sekretariat.
</p>
