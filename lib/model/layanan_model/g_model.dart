class GovernModel {
  final String jenis;
  final String title;
  final String image;
  final String description;
  final String url;

  const GovernModel(
      {required this.jenis,
      required this.title,
      required this.image,
      required this.description,
      required this.url});
}

// List<GovernModel> menu = detailMenu
//     .map(
//       (item) => GovernModel(
//           item['jenis'] as String,
//           item['title'] as String,
//           item['image'] as String,
//           item['description'] as String,
//           item['url'] as String),
//     )
//     .toList();

const detailMenu = [
  GovernModel(
    jenis: "Smart Government",
    title: "Aplikasi Perizinan(APRIZ)",
    image: "assets/icons/lock.png",
    description:
        "APRIZ -  Badan Penanaman Modal dan Pelayanan Terpadu Satu Pintu Pemerintah Kabupaten Wonosobo.",
    url: "https://apriz.wonosobokab.go.id/login",
  ),
  GovernModel(
    jenis: "Smart Government",
    title: "e - Kinerja",
    image: "assets/icons/work.png",
    description: "Aplikasi e -Kinerja Kabupaten Wonosobo.",
    url: "https://kinerja.wonosobokab.go.id",
  ),
  GovernModel(
    jenis: "Smart Government",
    title: "Jaringan Dokumentasi & Informasi Hukum (JDIH)",
    image: "assets/icons/arsip.png",
    description:
        "Notably powerful, Wanda Maximoff has fought both against and with the Avengers, attempting to hone her abilities and do what she believes is right to help the world.",
    url: "https://jdih.wonosobokab.go.id/",
  ),
  GovernModel(
    jenis: "Smart Government",
    title: "Lokal Text / Aplikasi Wajib Pajak (LOTAX)",
    image: "assets/icons/pajak.png",
    description: "Aplikasi Pajak untuk Wajib Pajak.",
    url: "https://lotax.wonosobokab.go.id/",
  ),
  GovernModel(
    jenis: "Smart Government",
    title: "Open Data Desa",
    image: "assets/icons/desa.png",
    description:
        "Open Data Desa adalah inisiatif bersama antara pemerintah Kabupaten Wonosobo dan Infest Yogyakarta yang bertujuan untuk mendorong partisipasi masyarakat dalam pembangunan desa. Kami percaya partisipasi dapat meningkatkan kualitas pembangunan desa dan akses masyarakat marjinal pada pembangunan.",
    url: "https://datadesa.wonosobokab.go.id/",
  ),
  GovernModel(
    jenis: "Smart Government",
    title: "Pelayanan Administrasi Terpadu Kecamatan (PATEN)",
    image: "assets/icons/admin.png",
    description:
        "Pelayanan Administrasi Terpadu Kecamatan Pemerintah Kabupaten Wonosobo.",
    url: "https://paten.wonosobokab.go.id/login",
  ),
  GovernModel(
    jenis: "Smart Government",
    title: "Sistem Informasi Manajemen Kepegawaian (SIMPEG)",
    image: "assets/icons/simpeg.png",
    description: "e - SIMPEG Pemerintah Kabupaten Wonosobo.",
    url: "https://simpeg.wonosobokab.go.id/v19/",
  ),
  GovernModel(
    jenis: "Smart Government",
    title:
        "Sistem Pengendalian Belanja Langsung Pemerintah Daerah (SPEDA BALAP)",
    image: "assets/icons/blanja.png",
    description: "e - SPEDABALAP Terintegrasi.",
    url: "https://spedabalap.wonosobokab.go.id/login",
  ),
  GovernModel(
    jenis: "Smart Government",
    title: "Sistem Informasi Pendapatan Wonosobo (SITAWON)",
    image: "assets/icons/pendapatan.png",
    description:
        "Aplikasi yang dipergunakan sistem administrasi Pajak Daerah. Aplikasi ini hadir dengan tujuan guna mempermudah administrasi pajak daerah Kabupaten Wonosobo.",
    url: "https://sitawon.wonosobokab.go.id/",
  ),
  GovernModel(
    jenis: "Smart Government",
    title: "Tata Naskah Dinas Elektronik (TNDE)",
    image: "assets/icons/tnde.png",
    description: "Sistem Informasi Kearsipan Dinamis Terintegrasi.",
    url: "https://tnde.wonosobokab.go.id/",
  ),
];
