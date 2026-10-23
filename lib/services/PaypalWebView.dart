// ignore: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fmt/services/PaymentConfig.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/utilities/typography.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// PayPal approval webview. Pops with `true` when the backend success URL is
/// hit (payment captured), `false` on cancel/close.
class PayPalWebViewPage extends StatefulWidget {
  final String approvalUrl;
  const PayPalWebViewPage({super.key, required this.approvalUrl});

  @override
  State<PayPalWebViewPage> createState() => _PayPalWebViewPageState();
}

class _PayPalWebViewPageState extends State<PayPalWebViewPage> {
  late final WebViewController _controller;
  bool _finishing = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => _handleUrl(url),
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onUrlChange: (change) {
            final url = change.url;
            if (url != null) _handleUrl(url);
          },
          onNavigationRequest: (req) {
            _handleUrl(req.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  void _handleUrl(String url) {
    if (_finishing) return;

    final isSuccess = url.contains(PaymentConfig.paypalSuccessMarker);
    final isCancel = url.contains(PaymentConfig.paypalCancelMarker);

    if (isSuccess || isCancel) {
      _finishing = true;
      if (mounted) Get.back(result: isSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_finishing,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Get.back(result: false),
            child: const Icon(Icons.close_rounded,
                size: 26, color: AppColors.black),
          ),
          centerTitle: true,
          title: Text(
            'checkout.paypal_title'.trns(),
            style: AppTextStyles.heading3(),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
