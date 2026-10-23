import 'package:fmt/utilities/colors.dart';
import 'package:flutter/material.dart';

class SelectionItem {
  const SelectionItem({required this.label, required this.value});

  final String label;
  final String value;
}

/// Global inline selection dropdown.
///
/// The field itself becomes a search bar while the dropdown is open. The
/// options panel expands right beneath the field, and every option shows a
/// radio indicator in its suffix (filled when selected, empty otherwise).
class InlineSelectionDropdown extends StatefulWidget {
  const InlineSelectionDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onSelected,
    this.searchHint,
    this.enabled = true,
    this.loading = false,
    this.fillColor = const Color(0xFFF9F9F9),
    this.maxPanelHeight = 300,
    this.emptyText,
  });

  final String label;
  final String hint;
  final String value;
  final List<SelectionItem> items;
  final ValueChanged<SelectionItem> onSelected;
  final String? searchHint;
  final bool enabled;
  final bool loading;
  final Color fillColor;
  final double maxPanelHeight;
  final String? emptyText;

  @override
  State<InlineSelectionDropdown> createState() =>
      _InlineSelectionDropdownState();
}

class _InlineSelectionDropdownState extends State<InlineSelectionDropdown> {
  bool _open = false;
  late final TextEditingController _search;
  final FocusNode _searchFocus = FocusNode();
  List<SelectionItem> _filtered = const [];

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _filtered = widget.items;
  }

  @override
  void didUpdateWidget(covariant InlineSelectionDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filtered = _applyFilter(_search.text);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<SelectionItem> _applyFilter(String query) {
    if (query.trim().isEmpty) return widget.items;
    final q = query.toLowerCase().trim();
    return widget.items
        .where((item) => item.label.toLowerCase().contains(q))
        .toList();
  }

  void _toggle() {
    if (!widget.enabled || widget.loading) return;
    if (_open) {
      _close();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _search.clear();
    _filtered = widget.items;
    setState(() => _open = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _open) _searchFocus.requestFocus();
    });
  }

  void _close() {
    if (!_open) return;
    _searchFocus.unfocus();
    setState(() {
      _open = false;
      _search.clear();
    });
  }

  void _onQueryChanged(String query) {
    setState(() => _filtered = _applyFilter(query));
  }

  void _select(SelectionItem item) {
    _close();
    widget.onSelected(item);
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) => _close(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField(),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _open
                ? _buildPanel()
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildField() {
    final hasValue = widget.value.trim().isNotEmpty;
    final borderColor = (_open || hasValue)
        ? AppColors.primary
        : const Color(0xFFE0E0E0);

    final field = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: widget.fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: _open ? 1.6 : 1.2),
      ),
      child: _open ? _buildSearchField() : _buildClosedField(hasValue),
    );

    if (_open) return field;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: widget.enabled ? 1 : 0.55,
      child: GestureDetector(onTap: _toggle, child: field),
    );
  }

  Widget _buildClosedField(bool hasValue) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.value.trim().isNotEmpty ? widget.value : widget.hint,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w500,
                  color: hasValue ? Colors.black87 : const Color(0xFF9CA3AF),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (widget.loading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _open ? 0.5 : 0,
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black54,
            ),
          ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Row(
      children: [
        const Icon(Icons.search_rounded, size: 28, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _search,
            focusNode: _searchFocus,
            onChanged: _onQueryChanged,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: widget.searchHint ?? widget.hint,
              hintStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
        ),
        if (_search.text.isNotEmpty)
          IconButton(
            onPressed: () {
              _search.clear();
              _onQueryChanged('');
            },
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: Color(0xFF9CA3AF),
            ),
          ),
      ],
    );
  }

  Widget _buildPanel() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      constraints: BoxConstraints(maxHeight: widget.maxPanelHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _filtered.isEmpty ? _buildEmptyState() : _buildItems(),
    );
  }

  Widget _buildItems() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: _filtered.length,
      itemBuilder: (context, index) => _buildItem(_filtered[index]),
    );
  }

  Widget _buildItem(SelectionItem item) {
    final isSelected = item.label == widget.value;
    return InkWell(
      onTap: () => _select(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.06)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.bold,
                  color: isSelected ? AppColors.primary : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _RadioIndicator(isSelected: isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 44,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 10),
            Text(
              widget.emptyText ?? 'No options available',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  final bool isSelected;
  const _RadioIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFCCCCCC),
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
    );
  }
}
