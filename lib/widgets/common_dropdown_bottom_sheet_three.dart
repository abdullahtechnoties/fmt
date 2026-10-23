import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utilities/translation_extention.dart' show TranslationsExtension;

class CommonDropdownBottomSheetThree extends StatefulWidget {
  final String title;
  final double bottomSheetHeight;
  final List<String> dropdownItems;
  final RxString selectedItem;
  final TextEditingController textController;
  final List<String>? selectedValue;
  final Function(dynamic)? onValueSelected;
  final String currentlySelectedValue;
  final bool showSearch;
  final String? searchHint;

  const CommonDropdownBottomSheetThree({
    super.key,
    required this.dropdownItems,
    required this.selectedItem,
    required this.textController,
    required this.title,
    required this.bottomSheetHeight,
    this.selectedValue,
    this.onValueSelected,
    required this.currentlySelectedValue,
    this.showSearch = false,
    this.searchHint,
  });

  @override
  State<CommonDropdownBottomSheetThree> createState() =>
      _CommonDropdownBottomSheetThreeState();
}

class _CommonDropdownBottomSheetThreeState
    extends State<CommonDropdownBottomSheetThree> {
  late TextEditingController _searchController;
  late List<String> _filteredItems;
  late List<int> _filteredIndices;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.dropdownItems;
    _filteredIndices = List.generate(
      widget.dropdownItems.length,
      (index) => index,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      _filteredIndices = [];
      _filteredItems = [];

      for (int i = 0; i < widget.dropdownItems.length; i++) {
        if (widget.dropdownItems[i].toLowerCase().contains(
          query.toLowerCase(),
        )) {
          _filteredItems.add(widget.dropdownItems[i]);
          _filteredIndices.add(i);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    final Color backgroundColorTop =
        themeController.isDarkMode.value
            ? AppColors.secondary
            : AppColors.white;
    final Color backgroundColorBottom =
        themeController.isDarkMode.value
            ? AppColors.secondary
            : AppColors.white;
    final Color textColor =
        themeController.isDarkMode.value
            ? AppColors.black
            : AppColors.black;
    final Color subTextColor =
        themeController.isDarkMode.value
            ? AppColors.secondary
            : Colors.grey[700]!;
    final Color searchTextColor =
        themeController.isDarkMode.value
            ? AppColors.primary
            : AppColors.black;
    final Color selectedColor =
        themeController.isDarkMode.value
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.primary.withValues(alpha: 0.05);
    final Color selectedBorderColor =
        themeController.isDarkMode.value
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.1);
    final Color selectedTextColor =
        themeController.isDarkMode.value
            ? AppColors.primary
            : AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      height: widget.bottomSheetHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColorTop.withValues(alpha: 0.95),
            backgroundColorBottom.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(R.scaleSize(context, 28)),
          topRight: Radius.circular(R.scaleSize(context, 28)),
        ),
        border: Border.all(
          color:
              themeController.isDarkMode.value
                  ? AppColors.white.withValues(alpha: 0.20)
                  : AppColors.white.withValues(alpha: 0.10),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.4),
            blurRadius: R.scaleSize(context, 30),
            spreadRadius: R.scaleSize(context, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(R.scaleSize(context, 28)),
          topRight: Radius.circular(R.scaleSize(context, 28)),
        ),
        child: Column(
          children: [
            Column(
              children: [
                SizedBox(height: R.scaleSize(context, 12)),
                Center(
                  child: Container(
                    width: R.scaleSize(context, 60),
                    height: R.scaleSize(context, 5),
                    decoration: BoxDecoration(
                      color:
                          themeController.isDarkMode.value
                              ? AppColors.white.withValues(alpha: 0.16)
                              : AppColors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(
                        R.scaleSize(context, 4),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: R.scaleSize(context, 16),
                          color: textColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color:
                              themeController.isDarkMode.value
                                  ? AppColors.primary
                                  : AppColors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                        splashRadius: R.scaleSize(context, 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (widget.showSearch) ...[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: R.scaleSize(context, 24),
                ),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        spreadRadius: 0,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterItems,
                    decoration: InputDecoration(
                      hintText: 'home.common.search'.trns(),
                      hintStyle: TextStyle(color: subTextColor, fontSize: 14),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: R.scaleSize(context, 20),
                                  color: subTextColor,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterItems('');
                                },
                              )
                              : null,
                      filled: true,
                      fillColor:
                          themeController.isDarkMode.value
                              ? AppColors.secondary.withValues(alpha: 0.95)
                              : AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: searchTextColor, fontSize: 13),
                  ),
                ),
              ),
            ],
            _filteredItems.isEmpty
                ? _buildEmptyState(textColor, subTextColor)
                : _buildItemsList(
                  textColor,
                  selectedColor,
                  selectedBorderColor,
                  selectedTextColor,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(
    Color textColor,
    Color selectedColor,
    Color selectedBorderColor,
    Color selectedTextColor,
  ) {
    return Expanded(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: R.scaleSize(context, 8),
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: R.scaleSize(context, 20),
          right: R.scaleSize(context, 20),
        ),
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          final fmtlIndex = _filteredIndices[index];
          final uniqueId =
              widget.selectedValue != null &&
                      fmtlIndex < widget.selectedValue!.length
                  ? widget.selectedValue![fmtlIndex]
                  : item;
          final isSelected = widget.currentlySelectedValue == uniqueId;
          return AnimatedContainer(
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : AppColors.transparent,
              borderRadius: BorderRadius.circular(
                R.scaleSize(context, 8),
              ),
              border:
                  isSelected
                      ? Border.all(color: selectedBorderColor, width: 1)
                      : null,
            ),
            child: Material(
              color: AppColors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  R.scaleSize(context, 8),
                ),
                splashColor: selectedTextColor.withValues(alpha: 0.1),
                highlightColor: AppColors.transparent,
                onTap: () {
                  if (widget.selectedValue != null &&
                      fmtlIndex < widget.selectedValue!.length) {
                    final selectedValue = widget.selectedValue![fmtlIndex];
                    widget.selectedItem.value = selectedValue;
                    widget.textController.text = item;
                    widget.onValueSelected?.call(selectedValue);
                  } else {
                    widget.selectedItem.value = item;
                    widget.textController.text = item;
                    widget.onValueSelected?.call(item);
                  }
                  Get.back();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.scaleSize(
                      context,
                      isSelected ? 10 : 10,
                    ),
                    vertical: R.scaleSize(context, 12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: R.scaleSize(context, 14),
                            color: isSelected ? selectedTextColor : textColor,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_rounded,
                          color: selectedTextColor,
                          size: R.scaleSize(context, 20),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: _filteredItems.length,
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color subTextColor) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: R.scaleSize(context, 60),
            color: subTextColor,
          ),
          SizedBox(height: R.scaleSize(context, 16)),
          Text(
            'home.common.noResultsFound'.trns(),
            style: TextStyle(
              fontSize: R.scaleSize(context, 18),
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: R.scaleSize(context, 8)),
          Text(
            'home.common.tryDifferentSearch'.trns(),
            style: TextStyle(
              fontSize: R.scaleSize(context, 14),
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }
}