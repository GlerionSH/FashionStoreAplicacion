import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../entities/flash_offer.dart';

abstract class FlashOffersRepository {
  Future<Either<Failure, FlashOffer?>> getActiveOffer();
}
