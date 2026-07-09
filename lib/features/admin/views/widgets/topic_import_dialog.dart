import 'package:flutter/material.dart';
import 'package:mobile/core/exceptions/app_exception.dart';
import 'package:mobile/core/utils/toast_util.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/features/admin/models/topic_model.dart';
import 'package:mobile/core/services/excel_service.dart';
import 'package:mobile/core/widgets/primary_button.dart';
import 'package:mobile/features/admin/models/level_model.dart';

class TopicImportDialog extends StatefulWidget {
  final TopicModel? topic;
  final List<LevelModel>? levels;
  final List<TopicModel>? allTopics;
  final String? initialLevelId;
  final Future<void> Function({
    String? topicId,
    required String levelId,
    required String title,
    required List<Map<String, dynamic>> words,
  })
  onImport;

  const TopicImportDialog({
    super.key,
    this.topic,
    this.levels,
    this.allTopics,
    this.initialLevelId,
    required this.onImport,
  });

  @override
  State<TopicImportDialog> createState() => _TopicImportDialogState();
}

enum ImportMode { selectTopic, createTopic }

class _TopicImportDialogState extends State<TopicImportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _selectedLevelId;
  String? _selectedTopicId;
  List<TopicModel> _filteredTopics = [];
  ImportMode _importMode = ImportMode.selectTopic;
  bool _isSubmitting = false;
  List<Map<String, dynamic>>? _parsedWords;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    if (widget.topic != null) {
      _titleController.text = widget.topic!.title;
      _selectedLevelId = widget.topic!.levelId;
      _selectedTopicId = widget.topic!.id;
    } else {
      _selectedLevelId = widget.initialLevelId;
      if (_selectedLevelId != null && widget.allTopics != null) {
        _filteredTopics = widget.allTopics!
            .where((t) => t.levelId == _selectedLevelId)
            .toList();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _pickAndParseFile() async {
    try {
      final words = await ExcelService.pickAndParseExcel();
      if (words != null) {
        setState(() {
          _parsedWords = words;
          _fileName = 'Đã trích xuất ${words.length} từ vựng';
        });
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  void _submit() async {
    if (widget.topic == null && !_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLevelId == null) {
      ToastUtil.showSnackBar(context, 'Vui lòng chọn Level', isError: true);
      return;
    }

    if (_importMode == ImportMode.selectTopic && _selectedTopicId == null) {
      ToastUtil.showSnackBar(context, 'Vui lòng chọn Topic', isError: true);
      return;
    }

    if (_parsedWords == null || _parsedWords!.isEmpty) {
      ToastUtil.showSnackBar(
        context,
        'Vui lòng chọn file Excel hợp lệ',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onImport(
        topicId: widget.topic?.id ?? _selectedTopicId,
        levelId: _selectedLevelId!,
        title: _titleController.text.trim(),
        words: _parsedWords!,
      );
      if (mounted) {
        Navigator.pop(context);
        ToastUtil.showSnackBar(context, 'Import dữ liệu thành công!');
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Import Từ Vựng',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.brandDark,
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
              const SizedBox(height: 16),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.topic != null) ...[
                      TextFormField(
                        initialValue: widget.topic!.levelId,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Level ID (Cố định)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: widget.topic!.title,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Topic (Cố định)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    _importMode == ImportMode.selectTopic
                                    ? AppColors.brandDark
                                    : AppColors.surface,
                                foregroundColor:
                                    _importMode == ImportMode.selectTopic
                                    ? AppColors.surface
                                    : AppColors.brandDark,
                              ),
                              onPressed: () {
                                setState(() {
                                  _importMode = ImportMode.selectTopic;
                                  _selectedTopicId = null;
                                  _titleController.text = '';
                                });
                              },
                              child: const Text('Chọn Topics'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    _importMode == ImportMode.createTopic
                                    ? AppColors.brandDark
                                    : AppColors.surface,
                                foregroundColor:
                                    _importMode == ImportMode.createTopic
                                    ? AppColors.surface
                                    : AppColors.brandDark,
                              ),
                              onPressed: () {
                                setState(() {
                                  _importMode = ImportMode.createTopic;
                                  _selectedTopicId = null;
                                  _titleController.text = '';
                                });
                              },
                              child: const Text('Tạo Topics'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedLevelId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Chọn Level',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            widget.levels?.map((level) {
                              return DropdownMenuItem(
                                value: level.id,
                                child: Text(
                                  level.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList() ??
                            [],
                        onChanged: (val) {
                          setState(() {
                            _selectedLevelId = val;
                            _selectedTopicId = null;
                            _titleController.text = '';
                            if (val != null && widget.allTopics != null) {
                              _filteredTopics = widget.allTopics!
                                  .where((t) => t.levelId == val)
                                  .toList();
                            } else {
                              _filteredTopics = [];
                            }
                          });
                        },
                        validator: (val) =>
                            val == null ? 'Vui lòng chọn Level' : null,
                      ),
                      const SizedBox(height: 16),
                      if (_selectedLevelId != null &&
                          _importMode == ImportMode.selectTopic) ...[
                        if (_filteredTopics.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfacePink.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Level này chưa có Topic nào. Vui lòng chọn "Tạo Topics" để tạo mới.',
                              style: TextStyle(color: AppColors.brandDark),
                            ),
                          )
                        else ...[
                          DropdownButtonFormField<String?>(
                            initialValue: _selectedTopicId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Chọn Topic',
                              border: OutlineInputBorder(),
                            ),
                            items: _filteredTopics.map((t) {
                              return DropdownMenuItem(
                                value: t.id,
                                child: Text(
                                  t.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedTopicId = val;
                                if (val != null) {
                                  final selected = _filteredTopics.firstWhere(
                                    (t) => t.id == val,
                                  );
                                  _titleController.text = selected.title;
                                } else {
                                  _titleController.text = '';
                                }
                              });
                            },
                            validator: (val) =>
                                val == null ? 'Vui lòng chọn Topic' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _titleController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Tên Topic (Cố định)',
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng chọn Topic';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                      if (_selectedLevelId != null &&
                          _importMode == ImportMode.createTopic) ...[
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Tên Topic Mới (vd: Bài 1 Minna)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tên Topic';
                            }
                            if (value.trim().length < 2) {
                              return 'Tên Topic quá ngắn';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _pickAndParseFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Chọn file Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.brandDark,
                    side: const BorderSide(color: AppColors.brandDark),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              if (_fileName != null) ...[
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    _fileName!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_parsedWords != null && _parsedWords!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    height: 250, // Chiều cao cố định để cuộn
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              AppColors.tertiary,
                            ),
                            columnSpacing: 24,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'STT',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Kanji',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Hiragana',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Romaji',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Meaning',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Example',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Audio URL',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: _parsedWords!.asMap().entries.map((entry) {
                              final index = entry.key;
                              final word = entry.value;
                              return DataRow(
                                cells: [
                                  DataCell(Text('${index + 1}')),
                                  DataCell(
                                    Text(word['kanji']?.toString() ?? ''),
                                  ),
                                  DataCell(
                                    Text(word['hiragana']?.toString() ?? ''),
                                  ),
                                  DataCell(
                                    Text(word['romaji']?.toString() ?? ''),
                                  ),
                                  DataCell(
                                    Text(word['meaning']?.toString() ?? ''),
                                  ),
                                  DataCell(
                                    Text(word['example']?.toString() ?? ''),
                                  ),
                                  DataCell(
                                    Text(word['audioUrl']?.toString() ?? ''),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 32),

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
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    child: PrimaryButton(
                      text: 'Import',
                      isLoading: _isSubmitting,
                      onPressed: _submit,
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
