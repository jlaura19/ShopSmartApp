import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final String? description;
  final DateTime expenseDate;
  final String? receiptUrl;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    this.description,
    required this.expenseDate,
    this.receiptUrl,
    required this.createdAt,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'category': category,
      'amount': amount,
      'description': description,
      'expenseDate': expenseDate,
      'receiptUrl': receiptUrl,
      'createdAt': createdAt,
    };
  }

  // Create from Firestore JSON
  factory ExpenseModel.fromJson(Map<String, dynamic> json, String docId) {
    return ExpenseModel(
      id: docId,
      userId: json['userId'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      expenseDate: (json['expenseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      receiptUrl: json['receiptUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create from Firestore DocumentSnapshot
  factory ExpenseModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data();
    if (data == null) throw Exception('Expense data not found');
    return ExpenseModel.fromJson(data, snap.id);
  }

  // Copy with modifications
  ExpenseModel copyWith({
    String? id,
    String? userId,
    String? category,
    double? amount,
    String? description,
    DateTime? expenseDate,
    String? receiptUrl,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      expenseDate: expenseDate ?? this.expenseDate,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'ExpenseModel(id: $id, category: $category, amount: $amount)';
}
