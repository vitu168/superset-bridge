import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

class SupersetExcelTemplate {
  SupersetExcelTemplate._();
  static Uint8List build({
    required List<Map<String, dynamic>> rows,
    String? sheetTitle,
    String? fileName,
    String createdBy = '',
    bool isDarkTheme = false,
  }) {
    final excel = Excel.createExcel();
    final name = sheetTitle ?? 'Report';

    // The default workbook contains Sheet1 – rename it instead of adding a new
    // sheet so we do not end up with a stray empty tab.
    excel.rename('Sheet1', name);
    final sheet = excel[name];

    if (rows.isEmpty) {
      sheet.appendRow([TextCellValue('No data available')]);
      return Uint8List.fromList(excel.encode()!);
    }

    final columnNames = rows.first.keys.toList();

    // ── Styles ──────────────────────────────────────────────────────────────
    final headerBgColor = ExcelColor.fromHexString(
      isDarkTheme ? '#1E293B' : '#2563EB',
    );
    final headerStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: headerBgColor,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final evenRowStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString(
        isDarkTheme ? '#2D3748' : '#F8FAFC',
      ),
    );
    final metaStyle = CellStyle(bold: true);

    // ── Metadata rows ────────────────────────────────────────────────────────
    int rowIndex = 0;

    void writeMeta(String text) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex++));
      cell.value = TextCellValue(text);
      cell.cellStyle = metaStyle;
    }

    if (fileName != null) writeMeta('File: $fileName');
    if (sheetTitle != null) writeMeta('Title: $sheetTitle');
    writeMeta(
        'Created: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
    if (createdBy.isNotEmpty) writeMeta('Created by: $createdBy');
    rowIndex++; // blank separator

    // ── Column header row ────────────────────────────────────────────────────
    for (var col = 0; col < columnNames.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex),
      );
      cell.value = TextCellValue(columnNames[col]);
      cell.cellStyle = headerStyle;
    }

    // ── Data rows ────────────────────────────────────────────────────────────
    for (var r = 0; r < rows.length; r++) {
      for (var col = 0; col < columnNames.length; col++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(
              columnIndex: col, rowIndex: rowIndex + 1 + r),
        );
        cell.value = _toCellValue(rows[r][columnNames[col]]);
        if (r.isEven) cell.cellStyle = evenRowStyle;
      }
    }

    // ── Auto-width ────────────────────────────────────────────────────────
    for (var col = 0; col < columnNames.length; col++) {
      sheet.setColumnWidth(
          col, _estimateColumnWidth(columnNames[col], rows, col));
    }

    return Uint8List.fromList(excel.encode()!);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static CellValue _toCellValue(dynamic value) {
    if (value == null) return TextCellValue('');
    if (value is int) return IntCellValue(value);
    if (value is double) return DoubleCellValue(value);
    if (value is bool) return TextCellValue(value ? 'Yes' : 'No');
    return TextCellValue(value.toString());
  }

  static double _estimateColumnWidth(
    String header,
    List<Map<String, dynamic>> rows,
    int colIndex,
  ) {
    final keys = rows.isNotEmpty ? rows.first.keys.toList() : <String>[];
    if (colIndex >= keys.length) return 15;
    final key = keys[colIndex];
    var maxLen = header.length;
    for (final row in rows.take(20)) {
      final len = (row[key]?.toString() ?? '').length;
      if (len > maxLen) maxLen = len;
    }
    return (maxLen + 4).clamp(10, 50).toDouble();
  }
}
