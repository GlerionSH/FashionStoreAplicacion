import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../domain/entities/flash_offer.dart';
import '../../domain/repositories/flash_offers_repository.dart';
import '../datasources/flash_offers_remote_datasource.dart';

class FlashOffersRepositoryImpl implements FlashOffersRepository {
  final FlashOffersRemoteDatasource remote;

  const FlashOffersRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, FlashOffer?>> getActiveOffer() async {
    try {
      final offer = await remote.getActiveOffer();
      return right(offer);
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }
}
