import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../l10n/app_localizations.dart';
import '../../products/presentation/providers/admin_products_providers.dart';

class AdminProductCreateScreen extends ConsumerStatefulWidget {
  const AdminProductCreateScreen({super.key});

  @override
  ConsumerState<AdminProductCreateScreen> createState() =>
      _AdminProductCreateScreenState();
}

class _AdminProductCreateScreenState
    extends ConsumerState<AdminProductCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  final _nameEsCtrl = TextEditingController();
  final _nameEnCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _descEsCtrl = TextEditingController();
  final _descEnCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _categoryCtrl = TextEditingController();
  final _imagesCtrl = TextEditingController();
  bool _isActive = true;
  bool _isFlash = false;
  bool _useSizes = true;
  final Set<String> _selectedSizes = {};
  final Map<String, TextEditingController> _sizeStockControllers = {};
  
  static const List<String> _availableSizes = ['XS', 'S', 'M', 'L', 'XL'];

  @override
  void dispose() {
    _nameEsCtrl.dispose();
    _nameEnCtrl.dispose();
    _slugCtrl.dispose();
    _descEsCtrl.dispose();
    _descEnCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _categoryCtrl.dispose();
    _imagesCtrl.dispose();
    for (final ctrl in _sizeStockControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _toggleSize(String size) {
    setState(() {
      if (_selectedSizes.contains(size)) {
        _selectedSizes.remove(size);
        _sizeStockControllers[size]?.dispose();
        _sizeStockControllers.remove(size);
      } else {
        _selectedSizes.add(size);
        _sizeStockControllers[size] = TextEditingController(text: '0');
      }
    });
  }

  int _calculateTotalStock() {
    if (!_useSizes) {
      return int.tryParse(_stockCtrl.text) ?? 0;
    }
    int total = 0;
    for (final ctrl in _sizeStockControllers.values) {
      total += int.tryParse(ctrl.text) ?? 0;
    }
    return total;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Validaciones adicionales
    final nameEs = _nameEsCtrl.text.trim();
    if (nameEs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre en español es obligatorio')),
      );
      return;
    }

    final priceCents = int.tryParse(_priceCtrl.text);
    if (priceCents == null || priceCents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El precio debe ser mayor a 0')),
      );
      return;
    }

    if (_useSizes && _selectedSizes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una talla')),
      );
      return;
    }

    if (_useSizes) {
      for (final size in _selectedSizes) {
        final stock = int.tryParse(_sizeStockControllers[size]?.text ?? '0');
        if (stock == null || stock < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Stock inválido para talla $size')),
          );
          return;
        }
      }
    } else {
      final stock = int.tryParse(_stockCtrl.text);
      if (stock == null || stock < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El stock debe ser mayor o igual a 0')),
        );
        return;
      }
    }

    setState(() => _saving = true);

    final images = _imagesCtrl.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final List<String> sizes;
    final Map<String, int> sizeStock;
    final int totalStock;

    if (_useSizes) {
      sizes = _selectedSizes.toList()..sort();
      sizeStock = {};
      for (final size in _selectedSizes) {
        sizeStock[size] = int.tryParse(_sizeStockControllers[size]?.text ?? '0') ?? 0;
      }
      totalStock = _calculateTotalStock();
    } else {
      sizes = [];
      sizeStock = {};
      totalStock = int.tryParse(_stockCtrl.text) ?? 0;
    }

    final data = {
      'id': const Uuid().v4(),
      'name': nameEs,
      'name_es': nameEs,
      'name_en': _nameEnCtrl.text.trim().isEmpty ? null : _nameEnCtrl.text.trim(),
      'slug': _slugCtrl.text.trim(),
      'description': _descEsCtrl.text.trim().isEmpty ? null : _descEsCtrl.text.trim(),
      'description_es': _descEsCtrl.text.trim().isEmpty ? null : _descEsCtrl.text.trim(),
      'description_en': _descEnCtrl.text.trim().isEmpty ? null : _descEnCtrl.text.trim(),
      'price_cents': priceCents,
      'stock': totalStock,
      'category_id': _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
      'is_active': _isActive,
      'is_flash': _isFlash,
      'images': images,
      'sizes': sizes,
      'size_stock': sizeStock,
      'product_type': 'simple',
    };

    try {
      await ref.read(adminProductsDatasourceProvider).upsertProduct(data);
      ref.invalidate(adminProductsListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context)!.adminProductCreated)),
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

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.adminProductNewTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.go('/admin-panel/productos'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            _field(t.adminFieldNameEs, _nameEsCtrl, required: true),
            _field(t.adminFieldNameEn, _nameEnCtrl),
            _field(t.adminFieldSlug, _slugCtrl, required: true),
            _field(t.adminFieldDescEs, _descEsCtrl, maxLines: 3),
            _field(t.adminFieldDescEn, _descEnCtrl, maxLines: 3),
            _field(t.adminFieldPrice, _priceCtrl, required: true, numeric: true),
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
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Usar tallas',
                  style: TextStyle(fontSize: 13, letterSpacing: 0.5)),
              value: _useSizes,
              activeTrackColor: const Color(0xFF111111),
              onChanged: (v) => setState(() => _useSizes = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            if (_useSizes) ..._buildSizesSection() else _buildManualStockField(),
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
                  : Text(t.adminProductCreateBtn),
            ),
            const SizedBox(height: 32),
          ],
        ),
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

  List<Widget> _buildSizesSection() {
    return [
      const Text(
        'TALLAS DISPONIBLES',
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 1.0,
          color: Color(0xFF9E9E9E),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _availableSizes.map((size) {
          final isSelected = _selectedSizes.contains(size);
          return FilterChip(
            label: Text(size),
            selected: isSelected,
            onSelected: (_) => _toggleSize(size),
            selectedColor: const Color(0xFF111111),
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 16),
      if (_selectedSizes.isNotEmpty) ..._buildSizeStockInputs(),
      if (_selectedSizes.isNotEmpty) ..._buildTotalStockDisplay(),
    ];
  }

  List<Widget> _buildSizeStockInputs() {
    final sortedSizes = _selectedSizes.toList()..sort();
    return [
      const Text(
        'STOCK POR TALLA',
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 1.0,
          color: Color(0xFF9E9E9E),
        ),
      ),
      const SizedBox(height: 8),
      ...sortedSizes.map((size) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  size,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _sizeStockControllers[size],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => _toggleSize(size),
                color: Colors.red.shade400,
              ),
            ],
          ),
        );
      }).toList(),
    ];
  }

  List<Widget> _buildTotalStockDisplay() {
    return [
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Stock total (automático)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_calculateTotalStock()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111111),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
    ];
  }

  Widget _buildManualStockField() {
    return _field('Stock', _stockCtrl, required: true, numeric: true);
  }
}
