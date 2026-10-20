import 'package:equatable/equatable.dart';

enum StorePurchaseStatus {
  /// Waiting for the payment (e.g. cash in a shop): the plan applies once it is paid.
  pending,

  /// Paid now: it must be registered in the server.
  purchased,

  /// Paid before (another session or while the app was closed): registered again, quietly.
  restored,
  canceled,
  error,
}

/// What the store says about a purchase.
class StorePurchaseUpdate extends Equatable {
  final StorePurchaseStatus status;
  final String productId;

  /// The token the server verifies with the store; null when there is no purchase.
  final String? purchaseToken;

  const StorePurchaseUpdate({required this.status, required this.productId, this.purchaseToken});

  @override
  List<Object?> get props => [status, productId, purchaseToken];
}
