import 'package:mobile/features/flashcard/models/flashcard_model.dart';

class ProgressWordPageModel {
  final List<FlashcardModel> docs;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ProgressWordPageModel({
    this.docs = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 10,
    this.totalPages = 0,
  });

  factory ProgressWordPageModel.fromJson(Map<String, dynamic> json) {
    final rawDocs = json['docs'] as List<dynamic>? ?? [];
    return ProgressWordPageModel(
      docs: rawDocs.map((e) => FlashcardModel.fromJson(e as Map<String, dynamic>)).toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}
