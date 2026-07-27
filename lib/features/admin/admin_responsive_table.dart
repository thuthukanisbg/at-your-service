import 'package:flutter/material.dart';

/// Makes an admin [DataTable] fill the available desktop workspace while
/// retaining horizontal scrolling when its intrinsic columns need more room.
class AdminResponsiveDataTable extends StatelessWidget {
  const AdminResponsiveDataTable({required this.table, super.key});

  final DataTable table;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth),
            child: table,
          ),
        );
      },
    );
  }
}
