import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
// share_plus removed to avoid KGP warning

class ExcelService {
  /// Sinh file mẫu Excel (Template) và lưu vào bộ nhớ.
  static Future<String?> downloadTemplate() async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];

      // Header
      sheet.appendRow([
        TextCellValue('Kanji'),
        TextCellValue('Hiragana (*)'),
        TextCellValue('Romaji'),
        TextCellValue('Meaning (*)'),
        TextCellValue('Example'),
        TextCellValue('Audio URL'),
      ]);

      // Sample data
      sheet.appendRow([
        TextCellValue('私'),
        TextCellValue('わたし'),
        TextCellValue('watashi'),
        TextCellValue('tôi'),
        TextCellValue('私は学生です。'),
        TextCellValue(''),
      ]);

      var fileBytes = excel.save();
      if (fileBytes != null) {
        String? outputFile = await FilePicker.saveFile(
          dialogTitle: 'Lưu file Excel mẫu',
          fileName: 'Word_Import_Template.xlsx',
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
          bytes: Uint8List.fromList(fileBytes),
        );

        if (outputFile != null) {
          // file_picker with `bytes` handles the writing natively on Android/iOS/Web
          // If the platform doesn't handle writing via bytes (like older desktop configs), we might need to write manually, but modern file_picker does.
          // To be absolutely safe for desktop, we check if outputFile is a path and write it if needed, but on Android content URIs are handled.
          if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
            final file = File(outputFile);
            await file.writeAsBytes(fileBytes);
          }
          return outputFile;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cho phép người dùng chọn file và trả về danh sách JSON (Map).
  /// Nếu có lỗi về format, sẽ ném ra Exception với thông báo cụ thể.
  static Future<List<Map<String, dynamic>>?> pickAndParseExcel() async {
    try {
      // Xóa toàn bộ cache ảo của hệ thống (Android/iOS) để tránh lỗi nhận nhầm file cũ/file 0 bytes
      await FilePicker.clearTemporaryFiles();

      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result == null || result.files.single.path == null) {
        return null; // Người dùng hủy chọn file
      }

      var bytes = File(result.files.single.path!).readAsBytesSync();

      // Kiểm tra xem file có đúng định dạng ZIP/XLSX không (phải bắt đầu bằng signature 'PK')
      if (bytes.length < 4 ||
          bytes[0] != 80 ||
          bytes[1] != 75 ||
          bytes[2] != 3 ||
          bytes[3] != 4) {
        String prefixText = '';
        try {
          prefixText = String.fromCharCodes(
            bytes.take(20).map((e) => e >= 32 && e <= 126 ? e : 46),
          );
        } catch (_) {}
        throw Exception(
          'Lỗi định dạng: File XLSX không hợp lệ (Size: ${bytes.length} bytes, Header: $prefixText...).\\n'
          'Có thể bạn đã lưu file dưới dạng CSV/XLS và tự đổi đuôi thành .xlsx, hoặc phần mềm bạn dùng để sửa file (vd: WPS/Google Sheets) lưu sai định dạng.\\n'
          '-> CÁCH SỬA: Mở lại file đó bằng Microsoft Excel -> Chọn File -> Save As -> BẮT BUỘC chọn định dạng "Excel Workbook (*.xlsx)" -> Lưu ra 1 file mới.',
        );
      }

      var excel = Excel.decodeBytes(bytes);

      // Đọc từ Sheet đầu tiên
      var sheetName = excel.tables.keys.first;
      var table = excel.tables[sheetName];

      if (table == null || table.rows.length <= 1) {
        throw Exception('File Excel rỗng hoặc không đúng định dạng.');
      }

      List<Map<String, dynamic>> words = [];

      // Bỏ qua dòng 0 (Header)
      for (int i = 1; i < table.rows.length; i++) {
        var row = table.rows[i];
        // Đảm bảo row có đủ 6 cột, nếu thiếu thì đệm null
        while (row.length < 6) {
          row.add(null);
        }

        String kanji = row[0]?.value?.toString().trim() ?? '';
        String hiragana = row[1]?.value?.toString().trim() ?? '';
        String romaji = row[2]?.value?.toString().trim() ?? '';
        String meaning = row[3]?.value?.toString().trim() ?? '';
        String example = row[4]?.value?.toString().trim() ?? '';
        String audioUrl = row[5]?.value?.toString().trim() ?? '';

        // Theo Rule 3: Nếu thiếu cả hai Hiragana VÀ Meaning -> Bỏ qua dòng
        if (hiragana.isEmpty && meaning.isEmpty) {
          continue;
        }

        // Bắt buộc: Phải có Hiragana và Meaning
        if (hiragana.isEmpty || meaning.isEmpty) {
          throw Exception(
            'Lỗi ở dòng ${i + 1}: Hiragana và Meaning không được để trống.',
          );
        }

        words.add({
          'kanji': kanji,
          'hiragana': hiragana,
          'romaji': romaji,
          'meaning': meaning,
          'example': example,
          'audioUrl': audioUrl,
        });
      }

      if (words.isEmpty) {
        throw Exception('Không tìm thấy từ vựng hợp lệ nào trong file.');
      }

      return words;
    } catch (e) {
      if (e.toString().contains(
        'Unsupported operation: Excel format unsupported',
      )) {
        throw Exception(
          'Định dạng file không được hỗ trợ. Vui lòng đảm bảo file được lưu dưới dạng chuẩn Excel Workbook (.xlsx) chứ không phải .xls hay .csv đổi đuôi.',
        );
      }
      rethrow;
    }
  }
}
