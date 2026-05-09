import 'package:flutter/foundation.dart';
import 'package:sukisave/core/models/vendor_order_request.dart';
import 'package:sukisave/core/services/auth_service.dart';
import 'package:sukisave/core/services/product_service.dart';

class VendorOrderStore extends ChangeNotifier {
  VendorOrderStore._();

  static final VendorOrderStore instance = VendorOrderStore._();

  final List<VendorOrderRequest> _requests = [];
  int _nextRequestId = 1;

  List<VendorOrderRequest> get requests => List.unmodifiable(_requests);

  List<VendorOrderRequest> get pendingRequests =>
      _requests.where((item) => item.isPending).toList();

  VendorOrderRequest createRequest({
    required int productId,
    required String name,
    required String description,
    required int price,
    required int quantity,
    required String imagePath,
  }) {
    return VendorOrderRequest(
      requestId: _nextRequestId++,
      productId: productId,
      customerUserId: AuthService.instance.currentUser?.id ?? 0,
      name: name,
      description: description,
      price: price,
      quantity: quantity,
      imagePath: imagePath,
      createdAt: DateTime.now(),
      status: VendorOrderStatus.pending,
    );
  }

  void addRequests(List<VendorOrderRequest> requests) {
    if (requests.isEmpty) return;
    _requests.addAll(requests);
    notifyListeners();
  }

  void updateStatus(
    int requestId,
    VendorOrderStatus status, {
    String? declineReason,
  }) {
    final index = _requests.indexWhere((item) => item.requestId == requestId);
    if (index == -1) return;
    if (_requests[index].status == status) return;

    _requests[index].status = status;
    if (status == VendorOrderStatus.denied) {
      _requests[index].declineReason = declineReason;
      ProductService().restoreQuantity(
        _requests[index].productId,
        amount: _requests[index].quantity,
      );
    } else if (status == VendorOrderStatus.accepted) {
      _requests[index].declineReason = null;
    }
    notifyListeners();
  }

  void removeByRequestIds(Set<int> requestIds) {
    if (requestIds.isEmpty) return;
    _requests.removeWhere((item) => requestIds.contains(item.requestId));
    notifyListeners();
  }
}
