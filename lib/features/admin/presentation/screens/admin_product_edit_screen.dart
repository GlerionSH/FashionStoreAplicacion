import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../../products/data/models/product_model.dart';
import '../../products/presentation/providers/admin_products_providers.dart';

class AdminProductEditScreen extends ConsumerStatefulWidget {
  final String productId;

  const AdminProductEditScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<AdminProductEditScreen> createState() =>
      _AdminProductEditScreenState();
}

class _AdminProductEditScreenState
    extends ConsumerState<AdminProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loaded = false;
  bool _saving = false;

  final _nameCtrl = TextEditingController();
  final _nameEsCtrl = TextEditingController();
  final _nameEnCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _descEsCtrl = TextEditingController();
  final _descEnCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _imagesCtrl = TextEditingController();
  final _sizesCtrl = TextEditingController();
  final _sizeStockCtrl = TextEditingController();
  bool _isActive = true;
  bool _isFlash = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameEsCtrl.dispose();
    _nameEnCtrl.dispose();
    _slugCtrl.dispose();
    _descCtrl.dispose();
    _descEsCtrl.dispose();
    _descEnCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _categoryCtrl.dispose();
    _imagesCtrl.dispose();
    _sizesCtrl.dispose();
    _sizeStockCtrl.dispose();
    super.dispose();
  }

  void _populateFromProduct(ProductModel product) {
    if (_loaded) return;
    _loaded = true;
    _nameCtrl.text = product.name;
    _nameEsCtrl.text = product.nameEs ?? '';
    _nameEnCtrl.text = product.nameEn ?? '';
    _slugCtrl.text = product.slug;
    _descCtrl.text = product.description ?? '';
    _descEsCtrl.text = product.descriptionEs ?? '';
    _descEnCtrl.text = product.descriptionEn ?? '';
    _priceCtrl.text = '${product.priceCents}';
    _stockCtrl.text = '${product.stock}';
    _categoryCtrl.text = product.categoryId ?? '';
    _imagesCtrl.text = product.images.join('\n');
    _sizesCtrl.text = product.sizes.join(', ');
    _sizeStockCtrl.text = jsonEncode(product.sizeStock);
    _isActive = product.isActive;
    _isFlash = product.isFlash;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final images = _imagesCtrl.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final sizes = _sizesCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    Map<String, dynamic> sizeStock = {};
    try {
      final decoded = jsonDecode(_sizeStockCtrl.text);
      if (decoded is Map) {
        sizeStock = decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {}

    final data = {
      'id': widget.productId,
      'name': _nameCtrl.text.trim(),
      'name_es': _nameEsCtrl.text.trim().isEmpty
          ? null
          : _nameEsCtrl.text.trim(),
      'name_en': _nameEnCtrl.text.trim().isEmpty
          ? null
          : _nameEnCtrl.text.trim(),
      'slug': _slugCtrl.text.trim(),
      'description': _descCtrl.text.trim().isEmpty
          ? null
          : _descCtrl.text.trim(),
      'description_es': _descEsCtrl.text.trim().isEmpty
          ? null
          : _descEsCtrl.text.trim(),
      'description_en': _descEnCtrl.text.trim().isEmpty
          ? null
          : _descEnCtrl.text.trim(),
      'price_cents': int.tryParse(_priceCtrl.text) ?? 0,
      'stock': int.tryParse(_stockCtrl.text) ?? 0,
      'category_id': _categoryCtrl.text.trim().isEmpty
          ? null
          : _categoryCtrl.text.trim(),
      'is_active': _isActive,
      'is_flash': _isFlash,
      'images': images,
      'sizes': sizes,
      'size_stock': sizeStock,
    };

    try {
      await ref.read(adminProductsDatasourceProvider).upsertProduct(data);
      ref.invalidate(adminProductsListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context)!.adminProductSaved)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final t = S.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.adminProductDeleteTitle),
        content: Text(t.adminProductDeleteMsg),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.adminCancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.adminProductDeleteBtn)),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final resp = await SupabaseService.client.functions.invoke(
        'admin-products-delete',
        method: HttpMethod.delete,
        body: {'product_id': widget.productId},
      );
      final data = resp.data as Map<String, dynamic>?;
      if (data?['has_orders'] == true) {
        if (!mounted) return;
        // Offer to deactivate instead
        final deactivate = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(t.adminProductDeleteTitle),
            content: Text(t.adminProductDeleteHasOrders),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.adminCancel)),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(t.adminProductDeactivateInstead),
              ),
            ],
          ),
        );
        if (deactivate == true) {
          await ref
              .read(adminProductsDatasourceProvider)
              .toggleActive(widget.productId, isActive: false);
          ref.invalidate(adminProductDetailProvider(widget.productId));
          ref.invalidate(adminProductsListProvider);
          if (mounted) context.pop();
        }
        return;
      }
      if (data?['error'] != null) throw Exception(data!['error']);
      ref.invalidate(adminProductDetailProvider(widget.productId));
      ref.invalidate(adminProductsListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.adminProductDeleted)));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAv = ref.watch(adminProductDetailProvider(widget.productId));

    final t = S.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.adminProductEditTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.go('/admin-panel/productos'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: _delete,
          ),
        ],
      ),
      body: productAv.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (product) {
          _populateFromProduct(product);
          return _buildForm();
        },
      ),
    );
  }

  Widget _buildForm() {
    final t = S.of(context)!;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _field(t.adminFieldName, _nameCtrl, required: true),
          _field(t.adminFieldNameEs, _nameEsCtrl),
          _field(t.adminFieldNameEn, _nameEnCtrl),
          _field(t.adminFieldSlug, _slugCtrl, required: true),
          _field(t.adminFieldDesc, _descCtrl, maxLines: 3),
          _field(t.adminFieldDescEs, _descEsCtrl, maxLines: 3),
          _field(t.adminFieldDescEn, _descEnCtrl, maxLines: 3),
          _field(t.adminFieldPrice, _priceCtrl,
              required: true, numeric: true),
          _field(t.adminFieldStock, _stockCtrl, required: true, numeric: true),
          _field(t.adminFieldCategoryId, _categoryCtrl),
          SwitchListTile(
            title: Text(t.adminFieldActive,
                style: const TextStyle(fontSize: 13, letterSpacing: 0.5)),
            value: _isActive,
            activeTrackColor: const Color(0xFF111111),
            onChanged: (v) => setState(() => _isActive = v),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text(t.adminFieldFlash,
                style: const TextStyle(fontSize: 13, letterSpacing: 0.5)),
            value: _isFlash,
            activeTrackColor: const Color(0xFF111111),
            onChanged: (v) => setState(() => _isFlash = v),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          Text(t.adminFieldImages,
              style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.0,
                  color: Color(0xFF9E9E9E))),
          const SizedBox(height: 4),
          TextFormField(
            controller: _imagesCtrl,
            maxLines: 5,
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              hintText: 'https://...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          _field(t.adminFieldSizes, _sizesCtrl),
          const SizedBox(height: 4),
          Text(t.adminFieldSizeStock,
              style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.0,
                  color: Color(0xFF9E9E9E))),
          const SizedBox(height: 4),
          TextFormField(
            controller: _sizeStockCtrl,
            maxLines: 3,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            decoration: const InputDecoration(
              hintText: '{"S": 10, "M": 5}',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: Colors.white),
                  )
                : Text(t.adminProductSaveBtn),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {bool required = false, int maxLines = 1, bool numeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        inputFormatters:
            numeric ? [FilteringTextInputFormatter.digitsOnly] : null,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? S.of(context)!.adminFieldRequired : null
            : null,
      ),
    );
  }
}
