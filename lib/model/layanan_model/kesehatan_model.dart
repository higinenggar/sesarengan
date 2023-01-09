class KesehatanModel {
  final String jenis;
  final String title;
  final String description;
  final String images;
  final String url;

  const KesehatanModel(
      {required this.jenis,
      required this.title,
      required this.description,
      required this.images,
      required this.url});
}

const detailKes = [
  KesehatanModel(
    jenis: "Kesehatan",
    title: "Antrian Rawat Jalan RSUD",
    description: "Aplikasi antrian online RSUD Setjonegoro Wonosobo",
    images: "assets/images/ico1.png",
    url:
        "https://play.google.com/store/apps/details?id=com.enggar.mysetjonegoro",
  ),
  KesehatanModel(
    jenis: "Kesehatan",
    title: "SIRANAP",
    description: "Informasi Ketersediaan Kamar RSUD KRT Setjonegoro Wonosobo.",
    images: "assets/images/ico4.png",
    url: "https://yankes.kemkes.go.id/app/siranap/",
  ),
  KesehatanModel(
    jenis: "Kesehatan",
    title: "Pendaftaran Vaksinasi",
    description: "Ayo vaksin! Wonosobo Sehat, Indonesia Hebat",
    images: "assets/images/ico11.png",
    url:
        "https://play.google.com/store/apps/details?id=com.enggar.mysetjonegoro",
  ),
];
