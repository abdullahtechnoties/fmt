import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:flutter/material.dart';

class CommonDropdownBottomSheetTwo extends StatefulWidget {
  final String title;
  final double bottomSheetHeight;
  final List<String> dropdownItems;
  final String? currentlySelectedValue;
  final Function(String) onItemSelected;
  final String? searchHint;
  final bool showSearch;

  const CommonDropdownBottomSheetTwo({
    super.key,
    required this.dropdownItems,
    required this.title,
    required this.bottomSheetHeight,
    this.currentlySelectedValue,
    required this.onItemSelected,
    this.searchHint,
    this.showSearch = false,
  });

  @override
  State<CommonDropdownBottomSheetTwo> createState() =>
      _CommonDropdownBottomSheetTwoState();
}

class _CommonDropdownBottomSheetTwoState
    extends State<CommonDropdownBottomSheetTwo> {
  late TextEditingController _searchController;
  late List<String> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.dropdownItems;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems =
          widget.dropdownItems
              .where((item) => item.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColorTop = AppColors.white;
    final Color backgroundColorBottom = AppColors.white;
    final Color textColor = AppColors.black;
    final Color subTextColor = Colors.grey[700]!;
    final Color searchBgColor = Colors.grey[200]!;
    final Color searchTextColor = AppColors.black;
    final Color selectedColor = AppColors.primary.withValues(alpha: 0.1);
    final Color selectedBorderColor = AppColors.primary.withValues(alpha: 0.4);
    final Color selectedTextColor = AppColors.primary;

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
          color: AppColors.white.withValues(alpha: 0.1),

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
            SizedBox(height: R.scaleSize(context, 12)),
            Center(
              child: Container(
                width: R.scaleSize(context, 60),
                height: R.scaleSize(context, 5),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(
                    R.scaleSize(context, 4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: R.scaleSize(context, 24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: R.scaleSize(context, 16),
                      color: textColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(20, 0),
                    child: IconButton(
                      icon: Icon(Icons.close, color: AppColors.black),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: R.scaleSize(context, 20),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.showSearch) ...[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: R.scaleSize(context, 24),
                  vertical: R.scaleSize(context, 16),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: searchBgColor,
                    borderRadius: BorderRadius.circular(
                      R.scaleSize(context, 14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.2),
                        blurRadius: R.scaleSize(context, 10),
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterItems,
                    style: TextStyle(color: searchTextColor),
                    decoration: InputDecoration(
                      hintText: widget.searchHint ?? 'Search...',
                      hintStyle: TextStyle(color: subTextColor),
                      prefixIcon: Icon(Icons.search, color: subTextColor),
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
                      fillColor: AppColors.transparent,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: R.scaleSize(context, 16),
                        vertical: R.scaleSize(context, 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            Expanded(
              child:
                  _filteredItems.isEmpty
                      ? _buildEmptyState(textColor, subTextColor)
                      : _buildItemsList(
                        textColor,
                        selectedColor,
                        selectedBorderColor,
                        selectedTextColor,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color subTextColor) {
    return Center(
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

  Widget _buildItemsList(
    Color textColor,
    Color selectedColor,
    Color selectedBorderColor,
    Color selectedTextColor,
  ) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: R.scaleSize(context, 8),
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: R.scaleSize(context, 16),
        right: R.scaleSize(context, 16),
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final isSelected = widget.currentlySelectedValue == item;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(
            vertical: R.scaleSize(context, 4),
          ),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : AppColors.transparent,
            borderRadius: BorderRadius.circular(
              R.scaleSize(context, 4),
            ),
            border:
                isSelected
                    ? Border.all(color: selectedBorderColor, width: 1)
                    : null,
          ),
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: () {
                widget.onItemSelected(item);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(
                R.scaleSize(context, 4),
              ),
              splashColor: selectedTextColor.withValues(alpha: 0.1),
              highlightColor: AppColors.transparent,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: R.scaleSize(context, 16),
                  vertical: R.scaleSize(context, 8),
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
                              isSelected ? FontWeight.w600 : FontWeight.normal,
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
    );
  }
}