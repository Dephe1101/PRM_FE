import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/toast_util.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/widgets/primary_button.dart';
import 'package:mobile/features/admin/models/level_model.dart';
import 'package:mobile/features/admin/models/topic_model.dart';
import 'package:mobile/core/validators/topic_validator.dart';
import 'package:mobile/core/exceptions/app_exception.dart';

class TopicCrudDialog extends StatefulWidget {
  final TopicModel? initialData;
  final String? selectedLevelId;
  final List<LevelModel> levels;
  final Future<void> Function(Map<String, dynamic> data) onSubmit;

  const TopicCrudDialog({
    super.key,
    this.initialData,
    this.selectedLevelId,
    required this.levels,
    required this.onSubmit,
  });

  @override
  State<TopicCrudDialog> createState() => _TopicCrudDialogState();
}

class _TopicCrudDialogState extends State<TopicCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _orderController;
  String? _currentLevelId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _titleController = TextEditingController(text: data?.title ?? '');
    _orderController = TextEditingController(
      text: data?.orderIndex.toString() ?? '',
    );

    if (data != null) {
      _currentLevelId = data.levelId;
    } else {
      _currentLevelId =
          widget.selectedLevelId ??
          (widget.levels.isNotEmpty ? widget.levels.first.id : null);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentLevelId == null) {
      ToastUtil.showSnackBar(
        context,
        'Vui lòng tạo ít nhất 1 cấp độ trước',
        isError: true,
      );
      return;
    }

    final payload = <String, dynamic>{
      'title': _titleController.text.trim(),
      'levelId': _currentLevelId,
    };

    final orderText = _orderController.text.trim();
    if (orderText.isNotEmpty) {
      payload['orderIndex'] = int.parse(orderText);
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final isEdit = widget.initialData != null;
      await widget.onSubmit(payload);
      if (mounted) {
        Navigator.of(context).pop();
        ToastUtil.showSnackBar(
          context,
          isEdit ? 'Cập nhật Topic thành công!' : 'Tạo Topic thành công!',
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
                isEdit ? 'Update Topic' : 'Create New Topic',
                style: AppTextStyles.h2.copyWith(color: AppColors.brandDark),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _currentLevelId,
                decoration: const InputDecoration(
                  labelText: 'Level',
                  border: OutlineInputBorder(),
                ),
                items: widget.levels.map((level) {
                  return DropdownMenuItem(
                    value: level.id,
                    child: Text(level.name),
                  );
                }).toList(),
                onChanged: isEdit
                    ? null
                    : (val) {
                        setState(() {
                          _currentLevelId = val;
                        });
                      },
                validator: TopicValidator.validateLevel,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title (e.g. Bài 1: Chào hỏi)',
                  border: OutlineInputBorder(),
                ),
                validator: TopicValidator.validateTitle,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _orderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Thứ tự hiển thị (Tuỳ chọn)',
                  border: OutlineInputBorder(),
                ),
                validator: TopicValidator.validateOrderIndex,
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
                      text: isEdit ? 'Lưu' : 'Tạo chủ đề',
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
