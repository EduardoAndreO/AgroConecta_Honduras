import 'package:flutter/foundation.dart';
import '../models/models.dart';

class CartItem {
  final Publicacion product;
  int quantity;
  CartItem({required this.product, required this.quantity});
  double get total => product.precioHnl * quantity;
}

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);
  int get count => _items.fold(0, (sum, item) => sum + item.quantity);
  double get total => _items.fold(0, (sum, item) => sum + item.total);

  void add(Publicacion product, {int quantity = 1}) {
    final existing =
        _items.where((item) => item.product.id == product.id).firstOrNull;
    if (existing == null) {
      _items.add(CartItem(product: product, quantity: quantity));
    } else {
      existing.quantity =
          (existing.quantity + quantity).clamp(1, product.sacos);
    }
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((item) => item.product.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
