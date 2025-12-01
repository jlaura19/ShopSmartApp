import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartshop_app/models/user_model.dart';
import 'package:smartshop_app/models/product_model.dart';
import 'package:smartshop_app/models/sale_model.dart';
import 'package:smartshop_app/models/expense_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ==================== USER OPERATIONS ====================

  /// Create user document in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toJson());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  /// Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final snap = await _firestore.collection('users').doc(userId).get();
      if (!snap.exists) return null;
      return UserModel.fromSnapshot(snap);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    if (currentUserId == null) return null;
    return getUser(currentUserId!);
  }

  /// Update user profile
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = DateTime.now();
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  /// Stream of current user
  Stream<UserModel?> watchCurrentUser() {
    if (currentUserId == null) return Stream.value(null);
    return _firestore
        .collection('users')
        .doc(currentUserId!)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return null;
      return UserModel.fromSnapshot(snap);
    }).handleError((e) {
      print('Error watching user: $e');
    });
  }

  // ==================== PRODUCT OPERATIONS ====================

  /// Add new product
  Future<String> addProduct(ProductModel product) async {
    try {
      final docRef = await _firestore.collection('products').add(product.toJson());
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  /// Get product by ID
  Future<ProductModel?> getProduct(String productId) async {
    try {
      final snap = await _firestore.collection('products').doc(productId).get();
      if (!snap.exists) return null;
      return ProductModel.fromSnapshot(snap);
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  /// Get all products for current user
  Future<List<ProductModel>> getProducts() async {
    if (currentUserId == null) return [];
    try {
      final query = await _firestore
          .collection('products')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();
      return query.docs
          .map((doc) => ProductModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  /// Stream of products for current user
  Stream<List<ProductModel>> watchProducts() {
    if (currentUserId == null) return Stream.value([]);
    return _firestore
        .collection('products')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((query) => query.docs
            .map((doc) => ProductModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList())
        .handleError((e) {
          print('Error watching products: $e');
        });
  }

  /// Update product
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = DateTime.now();
      await _firestore.collection('products').doc(productId).update(data);
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  /// Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  // ==================== SALE OPERATIONS ====================

  /// Add new sale
  Future<String> addSale(SaleModel sale) async {
    try {
      final docRef = await _firestore.collection('sales').add(sale.toJson());
      return docRef.id;
    } catch (e) {
      print('Error adding sale: $e');
      rethrow;
    }
  }

  /// Get all sales for current user
  Future<List<SaleModel>> getSales() async {
    if (currentUserId == null) return [];
    try {
      final query = await _firestore
          .collection('sales')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('saleDate', descending: true)
          .get();
      return query.docs
          .map((doc) => SaleModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print('Error getting sales: $e');
      return [];
    }
  }

  /// Stream of sales for current user
  Stream<List<SaleModel>> watchSales() {
    if (currentUserId == null) return Stream.value([]);
    return _firestore
        .collection('sales')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('saleDate', descending: true)
        .snapshots()
        .map((query) => query.docs
            .map((doc) => SaleModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList())
        .handleError((e) {
          print('Error watching sales: $e');
        });
  }

  /// Get sales within date range
  Future<List<SaleModel>> getSalesByDateRange(DateTime startDate, DateTime endDate) async {
    if (currentUserId == null) return [];
    try {
      final query = await _firestore
          .collection('sales')
          .where('userId', isEqualTo: currentUserId)
          .where('saleDate', isGreaterThanOrEqualTo: startDate)
          .where('saleDate', isLessThanOrEqualTo: endDate)
          .orderBy('saleDate', descending: true)
          .get();
      return query.docs
          .map((doc) => SaleModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print('Error getting sales by date range: $e');
      return [];
    }
  }

  /// Delete sale
  Future<void> deleteSale(String saleId) async {
    try {
      await _firestore.collection('sales').doc(saleId).delete();
    } catch (e) {
      print('Error deleting sale: $e');
      rethrow;
    }
  }

  // ==================== EXPENSE OPERATIONS ====================

  /// Add new expense
  Future<String> addExpense(ExpenseModel expense) async {
    try {
      final docRef = await _firestore.collection('expenses').add(expense.toJson());
      return docRef.id;
    } catch (e) {
      print('Error adding expense: $e');
      rethrow;
    }
  }

  /// Get all expenses for current user
  Future<List<ExpenseModel>> getExpenses() async {
    if (currentUserId == null) return [];
    try {
      final query = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('expenseDate', descending: true)
          .get();
      return query.docs
          .map((doc) => ExpenseModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print('Error getting expenses: $e');
      return [];
    }
  }

  /// Stream of expenses for current user
  Stream<List<ExpenseModel>> watchExpenses() {
    if (currentUserId == null) return Stream.value([]);
    return _firestore
        .collection('expenses')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('expenseDate', descending: true)
        .snapshots()
        .map((query) => query.docs
            .map((doc) => ExpenseModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList())
        .handleError((e) {
          print('Error watching expenses: $e');
        });
  }

  /// Get expenses within date range
  Future<List<ExpenseModel>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    if (currentUserId == null) return [];
    try {
      final query = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: currentUserId)
          .where('expenseDate', isGreaterThanOrEqualTo: startDate)
          .where('expenseDate', isLessThanOrEqualTo: endDate)
          .orderBy('expenseDate', descending: true)
          .get();
      return query.docs
          .map((doc) => ExpenseModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print('Error getting expenses by date range: $e');
      return [];
    }
  }

  /// Update expense
  Future<void> updateExpense(String expenseId, Map<String, dynamic> data) async {
    try {
      data['createdAt'] = DateTime.now();
      await _firestore.collection('expenses').doc(expenseId).update(data);
    } catch (e) {
      print('Error updating expense: $e');
      rethrow;
    }
  }

  /// Delete expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore.collection('expenses').doc(expenseId).delete();
    } catch (e) {
      print('Error deleting expense: $e');
      rethrow;
    }
  }

  // ==================== ANALYTICS OPERATIONS ====================

  /// Get total revenue for date range
  Future<double> getTotalRevenue(DateTime startDate, DateTime endDate) async {
    try {
      final sales = await getSalesByDateRange(startDate, endDate);
      double total = 0.0;
      for (final sale in sales) {
        total += sale.totalAmount;
      }
      return total;
    } catch (e) {
      print('Error calculating revenue: $e');
      return 0.0;
    }
  }

  /// Get total expenses for date range
  Future<double> getTotalExpenses(DateTime startDate, DateTime endDate) async {
    try {
      final expenses = await getExpensesByDateRange(startDate, endDate);
      double total = 0.0;
      for (final expense in expenses) {
        total += expense.amount;
      }
      return total;
    } catch (e) {
      print('Error calculating expenses: $e');
      return 0.0;
    }
  }

  /// Get profit (revenue - expenses) for date range
  Future<double> getProfit(DateTime startDate, DateTime endDate) async {
    try {
      final revenue = await getTotalRevenue(startDate, endDate);
      final expenses = await getTotalExpenses(startDate, endDate);
      return revenue - expenses;
    } catch (e) {
      print('Error calculating profit: $e');
      return 0.0;
    }
  }
}
