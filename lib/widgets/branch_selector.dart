import 'package:flutter/material.dart';
import 'package:fmt/models/store_model.dart';
import 'package:fmt/services/store_service.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// Branch selector shown in the home app bar. Tapping opens a bottom sheet
/// with every branch; the active one is highlighted. Stock/pricing on the
/// home screen always reflect the selected branch.
class BranchSelector extends StatelessWidget {
  const BranchSelector({
    super.key,
    this.onChanged,
  });

  final Future<void> Function(StoreModel store)? onChanged;

  StoreService get _storeService => Get.find<StoreService>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = _storeService.selectedStore.value;
      return GestureDetector(
        onTap: () => showBranchSheet(onChanged: onChanged),
        child: Container(
          constraints: BoxConstraints(maxWidth: R.w(190)),
          padding: EdgeInsets.symmetric(
            horizontal: R.w(12),
            vertical: R.h(8),
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(R.w(24)),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.store_outlined,
                  size: R.sp(18), color: AppColors.primary),
              SizedBox(width: R.w(6)),
              Flexible(
                child: Text(
                  current?.name ?? 'branch.select'.trns(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: R.sp(12),
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
              SizedBox(width: R.w(2)),
              Icon(Icons.keyboard_arrow_down,
                  size: R.sp(18), color: AppColors.grey),
            ],
          ),
        ),
      );
    });
  }
}

/// Opens the branch bottom sheet. Shared by the home app-bar pill and the
/// drawer branch tile — `onChanged` runs after a new branch is tapped.
void showBranchSheet({
  required Future<void> Function(StoreModel store)? onChanged,
}) {
  final storeService = Get.find<StoreService>();
  final stores = storeService.stores;
  if (stores.isEmpty) {
    Get.snackbar(
      'branch.unavailable_title'.trns(),
      'branch.unavailable'.trns(),
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }
  Get.bottomSheet(
    SafeArea(
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
          R.h(24),
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
              'branch.select'.trns(),
              style: TextStyle(
                fontSize: R.sp(18),
                fontWeight: FontWeight.w800,
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: R.h(4)),
            Text(
              'branch.select_hint'.trns(),
              style: TextStyle(
                fontSize: R.sp(12),
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: R.h(12)),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: stores.length,
                separatorBuilder: (_, _) => SizedBox(height: R.h(8)),
                itemBuilder: (context, index) {
                  final store = stores[index];
                  final isActive =
                      storeService.selectedStore.value?.id == store.id;
                  return _StoreTile(
                    store: store,
                    isActive: isActive,
                    onTap: () async {
                      Get.back();
                      await onChanged?.call(store);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

class _StoreTile extends StatelessWidget {
  const _StoreTile({
    required this.store,
    required this.isActive,
    required this.onTap,
  });

  final StoreModel store;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(R.w(12)),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(R.w(12)),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.cardBorder,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: R.w(44),
              height: R.w(44),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(R.w(10)),
                border: Border.all(color: AppColors.cardBorder),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.store,
                color: isActive ? AppColors.primary : AppColors.grey,
                size: R.sp(22),
              ),
            ),
            SizedBox(width: R.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  if (store.address != null)
                    Text(
                      store.address!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: R.sp(12),
                        color: AppColors.grey,
                      ),
                    ),
                ],
              ),
            ),
            if (isActive)
              Icon(Icons.check_circle,
                  color: AppColors.primary, size: R.sp(22)),
          ],
        ),
      ),
    );
  }
}
