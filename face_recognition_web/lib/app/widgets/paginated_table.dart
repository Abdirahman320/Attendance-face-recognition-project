import 'package:data_table_2/data_table_2.dart';
import 'package:face_recognition_web/app/utils/constants/Sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TPaginatedDataTable extends StatelessWidget {
  const TPaginatedDataTable({
    super.key,
    required this.columns,
    required this.source,
    this.rowsPerPage = 10,
    this.tableHeight = 760,
    this.onPageChanged,
    this.sortColumnIndex,
    this.dataRowHeight = TSizes.xl * 2,
    this.sortAscending = true,
    this.minWidth = 1000,
  });

  final List<DataColumn> columns;
  final DataTableSource source;
  final int rowsPerPage;
  final double tableHeight;
  final Function(int)? onPageChanged;
  final int? sortColumnIndex;
  final double dataRowHeight;
  final bool sortAscending;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: tableHeight,
      child: Theme(
        data: Theme.of(context).copyWith(
          cardTheme: const CardTheme(color: Colors.white, elevation: 0),
        ),
        child: PaginatedDataTable2(
          columnSpacing: 8,
          minWidth: minWidth,
          dividerThickness: 0,
          horizontalMargin: 12,
          dataRowHeight: dataRowHeight,
          rowsPerPage: rowsPerPage,
          availableRowsPerPage: [5, 7, 10, 20, 50],
          headingTextStyle: Theme.of(context).textTheme.titleMedium,
          headingRowColor: WidgetStateProperty.resolveWith(
            (states) => Colors.blueAccent.withOpacity(0.1),
          ),
          headingRowDecoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(TSizes.borderRadiusMd),
              topRight: Radius.circular(TSizes.borderRadiusMd),
            ),
          ),
          showCheckboxColumn: true,
          showFirstLastButtons: true,
          renderEmptyRowsInTheEnd: false,
          onPageChanged: onPageChanged,
          onRowsPerPageChanged: (noOfRows) {},
          sortAscending: sortAscending,
          sortArrowAlwaysVisible: true,
          sortArrowIcon: Icons.line_axis,
          sortColumnIndex: sortColumnIndex,
          sortArrowBuilder: (bool ascending, bool sorted) {
            if (sorted) {
              return Icon(
                ascending ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                size: TSizes.iconSm,
              );
            } else {
              return const Icon(Iconsax.arrow_3, size: TSizes.iconSm);
            }
          },
          columns: columns,
          source: source,
        ),
      ),
    );
  }
}
