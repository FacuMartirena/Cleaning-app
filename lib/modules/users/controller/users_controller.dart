import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/models/company_model.dart';
import 'package:bo_cleaning/core/models/user_model.dart';
import 'package:bo_cleaning/modules/companies/services/companies_provider.dart';
import 'package:bo_cleaning/modules/users/services/users_provider.dart';

/// Roles permitidos (enum del backend).
const List<String> allowedRoles = [
  'Administrador',
  'Administrativo',
  'Limpiador',
];

class UsersController extends GetxController {
  final UsersProvider _provider = Get.find<UsersProvider>();
  final CompaniesProvider _companiesProvider = Get.find<CompaniesProvider>();

  final _allUsers = <UserModel>[];
  final users = <UserModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);

  final searchQuery = ''.obs;
  final searchController = TextEditingController();
  Worker? _searchWorker;

  // ── Companies ─────────────────────────────────────────────────────────────────
  final companies = <CompanyModel>[].obs;
  final isLoadingCompanies = false.obs;

  // ── Formulario de creación (Reactive Forms) ──────────────────────────────────
  late final FormGroup createUserForm;

  @override
  void onInit() {
    super.onInit();
    _searchWorker = debounce(
      searchQuery,
      (_) => _applyFilter(),
      time: const Duration(milliseconds: 800),
    );
    createUserForm = FormGroup({
      'firstName': FormControl<String>(validators: [Validators.required]),
      'lastName': FormControl<String>(validators: [Validators.required]),
      'email': FormControl<String>(
        validators: [Validators.required, Validators.email],
      ),
      'password': FormControl<String>(
        validators: [Validators.required, Validators.minLength(6)],
      ),
      'ci': FormControl<String>(validators: [Validators.required]),
      'role': FormControl<String>(
        value: 'Limpiador',
        validators: [Validators.required],
      ),
      'active': FormControl<bool>(value: true),
      'companyId': FormControl<String?>(),
    });
  }

  @override
  void onReady() {
    super.onReady();
    loadUsers();
    loadCompanies();
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    createUserForm.dispose();
    searchController.dispose();
    super.onClose();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query.trim().toLowerCase();
  }

  void _applyFilter() {
    final q = searchQuery.value;
    if (q.isEmpty) {
      users.value = List.from(_allUsers);
    } else {
      users.value = _allUsers.where((u) {
        return u.firstName.toLowerCase().contains(q) ||
            u.lastName.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.ci.toLowerCase().contains(q) ||
            u.role.toLowerCase().contains(q);
      }).toList();
    }
  }

  // ── Companies ─────────────────────────────────────────────────────────────────

  Future<void> loadCompanies() async {
    isLoadingCompanies.value = true;
    try {
      final response = await _companiesProvider.getCompanies();
      if (response.statusCode == 200) {
        final list = response.body as List<dynamic>?;
        companies.value =
            list
                ?.map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      }
    } catch (_) {
      // Non-critical
    } finally {
      isLoadingCompanies.value = false;
    }
  }

  Future<void> createCompanyAndSelect(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    try {
      final response = await _companiesProvider.createCompany({
        'name': trimmed,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body as Map<String, dynamic>?;
        if (body != null) {
          final company = CompanyModel.fromJson(body);
          companies.add(company);
          createUserForm.control('companyId').value = company.id;
          Get.snackbar(
            'Empresa creada',
            '"${company.name}" fue creada y asignada.',
            backgroundColor: Globals.success,
            colorText: Globals.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          response.body?['message']?.toString() ?? 'Error al crear empresa',
          backgroundColor: Globals.error,
          colorText: Globals.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'No se pudo conectar con el servidor',
        backgroundColor: Globals.error,
        colorText: Globals.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void showCreateCompanyDialog() {
    final nameCtrl = TextEditingController();
    void disposeAfterClose() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        nameCtrl.dispose();
      });
    }

    Get.dialog<void>(
      AlertDialog(
        title: const Text('Nueva empresa'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            hintText: 'Ej: Mi Empresa S.A.',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) {
            final text = nameCtrl.text;
            Get.back<void>();
            disposeAfterClose();
            createCompanyAndSelect(text);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back<void>();
              disposeAfterClose();
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final text = nameCtrl.text;
              Get.back<void>();
              disposeAfterClose();
              createCompanyAndSelect(text);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  // ── Users ─────────────────────────────────────────────────────────────────────

  Future<void> loadUsers() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _provider.getUsers();
      if (response.statusCode == 200) {
        final list = response.body as List<dynamic>?;
        _allUsers
          ..clear()
          ..addAll(
            list
                    ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
                    .toList() ??
                [],
          );
        _applyFilter();
      } else {
        errorMessage.value =
            response.body?['message']?.toString() ?? 'Error al cargar usuarios';
      }
    } catch (_) {
      errorMessage.value = 'No se pudo conectar con el servidor';
    } finally {
      isLoading.value = false;
    }
  }

  void _resetCreateForm() {
    createUserForm.reset(
      value: {
        'firstName': null,
        'lastName': null,
        'email': null,
        'password': null,
        'ci': null,
        'role': 'Limpiador',
        'active': true,
        'companyId': null,
      },
    );
  }

  Future<void> createUser() async {
    if (createUserForm.invalid) {
      createUserForm.markAllAsTouched();
      return;
    }

    final values = createUserForm.value;
    isLoading.value = true;
    try {
      final body = UserModel.createBody(
        firstName: values['firstName']?.toString().trim() ?? '',
        lastName: values['lastName']?.toString().trim() ?? '',
        email: values['email']?.toString().trim() ?? '',
        password: values['password']?.toString().trim() ?? '',
        ci: values['ci']?.toString().trim() ?? '',
        role: values['role']?.toString() ?? 'Limpiador',
        active: values['active'] as bool? ?? true,
        companyId: values['companyId'] as String?,
      );

      final response = await _provider.createUser(body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _resetCreateForm();
        Get.back<void>();
        loadUsers();
        Get.snackbar(
          'Usuario creado',
          'El usuario se creó correctamente.',
          backgroundColor: Globals.success,
          colorText: Globals.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          response.body?['message']?.toString() ?? 'Error al crear usuario',
          backgroundColor: Globals.error,
          colorText: Globals.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'No se pudo conectar con el servidor',
        backgroundColor: Globals.error,
        colorText: Globals.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void openCreateUserDialog() => _resetCreateForm();

  Future<void> toggleActive(UserModel user) async {
    final isActive = user.active;
    try {
      final response = isActive
          ? await _provider.deactivateUser(user.id)
          : await _provider.activateUser(user.id);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final updated = UserModel.fromJson({
          'id': user.id,
          'email': user.email,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'ci': user.ci,
          'role': user.role,
          'active': !isActive,
          if (user.companyId != null) 'companyId': user.companyId,
          if (user.company != null) 'company': user.company!.toJson(),
        });
        final allIdx = _allUsers.indexWhere((u) => u.id == user.id);
        if (allIdx != -1) _allUsers[allIdx] = updated;
        final idx = users.indexWhere((u) => u.id == user.id);
        if (idx != -1) users[idx] = updated;
        Get.snackbar(
          isActive ? 'Usuario desactivado' : 'Usuario activado',
          '${user.firstName} ${user.lastName} fue ${isActive ? 'desactivado' : 'activado'}.',
          backgroundColor: isActive ? Globals.error : Globals.success,
          colorText: Globals.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          response.body?['message']?.toString() ??
              'No se pudo actualizar el estado',
          backgroundColor: Globals.error,
          colorText: Globals.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'No se pudo conectar con el servidor',
        backgroundColor: Globals.error,
        colorText: Globals.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
