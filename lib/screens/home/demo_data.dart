import 'dart:convert';

import '../../models/product.dart';
import '../../providers/product_provider.dart';

/// ── DỮ LIỆU GIẢ LẬP (chỉ dùng lúc làm giao diện) ──
/// true  = Trang chủ, Chi tiết hiện 12 sản phẩm mẫu bên dưới
///         (lấy từ file Excel của nhóm) khi API chưa có dữ liệu thật.
/// false = luôn dùng dữ liệu từ API.
/// TODO: đổi thành false khi MockAPI đã có đủ 26 sản phẩm.
const bool kUseDemoData = true;

/// Danh sách sản phẩm màn của Uyên dùng.
List<Product> productsOf(ProductProvider provider) {
  if (!kUseDemoData) return provider.products;
  // API còn dữ liệu mẫu tự sinh ("name 1", "category 1") thì dùng bản giả lập.
  final real = provider.products
      .where((p) => !p.name.startsWith('name '))
      .toList();
  return real.length >= 5 ? real : demoProducts;
}

Product? productById(ProductProvider provider, String id) {
  return productsOf(provider).where((p) => p.id == id).firstOrNull;
}

final List<Product> demoProducts = (jsonDecode(_demoJson) as List)
    .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
    .toList();

const _demoJson = r'''
[
  {
    "id": "1",
    "name": "Cao gót mũi nhọn Lumé Classic",
    "category": "Cao gót",
    "price": 650000,
    "oldPrice": 0,
    "rating": 4.5,
    "heelHeight": 7,
    "material": "Da tổng hợp",
    "occasions": [
      "Đi làm",
      "Dự tiệc"
    ],
    "isNew": false,
    "colors": [
      "Đen",
      "Nude"
    ],
    "sizes": [
      "35",
      "36",
      "37",
      "38"
    ],
    "image": "",
    "model3d": "",
    "description": "Thiết kế mũi nhọn thanh lịch, phù hợp đi làm."
  },
  {
    "id": "3",
    "name": "Sandal cao gót quai mảnh Lumé Lavender",
    "category": "Sandal",
    "price": 420000,
    "oldPrice": 490000,
    "rating": 4,
    "heelHeight": 7,
    "material": "Da lộn (suede)",
    "occasions": [
      "Đi làm",
      "Dự tiệc",
      "Hẹn hò"
    ],
    "isNew": false,
    "colors": [
      "Tím lavender",
      "Bạc"
    ],
    "sizes": [
      "35",
      "36",
      "37",
      "38",
      "39"
    ],
    "image": "",
    "model3d": "",
    "description": "Sandal cao gót quai mảnh ôm cổ chân, mũi tròn tối giản, tôn dáng chân thon gọn. Phù hợp đi tiệc hoặc dạo phố buổi tối."
  },
  {
    "id": "5",
    "name": "Sneaker chunky Lumé Vanilla",
    "category": "Sneaker",
    "price": 450000,
    "oldPrice": 750000,
    "rating": 4,
    "heelHeight": 4,
    "material": "Vải canvas phối da",
    "occasions": [
      "Đi học",
      "Dạo phố",
      "Du lịch",
      "Thể thao"
    ],
    "isNew": false,
    "colors": [
      "Vàng bơ",
      "Nâu"
    ],
    "sizes": [
      "36",
      "37",
      "38",
      "39",
      "40"
    ],
    "image": "",
    "model3d": "",
    "description": "Sneaker chunky đế dày phối 2 tông màu pastel, kiểu dáng basic trẻ trung, dễ phối cùng chân váy hoặc quần jeans."
  },
  {
    "id": "6",
    "name": "Sandal cao gót quai nơ Lumé Blossom",
    "category": "Sandal",
    "price": 480000,
    "oldPrice": 880000,
    "rating": 4.4,
    "heelHeight": 7,
    "material": "Da bóng (patent)",
    "occasions": [
      "Dự tiệc",
      "Dạo phố",
      "Hẹn hò"
    ],
    "isNew": true,
    "colors": [
      "Hồng phấn",
      "Hồng đào"
    ],
    "sizes": [
      "35",
      "36",
      "37",
      "38",
      "39"
    ],
    "image": "",
    "model3d": "",
    "description": "Sandal cao gót quai mảnh điểm nơ xinh xắn, mũi vuông thời trang. Thiết kế tối giản nhưng vẫn nổi bật, hợp đi tiệc hoặc dạo phố cuối tuần."
  },
  {
    "id": "7",
    "name": "Giày búp bê nơ Lumé Macaron",
    "category": "Giày búp bê",
    "price": 390000,
    "oldPrice": 690000,
    "rating": 4.5,
    "heelHeight": 1,
    "material": "Da satin",
    "occasions": [
      "Đi học",
      "Đi làm",
      "Dạo phố"
    ],
    "isNew": true,
    "colors": [
      "Hồng phấn",
      "Hồng baby"
    ],
    "sizes": [
      "35",
      "36",
      "37",
      "38",
      "39"
    ],
    "image": "",
    "model3d": "",
    "description": "Giày búp bê mũi tròn phối nơ satin nhẹ nhàng, đế bệt êm chân cả ngày. Phong cách nữ tính, dễ phối cùng chân váy hoặc quần ống rộng."
  },
  {
    "id": "10",
    "name": "Boots cổ ngắn Lumé Rosette",
    "category": "Boots",
    "price": 590000,
    "oldPrice": 990000,
    "rating": 4.8,
    "heelHeight": 7,
    "material": "Da lộn/Da bóng (patent)",
    "occasions": [
      "Dự tiệc",
      "Dạo phố",
      "Du lịch"
    ],
    "isNew": true,
    "colors": [
      "Hồng phấn",
      "Hồng nude"
    ],
    "sizes": [
      "35",
      "36",
      "37",
      "38",
      "39"
    ],
    "image": "",
    "model3d": "",
    "description": "Boots cổ ngắn mũi nhọn gót vuông 7cm, có mẫu da bóng và mẫu da lộn viền bèo nhún điệu đà. Phù hợp mặc cùng quần jeans hoặc váy midi mùa thu đông."
  },
  {
    "id": "11",
    "name": "Cao gót quai hậu ánh kim Lumé Rosé",
    "category": "Cao gót",
    "price": 550000,
    "oldPrice": 950000,
    "rating": 4.9,
    "heelHeight": 8,
    "material": "Vải satin ánh kim",
    "occasions": [
      "Dự tiệc"
    ],
    "isNew": true,
    "colors": [
      "Ánh kim",
      "Đen tuyền"
    ],
    "sizes": [
      "35",
      "36",
      "37",
      "38",
      "39"
    ],
    "image": "",
    "model3d": "",
    "description": "Cao gót mũi nhọn quai hậu đính đá lấp lánh, chất liệu ánh kim sang trọng. Lựa chọn hoàn hảo cho tiệc tối hoặc dịp đặc biệt."
  },
  {
    "id": "13",
    "name": "Cao gót vuông Lumé Elegance",
    "category": "Cao gót",
    "price": 590000,
    "oldPrice": 630000,
    "rating": 4.7,
    "heelHeight": 5,
    "material": "Da tổng hợp",
    "occasions": [
      "Đi làm",
      "Dự tiệc",
      "Hẹn hò"
    ],
    "isNew": true,
    "colors": [
      "Đen",
      "Nude",
      "Kem"
    ],
    "sizes": [
      "35",
      "36",
      "37",
      "38",
      "39"
    ],
    "image": "",
    "model3d": "",
    "description": "Giày cao gót vuông tạo cảm giác vững vàng khi di chuyển, kết hợp kiểu dáng tinh tế. Phù hợp với môi trường công sở và các sự kiện."
  },
  {
    "id": "19",
    "name": "Cao gót quai mảnh Lumé Gala",
    "category": "Cao gót",
    "price": 1250000,
    "oldPrice": 1450000,
    "rating": 4.9,
    "heelHeight": 9,
    "material": "Da lộn",
    "occasions": [
      "Dự tiệc",
      "Hẹn hò"
    ],
    "isNew": true,
    "colors": [
      "Đỏ rượu",
      "Đen"
    ],
    "sizes": [
      "35",
      "36",
      "37",
      "38"
    ],
    "image": "",
    "model3d": "",
    "description": "Cao gót 9cm quai mảnh ôm cổ chân, chất da lộn sang trọng. Hợp dự tiệc và sự kiện buổi tối."
  },
  {
    "id": "20",
    "name": "Sandal gót trong Lumé Crystal",
    "category": "Sandal",
    "price": 890000,
    "oldPrice": 990000,
    "rating": 4.8,
    "heelHeight": 8,
    "material": "Nhựa PVC trong, Da tổng hợp",
    "occasions": [
      "Dự tiệc",
      "Dạo phố"
    ],
    "isNew": true,
    "colors": [
      "Trong suốt",
      "Bạc"
    ],
    "sizes": [
      "35",
      "36",
      "37",
      "38",
      "39"
    ],
    "image": "",
    "model3d": "",
    "description": "Sandal quai trong suốt với gót trong lấp lánh, tạo hiệu ứng chân thon dài. Nổi bật khi đi tiệc hay chụp ảnh."
  },
  {
    "id": "23",
    "name": "Sneaker da trắng Lumé Cloud",
    "category": "Sneaker",
    "price": 980000,
    "oldPrice": 0,
    "rating": 4.9,
    "heelHeight": 3,
    "material": "Da bò",
    "occasions": [
      "Đi học",
      "Đi làm",
      "Dạo phố",
      "Du lịch"
    ],
    "isNew": true,
    "colors": [
      "Trắng",
      "Trắng hồng"
    ],
    "sizes": [
      "35",
      "36",
      "37",
      "38",
      "39",
      "40"
    ],
    "image": "",
    "model3d": "",
    "description": "Sneaker da trắng tối giản với đế cao 3cm êm ái. Dễ phối với mọi trang phục hằng ngày."
  },
  {
    "id": "24",
    "name": "Boots cao cổ Lumé Noir",
    "category": "Boots",
    "price": 1490000,
    "oldPrice": 1690000,
    "rating": 4.8,
    "heelHeight": 7,
    "material": "Da bò",
    "occasions": [
      "Dạo phố",
      "Du lịch"
    ],
    "isNew": true,
    "colors": [
      "Đen",
      "Nâu sô-cô-la"
    ],
    "sizes": [
      "36",
      "37",
      "38"
    ],
    "image": "",
    "model3d": "",
    "description": "Boots cao cổ gót vuông 7cm, da bò thật bền đẹp. Phối cùng váy dài hoặc quần skinny cho mùa lạnh."
  }
]
''';
