import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../data/datasources/flash_offers_remote_datasource.dart';
import '../../data/repositories/flash_offers_repository_impl.dart';
import '../../domain/entities/flash_offer.dart';
import '../../domain/repositories/flash_offers_repository.dart';

final flashOffersRemoteDatasourceProvider =
    Provider<FlashOffersRemoteDatasource>((ref) {
  return const FlashOffersRemoteDatasourceImpl();
});

final flashOffersRepositoryProvider = Provider<FlashOffersRepository>((ref) {
  return FlashOffersRepositoryImpl(
      ref.watch(flashOffersRemoteDatasourceProvider));
});

/// The currently active flash offer, or null if none active.
final activeFlashOfferProvider =
    FutureProvider<Either<Failure, FlashOffer?>>((ref) {
  return ref.watch(flashOffersRepositoryProvider).getActiveOffer();
});
