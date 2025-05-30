import 'package:flutter/material.dart';

class CustomDropdownButton extends StatefulWidget {
  final List<String> items;
  final String? selectedValue;
  final String label;
  final void Function(String?) onChanged;

  const CustomDropdownButton({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.label,
    required this.onChanged,
  });

  @override
  State<CustomDropdownButton> createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  bool isOpen = false;

  void _toggleDropdown() {
    if (isOpen) {
      _removeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    isOpen = false;
  }

  void _showDropdown() {
    final RenderBox renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx,
          top: position.dy + size.height + 8,
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: Offset(0, size.height + 8),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  border: Border.all(color: Color(0xFFDCEFB8), width: 1),
                ),
                child: RawScrollbar(
                  thumbVisibility: true,
                  controller: _scrollController,
                  radius: const Radius.circular(8),
                  thickness: 6,
                  thumbColor: Colors.white,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final value = widget.items[index];
                      return ListTile(
                        title: Text(value),
                        onTap: () {
                          widget.onChanged(value);
                          _removeDropdown();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    isOpen = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = widget.items.indexOf(widget.selectedValue ?? '');
      if (index != -1) {
        const double itemHeight = 48.0;
        final double offset = (index * itemHeight).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );
        _scrollController.jumpTo(offset);
      }
    });
  }

  @override
  void dispose() {
    _removeDropdown();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        key: _buttonKey,
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDCEFB8)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.selectedValue != null
                    ? widget.selectedValue! +
                        (widget.label.contains('연도')
                            ? '년'
                            : widget.label.contains('월')
                            ? '월'
                            : widget.label.contains('일')
                            ? '일'
                            : '')
                    : widget.label,
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
