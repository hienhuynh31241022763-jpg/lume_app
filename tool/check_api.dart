// ignore_for_file: avoid_print
import 'package:lume_app/data/product_api.dart';

Future<void> main() async {
  final products = await ProductApi().fetchProducts();
  print('Có ${products.length} sản phẩm');
  for (final p in products) {
    print('${p.id} | ${p.name} | ${p.price} | ${p.colors} | ${p.sizes}');
  }
}
