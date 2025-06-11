import 'package:flutter/material.dart';
import 'package:warehouse_receipt/constants/receipt_enum.dart';
import 'package:warehouse_receipt/data/models/receipt_item.dart';
import 'package:warehouse_receipt/utils/currency_formatter.dart';

class ReceiptFormHelper {
  // Receipt Form Controllers
  static Map<ReceiptField, TextEditingController> controllers = {};
  static Map<ReceiptItemField, TextEditingController> itemControllers = {};

  static void initialize() {
    // Initialize receipt controllers
    controllers = {
      for (var field in ReceiptField.values) field: TextEditingController()
    };

    // Initialize item controllers
    itemControllers = {
      for (var field in ReceiptItemField.values) field: TextEditingController()
    };
  }

  static final Map<ReceiptField, DateTime> dateValues = {
    ReceiptField.importDate: DateTime.now(),
    ReceiptField.deliveryDate: DateTime.now(),
  };

  static bool isDebit = false;

  static void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    for (var controller in itemControllers.values) {
      controller.dispose();
    }
    controllers.clear();
    itemControllers.clear();
  }

  // Receipt Form Methods
  static Widget buildField(ReceiptField field, BuildContext context) {
    if (field.isDateField) {
      return InkWell(
        onTap: () async {
          final newDate = await _selectDate(context, field);
          if (newDate != null) {
            dateValues[field] = newDate;
            (context as Element).markNeedsBuild();
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            _formatDate(dateValues[field]!),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    if (field == ReceiptField.isDebit) {
      return SwitchListTile(
        title: Text(field.label),
        subtitle: Text(isDebit ? 'Nợ' : 'Không'),
        value: isDebit,
        onChanged: (value) {
          isDebit = value;
          (context as Element).markNeedsBuild();
        },
      );
    }

    if (field == ReceiptField.totalAmount) {
      return ListTile(
        title: Text(
          field.label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          (double.tryParse(controllers[field]?.text ?? '0') ?? 0).toVND(),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.blue,
          ),
        ),
      );
    }

    if (field == ReceiptField.totalAmountInWords) {
      return ListTile(
        title: Text(
          field.label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          controllers[field]?.text ?? '',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.blue,
          ),
        ),
      );
    }

    return TextFormField(
      controller: controllers[field],
      decoration: InputDecoration(
        labelText: field.label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType:
          field.isNumberField ? TextInputType.number : TextInputType.text,
      maxLength: field.maxLength,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return field.errorMessage;
        }
        if (field.isNumberField) {
          final number = double.tryParse(value);
          if (number == null) {
            return 'Vui lòng nhập số hợp lệ';
          }
        }
        return null;
      },
    );
  }

  static Future<DateTime?> _selectDate(
      BuildContext context, ReceiptField field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateValues[field]!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    return picked;
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static Map<ReceiptField, String> getValues() {
    return {
      for (var field in ReceiptField.values)
        if (!field.isDateField) field: controllers[field]?.text ?? ''
    };
  }

  static void clear() {
    for (var controller in controllers.values) {
      controller.clear();
    }
    dateValues[ReceiptField.importDate] = DateTime.now();
    dateValues[ReceiptField.deliveryDate] = DateTime.now();
    isDebit = false;
  }

  // Receipt Item Form Methods
  static Widget buildItemField(ReceiptItemField field, BuildContext context) {
    if (field == ReceiptItemField.totalPrice) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                (double.tryParse(itemControllers[ReceiptItemField.totalPrice]
                                ?.text ??
                            '0') ??
                        0)
                    .toVND(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return TextFormField(
      controller: itemControllers[field],
      decoration: InputDecoration(
        labelText: field.label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType:
          field.isNumberField ? TextInputType.number : TextInputType.text,
      maxLength: field.maxLength,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return field.errorMessage;
        }
        if (field.isNumberField) {
          final number = double.tryParse(value);
          if (number == null) {
            return 'Vui lòng nhập số hợp lệ';
          }
        }
        return null;
      },
      onChanged: (value) {
        if (field == ReceiptItemField.quantityActual ||
            field == ReceiptItemField.unitPrice) {
          _calculateTotalPrice();
          // Force rebuild to update the total price display
          (context as Element).markNeedsBuild();
        }
      },
    );
  }

  static void _calculateTotalPrice() {
    final quantity = double.tryParse(
            itemControllers[ReceiptItemField.quantityActual]?.text ?? '0') ??
        0;
    final unitPrice = double.tryParse(
            itemControllers[ReceiptItemField.unitPrice]?.text ?? '0') ??
        0;
    final totalPrice = quantity * unitPrice;
    itemControllers[ReceiptItemField.totalPrice]?.text =
        totalPrice.toStringAsFixed(2);
  }

  static Map<ReceiptItemField, String> getItemValues() {
    return {
      for (var field in ReceiptItemField.values)
        field: itemControllers[field]?.text ?? ''
    };
  }

  static void clearItemForm() {
    for (var controller in itemControllers.values) {
      controller.clear();
    }
  }

  static List<ReceiptField> getBasicInfoFields() => [
        ReceiptField.unit,
        ReceiptField.department,
        ReceiptField.receiptNumber,
        ReceiptField.importDate,
        ReceiptField.isDebit,
      ];

  static List<ReceiptField> getDeliveryInfoFields() => [
        ReceiptField.deliverName,
        ReceiptField.followReference,
        ReceiptField.deliveryNumber,
        ReceiptField.deliveryDate,
        ReceiptField.deliveryFrom,
        ReceiptField.warehouseName,
        ReceiptField.warehouseLocation,
      ];

  static List<ReceiptField> getSummaryFields() => [
        ReceiptField.totalAmount,
        ReceiptField.totalAmountInWords,
        ReceiptField.numberOfOriginalDocs,
      ];

  static List<ReceiptField> getSignatureFields() => [
        ReceiptField.createdBy,
        ReceiptField.deliveredBy,
        ReceiptField.warehouseKeeper,
        ReceiptField.chiefAccountant,
      ];

  static void updateTotalAmount(List<ReceiptItem> items) {
    double total = 0;
    for (var item in items) {
      total += item.totalPrice;
    }
    controllers[ReceiptField.totalAmount]?.text = total.toStringAsFixed(2);
    controllers[ReceiptField.totalAmountInWords]?.text = _numberToWords(total);
  }

/*
 * Hàm _numberToWords chuyển đổi số tiền (dưới dạng double) thành chữ tiếng Việt.
 * Ví dụ:
 *   - 96000      -> "chín mươi sáu nghìn đồng"
 *   - 101203202  -> "một trăm linh một triệu hai trăm linh ba nghìn hai trăm linh hai đồng"
 *
 * Cách hoạt động:
 * 1. Tách số thành từng nhóm 3 chữ số từ phải sang trái (hàng đơn vị, nghìn, triệu, tỷ).
 *    Ví dụ: 101203202 => [101, 203, 202]
 *
 * 2. Dùng hàm readThreeDigits để đọc từng nhóm 3 chữ số:
 *    - Đọc hàng trăm, chục, đơn vị theo đúng ngữ pháp tiếng Việt.
 *    - Xử lý các trường hợp đặc biệt:
 *        + Số 1 => "mốt" khi ở cuối (21 → hai mươi mốt)
 *        + Số 5 => "lăm" khi ở cuối (15 → mười lăm)
 *        + Thêm từ "linh" khi hàng chục là 0 và đơn vị > 0 (205 → hai trăm linh năm)
 *        + Nếu nhóm không phải nhóm đầu tiên và có số < 100 thì vẫn phải thêm "không trăm" (để không mất nhịp)
 *
 * 3. Ghép các nhóm lại với đơn vị tương ứng:
 *    - [triệu], [nghìn], [đồng]
 *    Ví dụ: [101, 203, 202] → "một trăm linh một triệu hai trăm linh ba nghìn hai trăm linh hai đồng"
 *
 * 4. Nếu có phần thập phân (sau dấu phẩy), thì đọc như "phẩy ..."
 *
 * Trả về chuỗi kết quả cuối cùng kèm "đồng" ở cuối.
 */
  static String _numberToWords(double number) {
    if (number == 0) return 'không đồng';

    final units = [
      '',
      'một',
      'hai',
      'ba',
      'bốn',
      'năm',
      'sáu',
      'bảy',
      'tám',
      'chín'
    ];
    final scaleUnits = ['', 'nghìn', 'triệu', 'tỷ'];

    String readThreeDigits(int number, bool isFirstGroup) {
      int hundred = number ~/ 100;
      int ten = (number % 100) ~/ 10;
      int unit = number % 10;
      String result = '';

      if (hundred > 0) {
        result += '${units[hundred]} trăm';
      } else if (!isFirstGroup && (ten > 0 || unit > 0)) {
        result += 'không trăm';
      }

      if (ten > 1) {
        result += ' ${units[ten]} mươi';
        if (unit == 1) {
          result += ' mốt';
        } else if (unit == 5) {
          result += ' lăm';
        } else if (unit > 0) {
          result += ' ${units[unit]}';
        }
      } else if (ten == 1) {
        result += ' mười';
        if (unit == 5) {
          result += ' lăm';
        } else if (unit > 0) {
          result += ' ${units[unit]}';
        }
      } else if (unit > 0) {
        if (hundred > 0 || !isFirstGroup) {
          result += ' linh ${units[unit]}';
        } else {
          result += ' ${units[unit]}';
        }
      }

      return result.trim();
    }

    int wholeNumber = number.floor();
    int decimal = ((number - wholeNumber) * 100).round();
    List<String> parts = [];

    int group = 0;
    bool isFirstGroup = true;
    while (wholeNumber > 0) {
      int threeDigits = wholeNumber % 1000;
      if (threeDigits > 0 || group == 0) {
        String words = readThreeDigits(threeDigits, isFirstGroup);
        if (scaleUnits.length > group && scaleUnits[group].isNotEmpty) {
          words += ' ${scaleUnits[group]}';
        }
        parts.insert(0, words);
      }
      wholeNumber ~/= 1000;
      group++;
      isFirstGroup = false;
    }

    String result = parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();

    if (decimal > 0) {
      result += ' phẩy';
      if (decimal < 10) {
        result += ' ${units[decimal]}';
      } else {
        result += ' ${readThreeDigits(decimal, true)}';
      }
    }

    return '$result đồng';
  }
}
