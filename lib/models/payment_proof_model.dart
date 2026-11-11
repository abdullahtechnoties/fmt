/// Payment proof (transfer receipt) attached at checkout or later from the
/// order screen.
///
/// `payment_proof` is `null` until one is uploaded; otherwise it is the object
/// returned by `POST /orders/{id}/payment-proof`. The file itself is private
/// and must be requested with the bearer token.
class PaymentProof {
  const PaymentProof({
    this.url,
    this.apiUrl,
    this.name,
    this.mime,
    this.size = 0,
    this.isPdf = false,
    this.uploadedAt,
  });

  final String? url;
  final String? apiUrl;
  final String? name;
  final String? mime;
  final int size;
  final bool isPdf;
  final String? uploadedAt;

  String get sizeLabel => formatSize(size);

  bool get hasApiUrl => (apiUrl ?? '').trim().isNotEmpty;

  static PaymentProof? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return json.isEmpty ? null : PaymentProof.fromJson(json);
  }

  factory PaymentProof.fromJson(Map<String, dynamic> json) {
    final name = _stringOrNull(json['name']);
    final mime = _stringOrNull(json['mime']);
    final inferredPdf =
        (mime ?? '').toLowerCase() == 'application/pdf' ||
        (name ?? '').toLowerCase().endsWith('.pdf');
    final rawIsPdf = json['is_pdf'];
    return PaymentProof(
      url: _stringOrNull(json['url']),
      apiUrl: _stringOrNull(json['api_url']),
      name: name,
      mime: mime,
      size: _int(json['size']),
      isPdf: rawIsPdf is bool ? rawIsPdf : inferredPdf,
      uploadedAt: _stringOrNull(json['uploaded_at']),
    );
  }

  static String formatSize(int bytes) {
    if (bytes <= 0) return '';
    if (bytes >= 1024 * 1024) {
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(mb == mb.roundToDouble() ? 0 : 1)} MB';
    }
    return '${(bytes / 1024).ceil()} KB';
  }

  static String? _stringOrNull(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}

/// Rules returned by `GET /checkout/summary` under `data.payment_proof`.
///
/// Read these from the server instead of hardcoding them in the UI.
class PaymentProofRules {
  const PaymentProofRules({
    this.field = 'payment_proof',
    this.label = 'Payment Proof',
    this.hint = 'Already paid? Attach a screenshot of your transfer receipt.',
    this.required = false,
    this.accepts = const ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    this.maxKb = 5120,
  });

  final String field;
  final String label;
  final String hint;
  final bool required;
  final List<String> accepts;
  final int maxKb;

  int get maxBytes => maxKb * 1024;

  double get maxMb => maxKb / 1024;

  String get maxMbLabel {
    final mb = maxMb;
    return mb == mb.roundToDouble()
        ? mb.toStringAsFixed(0)
        : mb.toStringAsFixed(1);
  }

  /// Returns why [file] would be rejected, or `null` when it looks valid.
  /// The server still validates the file by content — this is a fast
  /// client-side guard so customers get immediate feedback.
  PaymentProofFileError? validateFile({
    required String? name,
    required int size,
  }) {
    final extension = _extensionOf(name);
    final allowed = accepts.map(_normaliseExtension).toSet();
    if (extension.isEmpty || !allowed.contains(extension)) {
      return PaymentProofFileError.unsupportedType;
    }
    if (maxKb > 0 && size > maxBytes) {
      return PaymentProofFileError.tooLarge;
    }
    return null;
  }

  factory PaymentProofRules.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) return const PaymentProofRules();

    final rawAccepts = json['accepts'];
    final accepts = rawAccepts is List
        ? rawAccepts
              .map((e) => _normaliseExtension(e.toString()))
              .where((e) => e.isNotEmpty)
              .toList()
        : const <String>[];

    final rawMaxKb = _int(json['max_kb']);
    final field = json['field']?.toString().trim() ?? '';
    final label = json['label']?.toString().trim() ?? '';
    final hint = json['hint']?.toString().trim() ?? '';

    return PaymentProofRules(
      field: field.isEmpty ? 'payment_proof' : field,
      label: label.isEmpty ? 'Payment Proof' : label,
      hint: hint.isEmpty
          ? 'Already paid? Attach a screenshot of your transfer receipt.'
          : hint,
      required: json['required'] == true,
      accepts: accepts.isEmpty
          ? const ['jpg', 'jpeg', 'png', 'webp', 'pdf']
          : accepts,
      maxKb: rawMaxKb > 0 ? rawMaxKb : 5120,
    );
  }

  static String _extensionOf(String? name) {
    final value = (name ?? '').trim().toLowerCase();
    final dot = value.lastIndexOf('.');
    if (dot < 0 || dot == value.length - 1) return '';
    return _normaliseExtension(value.substring(dot + 1));
  }

  static String _normaliseExtension(String value) {
    return value.trim().toLowerCase().replaceFirst(RegExp(r'^\.'), '');
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}

enum PaymentProofFileError { unsupportedType, tooLarge }
