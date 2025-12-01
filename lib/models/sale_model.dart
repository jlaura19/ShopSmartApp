import 'package:cloud_firestore/cloud_firestore.dart';

class SaleModel {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final int quantity;
  final double pricePerUnit;
  final double totalAmount;
  final DateTime saleDate;
  final String? notes;
  final DateTime createdAt;

  SaleModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalAmount,
    required this.saleDate,
    this.notes,
    required this.createdAt,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'totalAmount': totalAmount,
      'saleDate': saleDate,
      'notes': notes,
      'createdAt': createdAt,
    };
  }

  // Create from Firestore JSON
  factory SaleModel.fromJson(Map<String, dynamic> json, String docId) {
    return SaleModel(
      id: docId,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      saleDate: (json['saleDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: json['notes'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create from Firestore DocumentSnapshot
  factory SaleModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data();
    if (data == null) throw Exception('Sale data not found');
    return SaleModel.fromJson(data, snap.id);
  }

  // Copy with modifications
  SaleModel copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productName,
    int? quantity,
    double? pricePerUnit,
    double? totalAmount,
    DateTime? saleDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return SaleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      totalAmount: totalAmount ?? this.totalAmount,
      saleDate: saleDate ?? this.saleDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'SaleModel(id: $id, productName: $productName, quantity: $quantity, totalAmount: $totalAmount)';
}
