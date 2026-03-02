// lib/core/files/pdf_service.dart
//
// ORIGIN of PDFs in this app:
//   - Edge Function `invoice_pdf` (GET ?order_id=&token=) validated via invoice_token.
//   - Returns JSON { url: signedUrl } (Storage private bucket "invoices")
//     or, as fallback, raw application/pdf bytes if Storage upload failed.
//   - Calling via launchUrl → 401 because browser has no apikey/Authorization.
//
// SOLUTION applied (CASO 1 — Edge Function + Storage signed URL):
//   1. Call functions.invoke('invoice_pdf', ...) — SDK adds auth headers automatically.
//   2. If response.data is Map → extract signed URL → download bytes (no auth needed).
//      If response.data is Uint8List → use bytes directly.
//   3. Save bytes to getApplicationDocumentsDirectory().
//   4. Open with open_filex.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Exceptions ──────────────────────────────────────────────────────────────

class PdfDownloadException implements Exception {
  final String code;
  const PdfDownloadException(this.code);
  @override
  String toString() => 'PdfDownloadException($code)';
}

class PdfOpenException implements Exception {
  final String message;
  const PdfOpenException(this.message);
  @override
  String toString() => 'PdfOpenException($message)';
}

// ─── Service ─────────────────────────────────────────────────────────────────

class PdfService {
  PdfService._();

  // ── CASO 1: Download from any URL with optional Authorization header ────────
  // Use this when calling a protected REST endpoint that returns application/pdf.
  static Future<File> downloadPdfFromProtectedEndpoint({
    required String url,
    required String fileName,
    required String? accessToken,
  }) async {
    final headers = <String, String>{};
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    if (kDebugMode) debugPrint('[PdfService] GET $url');
    final response = await http.get(Uri.parse(url), headers: headers);
    if (kDebugMode) debugPrint('[PdfService] status=${response.statusCode}');

    if (response.statusCode == 401) throw const PdfDownloadException('session_expired');
    if (response.statusCode == 404) throw const PdfDownloadException('not_found');
    if (response.statusCode != 200) {
      throw PdfDownloadException('http_${response.statusCode}');
    }

    return _saveBytes(response.bodyBytes, fileName);
  }

  // ── CASO 2: Download from Supabase Storage private bucket via signed URL ────
  // Use this when you have the bucket + path and need a temporary download URL.
  static Future<File> downloadPdfFromSupabaseStoragePrivate({
    required String bucket,
    required String path,
    required String fileName,
  }) async {
    final sb = Supabase.instance.client;
    if (kDebugMode) debugPrint('[PdfService] createSignedUrl $bucket/$path');

    final signedUrl = await sb.storage.from(bucket).createSignedUrl(path, 60);

    if (kDebugMode) debugPrint('[PdfService] signedUrl obtained, downloading...');
    final response = await http.get(Uri.parse(signedUrl));
    if (response.statusCode == 404) throw const PdfDownloadException('not_found');
    if (response.statusCode != 200) {
      throw PdfDownloadException('http_${response.statusCode}');
    }

    return _saveBytes(response.bodyBytes, fileName);
  }

  // ── Open a saved PDF file with the system viewer ────────────────────────────
  static Future<OpenResult> openPdfFile(File file) async {
    if (kDebugMode) debugPrint('[PdfService] Opening ${file.path}');
    final result = await OpenFilex.open(file.path, type: 'application/pdf');
    if (kDebugMode) debugPrint('[PdfService] OpenFilex result: ${result.type} ${result.message}');
    return result;
  }

  // ── Complete invoice flow: Edge Function → download bytes → save → open ─────
  // This is the main entry-point used by "Descargar PDF" in Mis pedidos.
  //
  // The invoice_pdf Edge Function:
  //  - Validates order_id + invoice_token internally (service_role).
  //  - Returns { url: signedStorageUrl } OR raw PDF bytes as fallback.
  //  - functions.invoke() automatically adds apikey + Authorization headers.
  static Future<void> downloadAndOpenInvoice({
    required String orderId,
    required String invoiceToken,
  }) async {
    final sb = Supabase.instance.client;

    // Check session before invoking
    if (sb.auth.currentSession == null) {
      throw const PdfDownloadException('no_session');
    }

    final shortId = orderId.length >= 8 ? orderId.substring(0, 8) : orderId;
    final fileName = 'Factura_$shortId';

    if (kDebugMode) {
      debugPrint('[PdfService] invoking invoice_pdf order_id=$shortId...');
    }

    // Call Edge Function — SDK injects apikey + Authorization automatically
    final response = await sb.functions.invoke(
      'invoice_pdf',
      method: HttpMethod.get,
      queryParameters: {'order_id': orderId, 'token': invoiceToken},
    );

    if (kDebugMode) {
      debugPrint('[PdfService] invoice_pdf status=${response.status} '
          'dataType=${response.data?.runtimeType}');
    }

    if (response.status == 401) throw const PdfDownloadException('session_expired');
    if (response.status == 404) throw const PdfDownloadException('not_found');
    if (response.status != 200) {
      throw PdfDownloadException('http_${response.status}');
    }

    late final File file;

    // Case A: Edge Function returned JSON { url: signedUrl }
    if (response.data is Map<String, dynamic>) {
      final url = (response.data as Map<String, dynamic>)['url'] as String?;
      if (url == null || url.isEmpty) throw const PdfDownloadException('no_url');

      if (kDebugMode) debugPrint('[PdfService] downloading signed URL...');
      final httpResp = await http.get(Uri.parse(url));
      if (httpResp.statusCode == 404) throw const PdfDownloadException('not_found');
      if (httpResp.statusCode != 200) {
        throw PdfDownloadException('signed_url_http_${httpResp.statusCode}');
      }
      file = await _saveBytes(httpResp.bodyBytes, fileName);
    }
    // Case B: Edge Function returned raw PDF bytes (Storage upload failed fallback)
    else if (response.data is Uint8List) {
      file = await _saveBytes(response.data as Uint8List, fileName);
    } else {
      throw const PdfDownloadException('unknown_response_format');
    }

    final openResult = await openPdfFile(file);
    if (openResult.type != ResultType.done) {
      throw PdfOpenException('${openResult.message} (path: ${file.path})');
    }
  }

  // ── Internal helper ──────────────────────────────────────────────────────────
  static Future<File> _saveBytes(Uint8List bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final safeName = fileName.replaceAll(RegExp(r'[^\w\-]'), '_');
    final file = File('${dir.path}/$safeName.pdf');
    await file.writeAsBytes(bytes, flush: true);
    if (kDebugMode) debugPrint('[PdfService] saved to ${file.path} (${bytes.length} bytes)');
    return file;
  }
}
