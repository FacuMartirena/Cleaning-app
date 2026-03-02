import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/modules/products/controllers/products_controller.dart';

class AddProductSheet extends StatelessWidget {
  const AddProductSheet({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProductsController>();

    return ReactiveForm(
      formGroup: ctrl.createProductForm,
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Globals.hint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Agregar producto',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Globals.primary,
            ),
          ),
          const SizedBox(height: 24),
          _labeledField(
            'Nombre *',
            ReactiveTextField<String>(
              formControlName: 'name',
              decoration: _inputDecoration('Ej: Detergente en polvo'),
              textInputAction: TextInputAction.next,
              validationMessages: {
                ValidationMessage.required: (_) => 'Campo requerido',
              },
            ),
          ),
          const SizedBox(height: 16),
          _labeledField(
            'Presentación *',
            ReactiveTextField<String>(
              formControlName: 'unitOfMeasure',
              decoration: _inputDecoration('Ej: 500g, 1L, unidad'),
              textInputAction: TextInputAction.next,
              validationMessages: {
                ValidationMessage.required: (_) => 'Campo requerido',
              },
            ),
          ),
          const SizedBox(height: 16),
          _labeledField(
            'Cantidad disponible *',
            ReactiveTextField<String>(
              formControlName: 'quantityAvailable',
              decoration: _inputDecoration('Ej: 100'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validationMessages: {
                ValidationMessage.required: (_) => 'Campo requerido',
                ValidationMessage.pattern: (_) => 'Ingresa un número válido',
              },
            ),
          ),
          const SizedBox(height: 16),
          _labeledField(
            'Descripción',
            ReactiveTextField<String>(
              formControlName: 'description',
              decoration: _inputDecoration('Descripción opcional...'),
              maxLines: 3,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 16),
          ReactiveSwitchListTile(
            formControlName: 'active',
            title: const Text('Activo'),
            activeColor: Globals.primary,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          const Text(
            'Imagen',
            style: TextStyle(
              color: Globals.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final file = ctrl.pickedImage.value;
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      file?.name ?? 'Seleccionar imagen',
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: ctrl.pickImage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Globals.primary,
                      side: BorderSide(
                        color: file != null ? Globals.primary : Globals.hint,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                if (file != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear, color: Globals.hint),
                    onPressed: ctrl.clearImage,
                  ),
                ],
              ],
            );
          }),
          const SizedBox(height: 8),
          const Text(
            'Formatos: jpeg, jpg, png, gif, webp · Máx. 5 MB',
            style: TextStyle(fontSize: 11, color: Globals.hint),
          ),
          const SizedBox(height: 24),
          Obx(
            () => FilledButton(
              onPressed:
                  ctrl.isCreating.value ? null : ctrl.submitCreateProduct,
              style: FilledButton.styleFrom(
                backgroundColor: Globals.primary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: ctrl.isCreating.value
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Globals.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Crear producto'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Globals.hint, fontSize: 14),
        filled: true,
        fillColor: Globals.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Globals.hint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Globals.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Globals.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Globals.error, width: 1.5),
        ),
      );

  Widget _labeledField(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Globals.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      );
}
