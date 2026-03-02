import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/models/product_model.dart';
import 'package:bo_cleaning/core/services/auth_service.dart';
import 'package:bo_cleaning/modules/products/services/products_provider.dart';

class ProductsController extends GetxController {
  final ProductsProvider _provider = Get.find<ProductsProvider>();

  // ── List state ───────────────────────────────────────────────────────────────

  static const int _pageSize = 10;
  int _offset = 0;

  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = Rx<String?>(null);
  final _allProducts = <ProductModel>[];
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  final productAssetMap = <String, String>{
    'Detergent': 'assets/images/products/detergente.jpg',
  };

  String? getAssetPathForProduct(ProductModel product) =>
      product.assetImagePath ??
      productAssetMap[product.id] ??
      productAssetMap[product.name];

  // ── Create product state ─────────────────────────────────────────────────────

  late final FormGroup createProductForm;
  final pickedImage = Rx<PlatformFile?>(null);
  final isCreating = false.obs;

  bool get isAdmin => Get.find<AuthService>().isAdmin;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    createProductForm = FormGroup({
      'name': FormControl<String>(validators: [Validators.required]),
      'unitOfMeasure': FormControl<String>(validators: [Validators.required]),
      'quantityAvailable': FormControl<String>(
        validators: [
          Validators.required,
          Validators.pattern(r'^[0-9]+(\.[0-9]+)?$'),
        ],
      ),
      'description': FormControl<String>(),
      'active': FormControl<bool>(value: true),
    });
  }

  @override
  void onReady() {
    super.onReady();
    loadProducts();
  }

  @override
  void onClose() {
    searchController.dispose();
    createProductForm.dispose();
    super.onClose();
  }

  // ── Search ───────────────────────────────────────────────────────────────────

  void onSearchChanged(String query) {
    searchQuery.value = query.trim().toLowerCase();
    _applyFilter();
  }

  void _applyFilter() {
    final q = searchQuery.value;
    if (q.isEmpty) {
      products.value = List.from(_allProducts);
    } else {
      products.value = _allProducts.where((p) {
        return p.name.toLowerCase().contains(q) ||
            (p.description?.toLowerCase().contains(q) ?? false) ||
            p.unitOfMeasure.toLowerCase().contains(q);
      }).toList();
    }
  }

  // ── Load products ────────────────────────────────────────────────────────────

  Future<void> loadProducts() async {
    _offset = 0;
    hasMore.value = true;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _provider.getProducts(
        limit: _pageSize,
        offset: 0,
      );
      if (response.statusCode == 200) {
        final list = response.body as List<dynamic>?;
        final loaded =
            list
                ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        _allProducts
          ..clear()
          ..addAll(loaded);
        _applyFilter();
        if (loaded.length < _pageSize) hasMore.value = false;
        _offset = loaded.length;
      } else {
        errorMessage.value =
            response.body?['message']?.toString() ??
            'Error al cargar productos';
      }
    } catch (_) {
      errorMessage.value = 'No se pudo conectar con el servidor';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) return;
    isLoadingMore.value = true;
    try {
      final response = await _provider.getProducts(
        limit: _pageSize,
        offset: _offset,
      );
      if (response.statusCode == 200) {
        final list = response.body as List<dynamic>?;
        final loaded =
            list
                ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        _allProducts.addAll(loaded);
        _applyFilter();
        if (loaded.length < _pageSize) hasMore.value = false;
        _offset += loaded.length;
      }
    } catch (_) {
      // silent — la lista existente se mantiene
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ── Create product ───────────────────────────────────────────────────────────

  void openCreateProductSheet() => _resetCreateForm();

  void _resetCreateForm() {
    createProductForm.reset(value: {
      'name': null,
      'unitOfMeasure': null,
      'quantityAvailable': null,
      'description': null,
      'active': true,
    });
    pickedImage.value = null;
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpeg', 'jpg', 'png', 'gif', 'webp'],
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.size > 5 * 1024 * 1024) {
      Get.snackbar(
        'Imagen muy grande',
        'El tamaño máximo permitido es 5 MB.',
        backgroundColor: Globals.error,
        colorText: Globals.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    pickedImage.value = file;
  }

  void clearImage() => pickedImage.value = null;

  Future<void> submitCreateProduct() async {
    if (createProductForm.invalid) {
      createProductForm.markAllAsTouched();
      return;
    }

    final values = createProductForm.value;
    isCreating.value = true;
    try {
      final formData = FormData({
        'name': values['name']?.toString().trim() ?? '',
        'unitOfMeasure': values['unitOfMeasure']?.toString().trim() ?? '',
        'quantityAvailable':
            values['quantityAvailable']?.toString().trim() ?? '',
        if ((values['description'] as String?)?.trim().isNotEmpty == true)
          'description': values['description']?.toString().trim(),
        'active': (values['active'] as bool? ?? true).toString(),
      });

      final file = pickedImage.value;
      if (file != null && file.bytes != null) {
        formData.files.add(
          MapEntry(
            'image',
            MultipartFile(
              file.bytes!,
              filename: file.name,
              contentType: _contentType(file.extension),
            ),
          ),
        );
      }

      final response = await _provider.createProduct(formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back<void>();
        loadProducts();
        Get.snackbar(
          'Producto creado',
          'El producto fue creado exitosamente.',
          backgroundColor: Globals.success,
          colorText: Globals.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          response.body?['message']?.toString() ?? 'Error al crear el producto',
          backgroundColor: Globals.error,
          colorText: Globals.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error de conexión',
        'No se pudo conectar con el servidor.',
        backgroundColor: Globals.error,
        colorText: Globals.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCreating.value = false;
    }
  }

  String _contentType(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
