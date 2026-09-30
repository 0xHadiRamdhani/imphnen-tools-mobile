const appStrings = <String, Map<String, String>>{
  'home': {'id': 'Beranda', 'en': 'Home'},
  'tools': {'id': 'Alat', 'en': 'Tools'},
  'favorites': {'id': 'Favorit', 'en': 'Favorites'},
  'settings': {'id': 'Setelan', 'en': 'Settings'},
  'good_morning': {'id': 'Selamat pagi', 'en': 'Good morning'},
  'good_afternoon': {'id': 'Selamat siang', 'en': 'Good afternoon'},
  'good_evening': {'id': 'Selamat malam', 'en': 'Good evening'},
  'what_today': {
    'id': 'Apa yang ingin kamu kerjakan?',
    'en': 'What would you like to work on?',
  },
  'search': {
    'id': 'Cari JSON Formatter, PDF, QR...',
    'en': 'Search JSON Formatter, PDF, QR...',
  },
  'popular': {'id': 'Sering digunakan', 'en': 'Popular tools'},
  'recent': {'id': 'Terakhir dibuka', 'en': 'Recently used'},
  'categories': {'id': 'Kategori', 'en': 'Categories'},
  'see_all': {'id': 'Lihat semua', 'en': 'See all'},
  'all_tools': {
    'id': 'Kumpulan alat untuk semua kebutuhanmu.',
    'en': 'Useful tools for whatever you need to do.',
  },
  'free': {'id': 'Gratis digunakan', 'en': 'Free to use'},
  'private': {'id': 'Privasi diutamakan', 'en': 'Privacy first'},
  'instant': {'id': 'Cepat dan praktis', 'en': 'Fast and simple'},
  'open_tool': {'id': 'Buka alat', 'en': 'Open tool'},
  'empty_favorites': {
    'id': 'Belum ada alat favorit.',
    'en': 'No favorite tools yet.',
  },
  'empty_recent': {
    'id': 'Alat yang dibuka akan muncul di sini.',
    'en': 'Tools you open will show up here.',
  },
  'appearance': {'id': 'Tampilan', 'en': 'Appearance'},
  'dark_mode': {'id': 'Mode gelap', 'en': 'Dark mode'},
  'language': {'id': 'Bahasa', 'en': 'Language'},
  'privacy': {'id': 'Privasi', 'en': 'Privacy'},
  'clear_favorites': {'id': 'Hapus semua favorit', 'en': 'Clear favorites'},
  'clear_recent': {'id': 'Hapus riwayat terbaru', 'en': 'Clear recent history'},
  'about': {'id': 'Tentang IMPHNEN', 'en': 'About IMPHNEN'},
  'no_tools': {'id': 'Alat tidak ditemukan.', 'en': 'No tools found.'},
  'input': {'id': 'Masukkan teks', 'en': 'Input text'},
  'result': {'id': 'Hasil', 'en': 'Result'},
  'run': {'id': 'Proses', 'en': 'Run tool'},
  'copy': {'id': 'Salin', 'en': 'Copy'},
  'copied': {'id': 'Tersalin', 'en': 'Copied'},
  'clear': {'id': 'Bersihkan', 'en': 'Clear'},
  'processing': {
    'id': 'Butuh layanan pemrosesan',
    'en': 'Processing service required',
  },
  'processing_detail': {
    'id': 'Alat ini memerlukan pemroses dokumen atau layanan AI. Hubungkan layanan di server untuk mengaktifkannya. File tidak dikirim oleh aplikasi ini.',
    'en': 'This tool needs a document processor or AI service. Connect a server provider to enable it. This app does not upload your files.',
  },
  'jwt_warning': {
    'id': 'Decode bukan verifikasi. Signature JWT tidak diperiksa.',
    'en': 'Decoding is not verification. The JWT signature is not checked.',
  },
  'length': {'id': 'Panjang kata sandi', 'en': 'Password length'},
};

String tr(bool indonesian, String key) =>
    appStrings[key]?[indonesian ? 'id' : 'en'] ?? key;
