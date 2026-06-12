import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/widgets/primary_button.dart';
import 'package:mobile/features/admin/models/level_model.dart';
import 'package:mobile/core/validators/level_validator.dart';
import 'package:mobile/core/exceptions/app_exception.dart';
import 'package:mobile/core/utils/toast_util.dart';

class LevelCrudDialog extends StatefulWidget {
  final LevelModel? initialData;
  final Future<void> Function(Map<String, dynamic> data) onSubmit;

  const LevelCrudDialog({super.key, this.initialData, required this.onSubmit});

  @override
  State<LevelCrudDialog> createState() => _LevelCrudDialogState();
}

class _LevelCrudDialogState extends State<LevelCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _orderController;
  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameController = TextEditingController(text: data?.name ?? '');
    _descController = TextEditingController(text: data?.description ?? '');
    _orderController = TextEditingController(
      text: data?.orderIndex.toString() ?? '',
    );
    _isActive = data?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      try {
        final isEdit = widget.initialData != null;
        await widget.onSubmit({
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
          'orderIndex': int.parse(_orderController.text.trim()),
          'isActive': _isActive,
        });
        if (mounted) {
          Navigator.of(context).pop();
          ToastUtil.showSnackBar(
            context,
            isEdit ? 'Cập nhật Level thành công!' : 'Tạo Level thành công!',
          );
        }
      } catch (e) {
        if (mounted) {
          final errorMessage = e is AppException
              ? e.message
              : 'Đã xảy ra lỗi: $e';
          ToastUtil.showSnackBar(context, errorMessage, isError: true);
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialData != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Update Level' : 'Create New Level',
                style: AppTextStyles.h2.copyWith(color: AppColors.brandDark),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (e.g. N5 - Beginner)',
                  border: OutlineInputBorder(),
                ),
                validator: LevelValidator.validateName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _orderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Thứ tự hiển thị (VD: 1)',
                  border: OutlineInputBorder(),
                ),
                validator: LevelValidator.validateOrderIndex,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Active'),
                value: _isActive,
                activeTrackColor: AppColors.brandDark,
                onChanged: (val) {
                  setState(() {
                    _isActive = val;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(
                      'Hủy',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 140,
                    child: PrimaryButton(
                      text: isEdit ? 'Lưu' : 'Tạo cấp độ',
                      onPressed: _submit,
                      isLoading: _isSubmitting,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
