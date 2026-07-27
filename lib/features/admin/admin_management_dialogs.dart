import 'package:flutter/material.dart';

import '../../models/user_role.dart';
import 'admin_management_service.dart';

const _categoryIcons = <String, String>{
  'cleaning': 'Cleaning',
  'plumbing': 'Plumbing',
  'electrical': 'Electrical',
  'painting': 'Painting',
  'home_repair': 'Home repair',
};

Future<void> showAddManagedUserDialog({
  required BuildContext context,
  required UserRole role,
  required VoidCallback onCreated,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _AddManagedUserDialog(role: role, onCreated: onCreated),
  );
}

Future<void> showAddServiceCategoryDialog({
  required BuildContext context,
  required VoidCallback onCreated,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _AddServiceCategoryDialog(onCreated: onCreated),
  );
}

class _AddManagedUserDialog extends StatefulWidget {
  const _AddManagedUserDialog({required this.role, required this.onCreated});

  final UserRole role;
  final VoidCallback onCreated;

  @override
  State<_AddManagedUserDialog> createState() => _AddManagedUserDialogState();
}

class _AddManagedUserDialogState extends State<_AddManagedUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();
  var _saving = false;
  String? _error;

  bool get _isProvider => widget.role == UserRole.provider;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await AdminManagementService.instance.createManagedUser(
        ManagedUserInput(
          name: _nameController.text,
          email: _emailController.text,
          role: widget.role,
          category: _isProvider ? _categoryController.text : null,
          location: _isProvider ? _locationController.text : null,
          experience: _isProvider ? _experienceController.text : null,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onCreated();
      final label = _isProvider ? 'Provider' : 'Customer';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.passwordSetupEmailSent
                ? '$label added. A password setup email was sent.'
                : '$label added, but the password setup email could not be sent.',
          ),
        ),
      );
    } on AdminManagementException catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = error.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _isProvider ? 'provider' : 'customer';
    return AlertDialog(
      title: Text('Add $label'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Creates the account and sends a secure password setup email.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _nameController,
                  enabled: !_saving,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  enabled: !_saving,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    final required = _required(value);
                    if (required != null) return required;
                    return value!.contains('@')
                        ? null
                        : 'Enter a valid email address.';
                  },
                ),
                if (_isProvider) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _categoryController,
                    enabled: !_saving,
                    decoration: const InputDecoration(
                      labelText: 'Service category',
                      hintText: 'e.g. Cleaning',
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationController,
                    enabled: !_saving,
                    decoration: const InputDecoration(
                      labelText: 'Service area',
                      hintText: 'e.g. Cape Town',
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _experienceController,
                    enabled: !_saving,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Years of experience',
                    ),
                    validator: _required,
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child:
              _saving
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text('Add $label'),
        ),
      ],
    );
  }
}

class _AddServiceCategoryDialog extends StatefulWidget {
  const _AddServiceCategoryDialog({required this.onCreated});

  final VoidCallback onCreated;

  @override
  State<_AddServiceCategoryDialog> createState() =>
      _AddServiceCategoryDialogState();
}

class _AddServiceCategoryDialogState extends State<_AddServiceCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  var _iconKey = _categoryIcons.keys.first;
  var _active = true;
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await AdminManagementService.instance.createServiceCategory(
        ServiceCategoryInput(
          name: _nameController.text,
          iconKey: _iconKey,
          active: _active,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onCreated();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Service category added.')));
    } on AdminManagementException catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = error.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add service category'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Category name'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _iconKey,
                decoration: const InputDecoration(labelText: 'Icon'),
                items: [
                  for (final entry in _categoryIcons.entries)
                    DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                ],
                onChanged:
                    _saving
                        ? null
                        : (value) => setState(() => _iconKey = value!),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active for customer booking'),
                value: _active,
                onChanged:
                    _saving ? null : (value) => setState(() => _active = value),
              ),
              if (_error != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child:
              _saving
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Add category'),
        ),
      ],
    );
  }
}

String? _required(String? value) {
  return value == null || value.trim().isEmpty
      ? 'This field is required.'
      : null;
}
