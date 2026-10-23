// // app/widgets/draggable_request_button.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:fmt/utilities/colors.dart';
// import 'package:fmt/utilities/translation_extention.dart';

// class DraggableRequestButton extends StatefulWidget {
//   const DraggableRequestButton({
//     super.key,
//     required this.onTap,
//     this.initialTop,
//     this.initialRight = 16.0,
//   });

//   final VoidCallback onTap;
//   final double? initialTop;
//   final double initialRight;

//   @override
//   State<DraggableRequestButton> createState() =>
//       _DraggableRequestButtonState();
// }

// class _DraggableRequestButtonState
//     extends State<DraggableRequestButton>
//     with SingleTickerProviderStateMixin {
//   // Position state
//   late double _top;
//   late double _right;

//   // Label visibility
//   bool _labelVisible = false;

//   // Drag state to distinguish tap vs drag
//   bool _isDragging = false;
//   Offset _dragStartOffset = Offset.zero;

//   // Animation controller for label
//   late AnimationController _labelController;
//   late Animation<double> _labelFade;
//   late Animation<double> _labelScale;

//   // Auto-hide timer
//   static const Duration _autoHideDelay = Duration(seconds: 2);

//   @override
//   void initState() {
//     super.initState();
//     _labelController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 220),
//     );
//     _labelFade = CurvedAnimation(
//       parent: _labelController,
//       curve: Curves.easeOut,
//     );
//     _labelScale = Tween<double>(begin: 0.85, end: 1.0).animate(
//       CurvedAnimation(parent: _labelController, curve: Curves.easeOutBack),
//     );
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final mq = MediaQuery.of(context);
//     // Initial position — right-center of screen accounting for safe area
//     _top = widget.initialTop ??
//         (mq.size.height * 0.38 - mq.padding.top);
//     _right = widget.initialRight;
//   }

//   @override
//   void dispose() {
//     _labelController.dispose();
//     super.dispose();
//   }

//   void _showLabel() {
//     setState(() => _labelVisible = true);
//     _labelController.forward(from: 0);
//     // Auto-hide after delay
//     Future.delayed(_autoHideDelay, () {
//       if (mounted && _labelVisible) _hideLabel();
//     });
//   }

//   void _hideLabel() {
//     _labelController.reverse().then((_) {
//       if (mounted) setState(() => _labelVisible = false);
//     });
//   }

//   void _toggleLabel() {
//     HapticFeedback.lightImpact();
//     if (_labelVisible) {
//       _hideLabel();
//     } else {
//       _showLabel();
//     }
//     widget.onTap();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mq = MediaQuery.of(context);
//     final screenW = mq.size.width;
//     final screenH = mq.size.height;
//     final safeTop = mq.padding.top;
//     final safeBottom = mq.padding.bottom;

//     // Button dimensions
//     const double btnSize = 38.0;
//     // const double labelHeight = 40.0;
//     const double labelEstimatedWidth = 160.0;

//     return Positioned(
//       top: _top,
//       right: _right,
//       child: GestureDetector(
//         // ── Drag handling ──────────────────────────────────────
//         onPanStart: (details) {
//           _isDragging = false;
//           _dragStartOffset = details.globalPosition;
//         },
//         onPanUpdate: (details) {
//           final delta = details.globalPosition - _dragStartOffset;
//           if (delta.distance > 6) _isDragging = true;

//           setState(() {
//             // Update top
//             _top += details.delta.dy;
//             // Update right (inverted because positioned from right)
//             _right -= details.delta.dx;

//             // Clamp within screen bounds with padding
//             const double pad = 12.0;
//             _top = _top.clamp(
//               safeTop + pad,
//               screenH - safeBottom - btnSize - pad,
//             );
//             _right = _right.clamp(
//               pad,
//               screenW - btnSize - pad,
//             );
//           });
//         },
//         onPanEnd: (_) {
//           // Snap to nearest horizontal edge
//           final leftDist = screenW - _right - btnSize;
//           final rightDist = _right;
//           setState(() {
//             _right = rightDist < leftDist ? 16.0 : screenW - btnSize - 16.0;
//           });
//         },
//         // ── Tap: toggle label ──────────────────────────────────
//         onTap: () {
//           if (!_isDragging) _toggleLabel();
//         },

//         child: SizedBox(
//           // Give enough room for label overflow
//           width: labelEstimatedWidth + btnSize + 8,
//           height: btnSize,
//           child: Stack(
//             alignment: Alignment.centerRight,
//             clipBehavior: Clip.none,
//             children: [
//               // ── Dark pill label ──────────────────────────────
//               if (_labelVisible)
//                 Positioned(
//                   right: btnSize + 8,
//                   child: FadeTransition(
//                     opacity: _labelFade,
//                     child: ScaleTransition(
//                       scale: _labelScale,
//                       alignment: Alignment.centerRight,
//                       child: _RequestLabel(),
//                     ),
//                   ),
//                 ),

