import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/utils/toast_util.dart';
import 'package:mobile/features/admin/models/word_model.dart';
import 'package:mobile/core/exceptions/app_exception.dart';
import 'package:mobile/core/validators/word_validator.dart';
import 'package:mobile/core/widgets/primary_button.dart';

class WordCrudDialog extends StatefulWidget {
  final WordModel? initialData;
  final List<dynamic>? topics;
  final List<dynamic>? levels;
  final String? defaultTopicId;
  final Future<void> Function(Map<String, dynamic> data) onSubmit;

  const WordCrudDialog({
    super.key,
    this.initialData,
    this.topics,
    this.levels,
    this.defaultTopicId,
    required this.onSubmit,
  });

  @override
  State<WordCrudDialog> createState() => _WordCrudDialogState();
}

class _WordCrudDialogState extends State<WordCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  String _topicId = '';
  String _levelId = '';
  late TextEditingController _kanjiController;
  late TextEditingController _hiraganaController;
  late TextEditingController _romajiController;
  late TextEditingController _meaningController;
  late TextEditingController _exampleController;
  late TextEditingController _audioUrlController;

  @override
  void initState() {
    super.initState();
    _topicId = widget.initialData?.topicId ?? widget.defaultTopicId ?? '';

    // Set _levelId based on _topicId if possible
    if (_topicId.isNotEmpty && widget.topics != null) {
      final topic = widget.topics!.cast<dynamic>().firstWhere(
        (t) => t.id == _topicId,
        orElse: () => null,
      );
      if (topic != null) {
        _levelId = topic.levelId;
      }
    }

    if (widget.levels != null &&
        widget.levels!.isNotEmpty &&
        _levelId.isEmpty) {
      _levelId = widget.levels!.first.id;
    }

    if (widget.topics != null &&
        widget.topics!.isNotEmpty &&
        _topicId.isEmpty) {
      final filteredTopics = widget.topics!
          .cast<dynamic>()
          .where((t) => t.levelId == _levelId)
          .toList();
      if (filteredTopics.isNotEmpty) {
        _topicId = filteredTopics.first.id;
      }
    }

    _kanjiController = TextEditingController(
      text: widget.initialData?.kanji ?? '',
    );
    _hiraganaController = TextEditingController(
      text: widget.initialData?.hiragana ?? '',
    );
    _romajiController = TextEditingController(
      text: widget.initialData?.romaji ?? '',
    );
    _meaningController = TextEditingController(
      text: widget.initialData?.meaning ?? '',
    );
    _exampleController = TextEditingController(
      text: widget.initialData?.example ?? '',
    );
    _audioUrlController = TextEditingController(
      text: widget.initialData?.audioUrl ?? '',
    );
  }

  @override
  void dispose() {
    _kanjiController.dispose();
    _hiraganaController.dispose();
    _romajiController.dispose();
    _meaningController.dispose();
    _exampleController.dispose();
    _audioUrlController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Check topic manually as well since DropdownButtonFormField validator might not fire if not touched
    final topicError = WordValidator.validateTopic(_topicId);
    if (topicError != null) {
      ToastUtil.showSnackBar(context, topicError, isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final isEdit = widget.initialData != null;
      await widget.onSubmit({
        'topicId': _topicId,
        'kanji': _kanjiController.text.trim(),
        'hiragana': _hiraganaController.text.trim(),
        'romaji': _romajiController.text.trim(),
        'meaning': _meaningController.text.trim(),
        'example': _exampleController.text.trim(),
        'audioUrl': _audioUrlController.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context);
        ToastUtil.showSnackBar(
          context,
          isEdit ? 'Cập nhật Từ vựng thành công!' : 'Tạo Từ vựng thành công!',
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
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialData != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Cập nhật từ vựng' : 'Thêm từ vựng mới',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.brandDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Level ID
                if (widget.levels != null && widget.levels!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      isEditing
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.levels!
                                    .cast<dynamic>()
                                    .firstWhere(
                                      (l) => l.id == _levelId,
                                      orElse: () => widget.levels!.first,
                                    )
                                    .name,
                                style: AppTextStyles.bodyText.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : DropdownButtonFormField<String>(
                              key: ValueKey(_levelId),
                              initialValue: _levelId.isNotEmpty
                                  ? _levelId
                                  : null,
                              isExpanded: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              items: widget.levels!.map((l) {
                                return DropdownMenuItem<String>(
                                  value: l.id,
                                  child: Text(l.name),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _levelId = val;
                                    // Reset topic to the first of the new level
                                    final filtered = widget.topics!
                                        .cast<dynamic>()
                                        .where((t) => t.levelId == _levelId)
                                        .toList();
                                    if (filtered.isNotEmpty) {
                                      _topicId = filtered.first.id;
                                    } else {
                                      _topicId = '';
                                    }
                                  });
                                }
                              },
                            ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Topic ID
                if (widget.topics != null && widget.topics!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Topic',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      isEditing
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.topics!
                                    .cast<dynamic>()
                                    .firstWhere(
                                      (t) => t.id == _topicId,
                                      orElse: () => widget.topics!.first,
                                    )
                                    .title,
                                style: AppTextStyles.bodyText.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : () {
                              final filteredTopics = widget.topics!
                                  .cast<dynamic>()
                                  .where((t) => t.levelId == _levelId)
                                  .toList();

                              return DropdownButtonFormField<String>(
                                key: ValueKey(_topicId),
                                initialValue:
                                    _topicId.isNotEmpty &&
                                        filteredTopics.any(
                                          (t) => t.id == _topicId,
                                        )
                                    ? _topicId
                                    : null,
                                isExpanded: true,
                                itemHeight: null,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                selectedItemBuilder: (context) {
                                  return filteredTopics.map((t) {
                                    return Text(
                                      t.title,
                                      softWrap: true,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  }).toList();
                                },
                                items: filteredTopics.map((t) {
                                  return DropdownMenuItem<String>(
                                    value: t.id,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Text(t.title, softWrap: true),
                                    ),
                                  );
                                }).toList(),
                                validator: WordValidator.validateTopic,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _topicId = val);
                                  }
                                },
                              );
                            }(),
                      const SizedBox(height: 16),
                    ],
                  ),

                _buildTextField('Kanji (tùy chọn)', _kanjiController),
                const SizedBox(height: 16),
                _buildTextField(
                  'Hiragana (*)',
                  _hiraganaController,
                  validator: WordValidator.validateHiragana,
                ),
                const SizedBox(height: 16),
                _buildTextField('Romaji (tùy chọn)', _romajiController),
                const SizedBox(height: 16),
                _buildTextField(
                  'Meaning (*)',
                  _meaningController,
                  validator: WordValidator.validateMeaning,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Example (tùy chọn)',
                  _exampleController,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Audio URL (tùy chọn)',
                  _audioUrlController,
                  validator: WordValidator.validateAudioUrl,
                ),
                const SizedBox(height: 32),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      child: Text(
                        'Hủy',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 140,
                      child: PrimaryButton(
                        text: isEditing ? 'Lưu' : 'Tạo mới',
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
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
