abstract class AdminRemoteDatasource {
  Future<void> listProducts();
  Future<void> upsertProduct();
  Future<void> listOrders();
  Future<void> getOrderById(String orderId);
  Future<void> listReturns();
  Future<void> updateFlashSettings();
}

class AdminRemoteDatasourceImpl implements AdminRemoteDatasource {
  const AdminRemoteDatasourceImpl();

  @override
  Future<void> listProducts() async {
    // TODO: Implement using Supabase direct queries (fs_products).
    throw UnimplementedError();
  }

  @override
  Future<void> upsertProduct() async {
    // TODO: Implement using Supabase direct queries (fs_products).
    throw UnimplementedError();
  }

  @override
  Future<void> listOrders() async {
    // TODO: Implement using Supabase direct queries (fs_orders).
    throw UnimplementedError();
  }

  @override
  Future<void> getOrderById(String orderId) async {
    // TODO: Implement using Supabase direct queries (fs_orders + fs_order_items).
    throw UnimplementedError();
  }

  @override
  Future<void> listReturns() async {
    // TODO: Implement using existing Astro /api/admin/returns/* endpoints or direct Supabase if used in Astro.
    throw UnimplementedError();
  }

  @override
  Future<void> updateFlashSettings() async {
    // TODO: Implement using Supabase direct queries (fs_settings + fs_flash_offers).
    throw UnimplementedError();
  }
}
