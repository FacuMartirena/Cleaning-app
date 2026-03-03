import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/models/company_model.dart';
import 'package:bo_cleaning/modules/company_select/controllers/company_select_controller.dart';

class CompanySelectView extends GetView<CompanySelectController> {
  const CompanySelectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar empresa'),
        backgroundColor: Globals.primary,
        foregroundColor: Globals.white,
        actions: [
          TextButton.icon(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout, color: Globals.white, size: 20),
            label: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Globals.white),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage.value!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Globals.primary),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => controller.loadCompanies(),
                    style: FilledButton.styleFrom(
                      backgroundColor: Globals.primary,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }
        if (controller.companies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_outlined, size: 72, color: Globals.hint),
                const SizedBox(height: 16),
                Text(
                  'No hay empresas disponibles',
                  style: const TextStyle(
                    color: Globals.hint,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                Globals.primary.withValues(alpha: 0.12),
              ),
              columns: const [
                DataColumn(label: Text('Empresa')),
                DataColumn(label: Text('Acción')),
              ],
              rows: controller.companies
                  .map((c) => _buildRow(c, controller.selectCompany))
                  .toList(),
            ),
          ),
        );
      }),
    );
  }

  DataRow _buildRow(
    CompanyModel company,
    void Function(CompanyModel) onSelect,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            company.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          FilledButton.icon(
            onPressed: () => onSelect(company),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Seleccionar'),
            style: FilledButton.styleFrom(
              backgroundColor: Globals.primary,
            ),
          ),
        ),
      ],
    );
  }
}
