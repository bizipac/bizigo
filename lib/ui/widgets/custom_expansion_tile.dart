import 'package:flutter/material.dart';

// class ExpandableFormSection extends StatefulWidget {
//   final String title;
//   final Widget child;
//
//   final bool initiallyExpanded;
//   final ValueChanged<bool>? onExpansionChanged;
//
//   const ExpandableFormSection({
//     super.key,
//     required this.title,
//     required this.child,
//     this.initiallyExpanded = false,
//     this.onExpansionChanged,
//   });
//
//   @override
//   State<ExpandableFormSection> createState() =>
//       _ExpandableFormSectionState();
// }
//
// class _ExpandableFormSectionState extends State<ExpandableFormSection> {
//   late bool _isExpanded;
//
//   @override
//   void initState() {
//     super.initState();
//     _isExpanded = widget.initiallyExpanded;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ExpansionTile(
//       key: ValueKey(widget.initiallyExpanded),
//       initiallyExpanded: widget.initiallyExpanded,
//       onExpansionChanged: (val) {
//         setState(() {
//           _isExpanded = val;
//         });
//
//         if (widget.onExpansionChanged != null) {
//           widget.onExpansionChanged!(val);
//         }
//       },
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//         side: BorderSide(color: Colors.grey.shade300),
//       ),
//       collapsedShape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//         side: BorderSide(color: Colors.grey.shade300),
//       ),
//       collapsedBackgroundColor: Colors.white,
//       title: Text(
//         widget.title,
//         style: const TextStyle(
//           fontFamily: 'Poppins',
//           fontSize: 15,
//           fontWeight: FontWeight.w400,
//         ),
//       ),
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: widget.child,
//         ),
//       ],
//     );
//   }
// }
class ExpandableFormSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  const ExpandableFormSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  });

  @override
  State<ExpandableFormSection> createState() =>
      _ExpandableFormSectionState();
}

class _ExpandableFormSectionState
    extends State<ExpandableFormSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant ExpandableFormSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// sync when parent forces expansion
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _isExpanded = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (val) {
        setState(() => _isExpanded = val);

        widget.onExpansionChanged?.call(val);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      collapsedBackgroundColor: Colors.white,
      title: Text(
        widget.title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.child,
        ),
      ],
    );
  }
}