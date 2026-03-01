import '../../domain/entities/cart_item.dart';

class CartItemModel {
  final String productId;
  final String name;
  final String slug;
  final String? imageUrl;
  final int priceCents;
  final int quantity;
  final String? size;

  const CartItemModel({
    required this.productId,
    required this.name,
    required this.slug,
    this.imageUrl,
    required this.priceCents,
    required this.quantity,
    this.size,
  });

  String get uniqueKey => '$productId|${size ?? ""}';

  CartItem toEntity() => CartItem(
        productId: productId,
        name: name,
        slug: slug,
        imageUrl: imageUrl,
        priceCents: priceCents,
        quantity: quantity,
        size: size,
      );

  factory CartItemModel.fromEntity(CartItem entity) => CartItemModel(
        productId: entity.productId,
        name: entity.name,
        slug: entity.slug,
        imageUrl: entity.imageUrl,
        priceCents: entity.priceCents,
        quantity: entity.quantity,
        size: entity.size,
      );

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        productId: json['productId'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        imageUrl: json['imageUrl'] as String?,
        priceCents: json['priceCents'] as int,
        quantity: json['quantity'] as int,
        size: json['size'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'slug': slug,
        'imageUrl': imageUrl,
        'priceCents': priceCents,
        'quantity': quantity,
        'size': size,
      };
}
