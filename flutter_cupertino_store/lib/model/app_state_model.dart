import 'package:flutter/foundation.dart' as foundation;

import 'product.dart';
import 'products_repository.dart';

double _salesTaxRate = 0.06;
double _shippingCostPerItem = 7;

class AppStateModel extends foundation.ChangeNotifier {
  List<Product> _availableProducts;

  Category _selectedCategory = Category.all;

  // Will carry the IDs and quantities currently in cart
  final _productsInCart = <int, int>{};

  Map<int, int> get productsInCart {
    return Map.from(_productsInCart);
  }

  // Computed properties
  Category get selectedCategory {
    return _selectedCategory;
  }

  int get totalCartQuantity {
    return _productsInCart.values.fold(0, (accumulator, value) {
      return accumulator + value;
    });
  }

  double get subtotalCost {
    return _productsInCart.keys.map( (id) {
      return _availableProducts[id].price * _productsInCart[id];
    }).fold(0, (accumulator, extendedPrice) {
      return accumulator + extendedPrice;
    });
  }

  double get shippingCost {
    return _shippingCostPerItem 
         * _productsInCart.values.fold(0, (acc, itemCount){
      return acc + itemCount;
    });
  }

  double get tax {
    return subtotalCost * _salesTaxRate;
  }

  double get totalCost {
    return subtotalCost + shippingCost + tax;
  }

  List<Product> getProducts() {
    if (_availableProducts == null) {
      return [];
    }

    if (_selectedCategory == Category.all) {
      return List.from(_availableProducts);
    } else {
      return _availableProducts.where( (p) {
        return p.category == _selectedCategory;
      }).toList();
    }
  }

  List<Product> search(String searchTerms) {
    return getProducts().where( (p) {
      return p.name.toLowerCase().contains(searchTerms.toLowerCase());
    }).toList();
  }

  Product getProductById(int id) {
    return _availableProducts.firstWhere((p) => p.id == id);
  }

  void addProductToCart(int productId) {
    if (!_productsInCart.containsKey(productId)) {
      _productsInCart[productId] = 1;
    } else {
      _productsInCart[productId]++;
    }

    notifyListeners();
  }

  void removeItemFromCart(int productId) {
    if (_productsInCart.containsKey(productId)) {
      if (_productsInCart[productId] == 1) {
        _productsInCart.remove(productId);
      } else {
        _productsInCart[productId]--;
      }
    }
  
    notifyListeners();
  }

  void clearCart() {
    _productsInCart.clear();

    notifyListeners();
  }

  void loadProducts() {
    _availableProducts = ProductsRepository.loadProducts(Category.all);
    
    notifyListeners();
  }

  void setCategory(Category newCategory) {
    _selectedCategory = newCategory;

    notifyListeners();
  }




}
