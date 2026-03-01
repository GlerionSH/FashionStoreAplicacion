abstract class AdminRepository {
  Future<void> listProducts();
  Future<void> upsertProduct();
  Future<void> listOrders();
  Future<void> getOrderById(String orderId);
  Future<void> listReturns();
  Future<void> updateFlashSettings();
}
