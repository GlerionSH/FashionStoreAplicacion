import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/products_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductsRemoteDatasource remoteDatasource;

  const ProductRepositoryImpl(this.remoteDatasource);

  static const _maxRetries = 3;
  static const _backoffDelays = [
    Duration(milliseconds: 500),
    Duration(seconds: 1),
    Duration(seconds: 2),
  ];

  /// Returns true if the error is transient and worth retrying.
  bool _isTransient(Object e) {
    if (e is SocketException) return true;
    if (e is http.ClientException) return true;
    if (e is TimeoutException) return true;
    // Supabase 5xx-class or network-level PostgrestException
    if (e is PostgrestException) {
      final code = e.code;
      // Don't retry auth/RLS errors
      if (code == '42501' || code == '401' || code == '403') return false;
      return true;
    }
    return false;
  }

  /// Retries [fn] up to [_maxRetries] times with exponential backoff
  /// for transient errors only.
  Future<T> _withRetry<T>(Future<T> Function() fn, String label) async {
    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        return await fn();
      } catch (e) {
        if (attempt < _maxRetries && _isTransient(e)) {
          final delay = _backoffDelays[attempt];
          debugPrint('[ProductRepo] $label attempt ${attempt + 1} failed '
              '(${e.runtimeType}), retrying in ${delay.inMilliseconds}ms…');
          await Future.delayed(delay);
          continue;
        }
        rethrow;
      }
    }
    throw StateError('Unreachable');
  }

  Failure _classify(Object e) {
    if (e is SocketException) {
      return const NetworkFailure(
        'Sin conexión a internet. Comprueba tu red e inténtalo de nuevo.',
      );
    }

    if (e is http.ClientException) {
      final isCors = kIsWeb &&
          (e.message.contains('Failed to fetch') ||
              e.message.contains('XMLHttpRequest'));
      if (isCors) {
        return const CorsFailure(
          'No se pudo conectar a Supabase (posible bloqueo CORS). '
          'Revisa las extensiones del navegador y la configuracion '
          'de CORS origins en tu proyecto Supabase.',
        );
      }
      return NetworkFailure('Error de red: ${e.message}');
    }

    if (e is AuthException) {
      return AuthFailure('Auth: ${e.message} (${e.statusCode})');
    }

    if (e is PostgrestException) {
      final code = e.code;
      if (code == '42501' || code == '401' || code == '403') {
        return RlsFailure(
          'Permiso denegado en fs_products (code=$code). '
          'Revisa las RLS policies para el rol anon.',
          sqlHint: 'CREATE POLICY "anon_select_products" ON fs_products '
              'FOR SELECT TO anon USING (is_active = true);',
        );
      }
      return NetworkFailure('Supabase: ${e.message} (code=$code)');
    }

    return UnknownFailure(e.toString());
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    int limit = 20,
    int offset = 0,
    String? categoryId,
    String? search,
  }) async {
    try {
      final models = await _withRetry(
        () => remoteDatasource.fetchProducts(
          limit: limit,
          offset: offset,
          categoryId: categoryId,
          search: search,
        ),
        'getProducts',
      );
      return right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return left(_classify(e));
    }
  }

  @override
  Future<Either<Failure, Product?>> getBySlug(String slug) async {
    try {
      final model = await _withRetry(
        () => remoteDatasource.getBySlug(slug),
        'getBySlug($slug)',
      );
      return right(model?.toEntity());
    } catch (e) {
      return left(_classify(e));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getFlashProducts() async {
    try {
      final models = await _withRetry(
        () => remoteDatasource.fetchFlashProducts(),
        'getFlashProducts',
      );
      return right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return left(_classify(e));
    }
  }
}
