import 'package:flutter/material.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Full-screen viewer for the private payment-proof file.
///
/// The endpoint streams the receipt only when the bearer token is present,
/// so the headers are forwarded to the initial web request instead of
/// opening the URL with `url_launcher`.
class PaymentProofViewerPage extends StatefulWidget {
  const PaymentProofViewerPage({
    super.key,
    required this.url,
    this.headers = const {},
    this.title,
  });

  final String url;
  final Map<String, String> headers;
  final String? title;

  @override
  State<PaymentProofViewerPage> createState() => _PaymentProofViewerPageState();
}

class _PaymentProofViewerPageState extends State<PaymentProofViewerPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url), headers: widget.headers);
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.title ?? '').trim();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: Get.back,
          child: const Icon(
            Icons.close_rounded,
            size: 26,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        title: Text(
          title.isEmpty ? 'payment_proof.title'.trns() : title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
