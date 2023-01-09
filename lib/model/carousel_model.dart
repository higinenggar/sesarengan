class CarouselModel {
  String? image;

  CarouselModel(this.image);
}

List<CarouselModel> carousels =
    carouselsData.map((item) => CarouselModel(item['image'])).toList();

var carouselsData = [
  {"image": "assets/images/slider1.png"},
  {"image": "assets/images/slider2.png"},
  {"image": "assets/images/slider3.png"},
  {"image": "assets/images/slider4.png"},
];
