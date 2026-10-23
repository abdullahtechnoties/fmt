class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final String? nextPageUrl;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    this.nextPageUrl,
  });

  bool get hasNextPage => nextPageUrl != null && currentPage < lastPage;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: _parseInt(json['current_page']) ?? 1,
      lastPage: _parseInt(json['last_page']) ?? 1,
      total: _parseInt(json['total']) ?? 0,
      perPage: _parseInt(json['per_page']) ?? 10,
      nextPageUrl: json['next_page_url']?.toString(),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}

class PaginatedResult<T> {
  final List<T> items;
  final PaginationMeta meta;

  const PaginatedResult({required this.items, required this.meta});
}