//               // ── Teal camera button ───────────────────────────
//               Positioned(
//                 right: 0,
//                 child: _CameraButton(size: btnSize),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  Dark pill label — "Request A Product"
// // ─────────────────────────────────────────────────────────────
// class _RequestLabel extends StatelessWidget {
//   const _RequestLabel();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1A1A),
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.18),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Text(
//         'home.request_product'.trns(),
//         style: TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//           color: AppColors.white,
//           letterSpacing: 0.2,
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  Teal circular camera button
// // ─────────────────────────────────────────────────────────────
// class _CameraButton extends StatelessWidget {
//   const _CameraButton({required this.size});
//   final double size;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: AppColors.primary,
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withValues(alpha: 0.40),
//             blurRadius: 14,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: const Icon(
//         Icons.camera_alt_rounded,
//         color: AppColors.white,
//         size: 20,
//       ),
//     );
//   }
// }


// app/widgets/draggable_request_button.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:fmt/utilities/colors.dart';
// import 'package:fmt/utilities/translation_extention.dart';

// class DraggableRequestButton extends StatefulWidget {
//   const DraggableRequestButton({
//     super.key,
//     required this.onTap,
//     this.initialTop,
//     this.initialRight = 16.0,
//   });

//   final VoidCallback onTap;
//   final double? initialTop;
//   final double initialRight;

//   @override
//   State<DraggableRequestButton> createState() =>
//       _DraggableRequestButtonState();
// }

// class _DraggableRequestButtonState
//     extends State<DraggableRequestButton> {
//   // Position state
//   late double _top;
//   late double _right;

//   // Drag state to distinguish tap vs drag
//   bool _isDragging = false;
//   Offset _dragStartOffset = Offset.zero;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final mq = MediaQuery.of(context);
//     // Initial position — right-center of screen accounting for safe area
//     _top = widget.initialTop ??
//         (mq.size.height * 0.38 - mq.padding.top);
//     _right = widget.initialRight;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mq = MediaQuery.of(context);
//     final screenW = mq.size.width;
//     final screenH = mq.size.height;
//     final safeTop = mq.padding.top;
//     final safeBottom = mq.padding.bottom;

//     // Button dimensions
//     const double btnSize = 38.0;
//     const double labelEstimatedWidth = 160.0;

//     return Positioned(
//       top: _top,
//       right: _right,
//       child: GestureDetector(
//         // ── Drag handling ──────────────────────────────────────
//         onPanStart: (details) {
//           _isDragging = false;
//           _dragStartOffset = details.globalPosition;
//         },
//         onPanUpdate: (details) {
//           final delta = details.globalPosition - _dragStartOffset;
//           if (delta.distance > 6) _isDragging = true;

//           setState(() {
//             _top += details.delta.dy;
//             _right -= details.delta.dx;

//             const double pad = 12.0;
//             _top = _top.clamp(
//               safeTop + pad,
//               screenH - safeBottom - btnSize - pad,
//             );
//             _right = _right.clamp(
//               pad,
//               screenW - btnSize - pad,
//             );
//           });
//         },
//         onPanEnd: (_) {
//           final leftDist = screenW - _right - btnSize;
//           final rightDist = _right;
//           setState(() {
//             _right = rightDist < leftDist ? 16.0 : screenW - btnSize - 16.0;
//           });
//         },
//         // ── Tap: trigger callback (label is always visible) ──
//         onTap: () {
//           if (!_isDragging) {
//             HapticFeedback.lightImpact();
//             widget.onTap();
//           }
//         },

//         child: SizedBox(
//           width: labelEstimatedWidth + btnSize + 8,
//           height: btnSize,
//           child: Stack(
//             alignment: Alignment.centerRight,
//             clipBehavior: Clip.none,
//             children: [
//               // ── Dark pill label (always visible) ─────────────
//               Positioned(
//                 right: 14,
//                 bottom: 40,
//                 child: _RequestLabel(),
//               ),

//               // ── Teal camera button ───────────────────────────
//               Positioned(
//                 right: 0,
//                 child: _CameraButton(size: btnSize),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  Dark pill label — "Request A Product"
// // ─────────────────────────────────────────────────────────────
// class _RequestLabel extends StatelessWidget {
//   const _RequestLabel();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1A1A),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(30),
//           bottomLeft: Radius.circular(30),
//           topRight: Radius.circular(30),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.18),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Text(
//         'home.request_product'.trns(),
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: AppColors.white,
//           letterSpacing: 0.2,
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  Teal circular camera button
// // ─────────────────────────────────────────────────────────────
// class _CameraButton extends StatelessWidget {
//   const _CameraButton({required this.size});
//   final double size;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: AppColors.primary,
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withValues(alpha: 0.40),
//             blurRadius: 14,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: const Icon(
//         Icons.camera_alt_rounded,
//         color: AppColors.white,
//         size: 20,
//       ),
//     );
//   }
// }



// app/widgets/draggable_request_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';

class DraggableRequestButton extends StatefulWidget {
  const DraggableRequestButton({
    super.key,
    required this.onTap,
    this.initialTop,
    this.initialRight = 16.0,
  });

  final VoidCallback onTap;
  final double? initialTop;
  final double initialRight;

  @override
  State<DraggableRequestButton> createState() =>
      _DraggableRequestButtonState();
}

class _DraggableRequestButtonState
    extends State<DraggableRequestButton>
    with SingleTickerProviderStateMixin {
  // Position state
  late double _top;
  late double _right;

  // Label visibility
  bool _labelVisible = true;

  // Drag state to distinguish tap vs drag
  bool _isDragging = false;
  Offset _dragStartOffset = Offset.zero;

  // Animation controller for label
  late AnimationController _labelController;
  late Animation<double> _labelFade;
  late Animation<double> _labelScale;

  @override
  void initState() {
    super.initState();
    _labelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _labelController.value = 1.0;
    _labelFade = CurvedAnimation(
      parent: _labelController,
      curve: Curves.easeOut,
    );
    _labelScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _labelController, curve: Curves.easeOutBack),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mq = MediaQuery.of(context);
    _top = widget.initialTop ??
        (mq.size.height * 0.38 - mq.padding.top);
    _right = widget.initialRight;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _hideLabel() {
    if (_labelVisible) {
      _labelController.reverse().then((_) {
        if (mounted) setState(() => _labelVisible = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final safeTop = mq.padding.top;
    final safeBottom = mq.padding.bottom;

    const double btnSize = 38.0;
    const double labelEstimatedWidth = 160.0;

    return Positioned(
      top: _top,
      right: _right,
      child: GestureDetector(
        // ── Drag handling ──────────────────────────────────────
        onPanStart: (details) {
          _isDragging = false;
          _dragStartOffset = details.globalPosition;
          // Hide label when drag starts
          if (_labelVisible) _hideLabel();
        },
        onPanUpdate: (details) {
          final delta = details.globalPosition - _dragStartOffset;
          if (delta.distance > 6) _isDragging = true;

          setState(() {
            _top += details.delta.dy;
            _right -= details.delta.dx;

            const double pad = 12.0;
            _top = _top.clamp(
              safeTop + pad,
              screenH - safeBottom - btnSize - pad,
            );
            _right = _right.clamp(
              pad,
              screenW - btnSize - pad,
            );
          });
        },
        onPanEnd: (_) {
          final leftDist = screenW - _right - btnSize;
          final rightDist = _right;
          setState(() {
            _right = rightDist < leftDist ? 16.0 : screenW - btnSize - 16.0;
          });
        },
        // ── Tap: trigger callback ─────────────────────────────
        onTap: () {
          if (!_isDragging) {
            HapticFeedback.lightImpact();
            widget.onTap();
          }
        },

        child: SizedBox(
          width: labelEstimatedWidth + btnSize + 8,
          height: btnSize,
          child: Stack(
            alignment: Alignment.centerRight,
            clipBehavior: Clip.none,
            children: [
              // ── Label (to the left of the button) ────────────
              if (_labelVisible)
                Positioned(
                  right: 17,
                  bottom: 40,
                  child: FadeTransition(
                    opacity: _labelFade,
                    child: ScaleTransition(
                      scale: _labelScale,
                      alignment: Alignment.centerRight,
                      child: _RequestLabel(),
                    ),
                  ),
                ),

              // ── Camera button ───────────────────────────────
              Positioned(
                right: 0,
                child: _CameraButton(size: btnSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Dark pill label — "Request A Product"
// ─────────────────────────────────────────────────────────────
class _RequestLabel extends StatelessWidget {
  const _RequestLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'home.request_product'.trns(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Teal circular camera button
// ─────────────────────────────────────────────────────────────
class _CameraButton extends StatelessWidget {
  const _CameraButton({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.40),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.camera_alt_rounded,
        color: AppColors.white,
        size: 20,
      ),
    );
  }
}