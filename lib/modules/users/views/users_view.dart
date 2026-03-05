import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/models/user_model.dart';
import 'package:bo_cleaning/core/widgets/app_drawer.dart';
import 'package:bo_cleaning/modules/users/controller/users_controller.dart';

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios y roles'),
        backgroundColor: Globals.primary,
        foregroundColor: Globals.white,
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateUserBottomSheet,
        backgroundColor: Globals.primary,
        foregroundColor: Globals.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Crear usuario'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, email o CI',
                hintStyle: const TextStyle(color: Globals.hint, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Globals.hint),
                suffixIcon: Obx(
                  () => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Globals.hint),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.onSearchChanged('');
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                filled: true,
                fillColor: Globals.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Globals.hint),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Globals.hint),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Globals.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
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
                          onPressed: () => controller.loadUsers(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (controller.users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 72, color: Globals.hint),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.value.isNotEmpty
                            ? 'Sin resultados para "${controller.searchQuery.value}"'
                            : 'No hay usuarios',
                        style: const TextStyle(
                          color: Globals.hint,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.users.length,
                itemBuilder: (context, index) => _UserTile(
                  user: controller.users[index],
                  onToggle: controller.canDeactivateUser(controller.users[index])
                      ? () => controller.toggleActive(controller.users[index])
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showCreateUserBottomSheet() {
    controller.openCreateUserDialog();
    // ── Adaptive: smaller initial size on wider screens ───────────────────────
    final isWide = Get.width >= 600;
    Get.bottomSheet<void>(
      DraggableScrollableSheet(
        initialChildSize: isWide ? 0.7 : 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Globals.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ReactiveForm(
            formGroup: controller.createUserForm,
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
                  'Crear usuario',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Globals.primary,
                  ),
                ),
                const SizedBox(height: 24),
                _labeledField(
                  'Nombre',
                  ReactiveTextField<String>(
                    formControlName: 'firstName',
                    decoration: _inputDecoration('Ej: María'),
                    textInputAction: TextInputAction.next,
                    validationMessages: {
                      ValidationMessage.required: (_) => 'Campo requerido',
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _labeledField(
                  'Apellido',
                  ReactiveTextField<String>(
                    formControlName: 'lastName',
                    decoration: _inputDecoration('Ej: García'),
                    textInputAction: TextInputAction.next,
                    validationMessages: {
                      ValidationMessage.required: (_) => 'Campo requerido',
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _labeledField(
                  'Email',
                  ReactiveTextField<String>(
                    formControlName: 'email',
                    decoration: _inputDecoration('email@ejemplo.com'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validationMessages: {
                      ValidationMessage.required: (_) => 'Campo requerido',
                      ValidationMessage.email: (_) => 'Email inválido',
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _labeledField(
                  'Contraseña',
                  ReactiveTextField<String>(
                    formControlName: 'password',
                    decoration: _inputDecoration('••••••••'),
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validationMessages: {
                      ValidationMessage.required: (_) => 'Campo requerido',
                      ValidationMessage.minLength: (_) => 'Mínimo 6 caracteres',
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _labeledField(
                  'Cédula (CI)',
                  ReactiveTextField<String>(
                    formControlName: 'ci',
                    decoration: _inputDecoration('Ej: 12345678'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validationMessages: {
                      ValidationMessage.required: (_) => 'Campo requerido',
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _labeledField(
                  'Rol',
                  ReactiveDropdownField<String>(
                    formControlName: 'role',
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Globals.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    items: controller.availableRoles
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                // ── Company (optional) — + empresa above dropdown ────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Empresa',
                      style: TextStyle(
                        color: Globals.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: controller.showCreateCompanyDialog,
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: Globals.primary,
                      ),
                      label: const Text(
                        'Agregar empresa',
                        style: TextStyle(
                          color: Globals.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(
                  () => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: controller.isLoadingCompanies.value
                        ? Container(
                            key: const ValueKey('loading'),
                            height: 52,
                            decoration: BoxDecoration(
                              border: Border.all(color: Globals.hint),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Globals.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        : ReactiveDropdownField<String?>(
                            key: const ValueKey('dropdown'),
                            formControlName: 'companyId',
                            decoration: _inputDecoration(
                              null,
                            ).copyWith(hintText: 'Sin empresa'),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text(
                                  'Sin empresa',
                                  style: TextStyle(color: Globals.hint),
                                ),
                              ),
                              ...controller.companies.map(
                                (c) => DropdownMenuItem<String?>(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                ReactiveSwitchListTile(
                  formControlName: 'active',
                  title: const Text('Activo'),
                  activeColor: Globals.primary,
                ),
                const SizedBox(height: 24),
                Obx(
                  () => FilledButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.createUser,
                    style: FilledButton.styleFrom(
                      backgroundColor: Globals.primary,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Globals.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Crear usuario'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Globals.transparent,
    );
  }

  InputDecoration _inputDecoration(String? hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Globals.hint, fontSize: 14),
    filled: true,
    fillColor: Globals.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Globals.hint),
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

// ── User tile ─────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, this.onToggle});

  final UserModel user;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Globals.primary.withValues(alpha: 0.2),
              child: Icon(Icons.person, color: Globals.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 12, color: Globals.hint),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: [
                      _RoleChip(role: user.role),
                      if (user.company != null)
                        _CompanyChip(name: user.company!.name),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: user.active,
              onChanged: onToggle != null ? (_) => onToggle!() : null,
              activeColor: Globals.primary,
              inactiveThumbColor: Globals.hint,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Role chip with 3-role color coding ───────────────────────────────────────

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});

  final String role;

  Color get _color {
    switch (role) {
      case 'Administrador':
        return Globals.primary;
      case 'Administrativo':
        return Globals.pending;
      default:
        return Globals.hint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Company chip ──────────────────────────────────────────────────────────────

class _CompanyChip extends StatelessWidget {
  const _CompanyChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.business_outlined, size: 11, color: Globals.hint),
        const SizedBox(width: 3),
        Text(name, style: const TextStyle(fontSize: 11, color: Globals.hint)),
      ],
    );
  }
}
