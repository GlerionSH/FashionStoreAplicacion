import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDatasource remote;

  const AdminRepositoryImpl(this.remote);

  @override
  Future<void> listProducts() => remote.listProducts();

  @override
  Future<void> upsertProduct() => remote.upsertProduct();

  @override
  Future<void> listOrders() => remote.listOrders();

  @override
  Future<void> getOrderById(String orderId) => remote.getOrderById(orderId);

  @override
  Future<void> listReturns() => remote.listReturns();

  @override
  Future<void> updateFlashSettings() => remote.updateFlashSettings();
}
