import 'package:fmt/utilities/translation_extention.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utilities/colors.dart';
import 'inputfield.dart';

/// A reusable, tappable field that opens a searchable selection sheet.
/// Uses the same visual style as [InputField].
class SearchableSelectField<T> extends StatefulWidget {
  const SearchableSelectField({
    super.key,
    required this.hintText,
    required this.displayText,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
    this.enabled = true,
    this.isLoading = false,
    this.signupStyle = true,
    this.emptyDataMessage,
  });

  final String hintText;
  final String? displayText;
  final List<T> items;
  final String Function(T item) itemLabel;
  final void Function(T item) onSelected;
  final bool enabled;
  final bool isLoading;
  final bool signupStyle;
  final String? emptyDataMessage;

  @override
  State<SearchableSelectField<T>> createState() =>
      _SearchableSelectFieldState<T>();
}

class _SearchableSelectFieldState<T> extends State<SearchableSelectField<T>> {
  late final TextEditingController _controller;

  String get _emptyDataMessage {
    if (widget.emptyDataMessage != null &&
        widget.emptyDataMessage!.isNotEmpty) {
      return widget.emptyDataMessage!;
    }
    return 'home.common.noItemAvailable'.trnsFormat({'item': widget.hintText});
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.displayText ?? '');
  }

  @override
  void didUpdateWidget(covariant SearchableSelectField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.displayText != widget.displayText) {
      _controller.text = widget.displayText ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if there's no data
    final bool hasNoData = widget.items.isEmpty;

    // Determine if the field should be interactive
    final bool isInteractive =
        widget.enabled && !widget.isLoading && !hasNoData;

    return GestureDetector(
      onTap: isInteractive ? () => _openSheet(context) : null,
      child: AbsorbPointer(
        child: InputField(
          controller: _controller,
          hintText: hasNoData ? _emptyDataMessage : widget.hintText,
          signupStyle: widget.signupStyle,
          enabled: widget.enabled && !hasNoData,
          readOnly: true,
          suffixIcon: widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.secondary,
                    ),
                  ),
                )
              : hasNoData
              ? const Icon(Icons.block, color: AppColors.grey, size: 20)
              : const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.secondary,
                ),
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final selected = await Get.bottomSheet<T?>(
      _SearchSheet<T>(
        title: widget.hintText,
        items: widget.items,
        itemLabel: widget.itemLabel,
        initialQuery: "",
        emptyDataMessage: _emptyDataMessage,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (selected != null) widget.onSelected(selected);
  }
}

class _SearchSheet<T> extends StatefulWidget {
  const _SearchSheet({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.initialQuery,
    required this.emptyDataMessage,
  });

  final String title;
  final List<T> items;
  final String Function(T item) itemLabel;
  final String initialQuery;
  final String emptyDataMessage;

  @override
  State<_SearchSheet<T>> createState() => _SearchSheetState<T>();
}

class _SearchSheetState<T> extends State<_SearchSheet<T>> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _searchController.text.trim().toLowerCase();

    // Check if there's any data at all
    final bool hasNoData = widget.items.isEmpty;

    // Filter items if there is data
    final filtered = hasNoData
        ? <T>[]
        : q.isEmpty
        ? widget.items
        : widget.items
              .where((e) => widget.itemLabel(e).toLowerCase().contains(q))
              .toList();

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back<T?>(result: null),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Hide search field when there's no data
            if (!hasNoData)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: InputField(
                  controller: _searchController,
                  hintText: 'home.common.search'.trns(),
                  signupStyle: true,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            Expanded(child: _buildContent(filtered, hasNoData)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<T> filtered, bool hasNoData) {
    // Case 1: No data at all
    if (hasNoData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                widget.emptyDataMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Case 2: No search results
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 48, color: AppColors.grey),
              const SizedBox(height: 16),
              Text(
                'home.common.noResultsFound'.trns(),
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Case 3: Show the list
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final item = filtered[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            widget.itemLabel(item),
            style: const TextStyle(color: AppColors.black),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.grey,
          ),
          onTap: () => Get.back<T?>(result: item),
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemCount: filtered.length,
    );
  }
}
