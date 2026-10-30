import 'package:flutter/material.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/inputfield.dart';
import 'package:fmt/widgets/main_btn.dart';
import 'package:get/get.dart';

/// Single-address editor: one delivery line per customer, each save
/// overwrites the previous one (`PUT /account/addresses/delivery`).
/// Returns true when the caller saved successfully.
Future<bool> showDeliveryAddressSheet({
  required String initial,
  required Future<bool> Function(String value) onSave,
}) async {
  final result = await Get.bottomSheet<bool>(
    _DeliveryAddressSheet(initial: initial, onSave: onSave),
    isScrollControlled: true,
  );
  return result ?? false;
}

class _DeliveryAddressSheet extends StatefulWidget {
  const _DeliveryAddressSheet({required this.initial, required this.onSave});

  final String initial;
  final Future<bool> Function(String value) onSave;

  @override
  State<_DeliveryAddressSheet> createState() => _DeliveryAddressSheetState();
}

class _DeliveryAddressSheetState extends State<_DeliveryAddressSheet> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final ok = await widget.onSave(_controller.text);
      if (ok && mounted) Get.back(result: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(R.w(20)),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          R.w(20),
          R.h(12),
          R.w(20),
          R.h(24) + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: R.w(48),
                height: R.h(4),
                decoration: BoxDecoration(
                  color: AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: R.h(14)),
            Text(
              'profile.delivery_title'.trns(),
              style: TextStyle(
                fontSize: R.sp(18),
                fontWeight: FontWeight.w800,
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: R.h(4)),
            Text(
              'profile.delivery_hint'.trns(),
              style: TextStyle(fontSize: R.sp(12), color: AppColors.grey),
            ),
            SizedBox(height: R.h(14)),
            InputField(
              controller: _controller,
              hintText: 'profile.delivery_placeholder'.trns(),
              maxLines: 4,
              textInputAction: TextInputAction.done,
              borderRadius: 12,
            ),
            SizedBox(height: R.h(16)),
            SizedBox(
              height: R.h(50),
              child: MainBtn(
                text: 'profile.delivery_save'.trns(),
                color: AppColors.primary,
                borderRadius: 12,
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
