class PaginatedResponse<T> {
  final List<T> docs;
  final int totalDocs;
  final int limit;
  final int totalPages;
  final int page;
  final bool hasNextPage;
  final bool hasPrevPage;

  PaginatedResponse({
    required this.docs,
    required this.totalDocs,
    required this.limit,
    required this.totalPages,
    required this.page,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return PaginatedResponse(
      docs: (json['docs'] as List).map((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      totalDocs: json['totalDocs'] ?? 0,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
      page: json['page'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }
}
