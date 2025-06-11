import 'package:warehouse_receipt/constants/config.dart';

enum ReceiptField {
  // Basic Information
  unit('Đơn vị', 'Vui lòng nhập đơn vị'),
  department('Bộ phận', 'Vui lòng nhập bộ phận'),
  receiptNumber('Số phiếu', 'Vui lòng nhập số phiếu'),
  importDate('Ngày nhập kho', 'Vui lòng chọn ngày nhập kho'),
  isDebit('Có nợ?', 'Vui lòng chọn trạng thái nợ'),

  // Delivery Information
  deliverName('Tên người giao', 'Vui lòng nhập tên người giao'),
  followReference('Theo tham chiếu', 'Vui lòng nhập theo tham chiếu'),
  deliveryNumber('Số phiếu giao hàng', 'Vui lòng nhập số phiếu giao hàng'),
  deliveryDate('Ngày giao hàng', 'Vui lòng chọn ngày giao hàng'),
  deliveryFrom('Của kho', 'Vui lòng nhập của kho nào'),
  warehouseName('Nhập tại kho', 'Vui lòng nhập nhập tại kho nào'),
  warehouseLocation('Địa điểm nhập kho', 'Vui lòng nhập địa điểm nhập kho'),

  // Summary
  totalAmount('Tổng tiền viết bằng chữ', '', maxLength: maxLengthOfNumber),
  totalAmountInWords('Số tiền bằng chữ', 'Vui lòng nhập số tiền bằng chữ', maxLength: maxLengthOfString),
  numberOfOriginalDocs(
      'Số lượng chứng từ gốc', 'Vui lòng nhập số lượng chứng từ gốc', maxLength: maxLengthOfNumber),

  // Signatures
  createdBy('Người lập phiếu', 'Vui lòng nhập tên người lập phiếu'),
  deliveredBy('Người giao hàng', 'Vui lòng nhập tên người giao hàng'),
  warehouseKeeper('Thủ kho', 'Vui lòng nhập tên thủ kho'),
  chiefAccountant('Kế toán trưởng', 'Vui lòng nhập tên kế toán trưởng');

  final String label;
  final String errorMessage;
  final int maxLength;

  const ReceiptField(this.label, this.errorMessage, {this.maxLength = maxLengthOfString});

  bool get isDateField => this == importDate || this == deliveryDate;
  bool get isSwitchField => this == isDebit;
  bool get isNumberField => this == totalAmount || this == numberOfOriginalDocs;
  bool get isCurrencyField => this == totalAmount;
}

enum ReceiptItemField {
  name('Tên vật tư/hàng hóa', 'Vui lòng nhập tên vật tư/hàng hóa', maxLength: maxLengthOfString),
  code('Mã số', 'Vui lòng nhập mã số', maxLength: maxLengthOfString),
  calculateUnit('Đơn vị tính', 'Vui lòng nhập đơn vị tính', maxLength: maxLengthOfString),
  quantityFromDoc('Theo chứng từ', 'Vui lòng nhập số lượng trong chứng từ', maxLength: maxLengthOfNumber),
  quantityActual('Thực nhập', 'Vui lòng nhập số lượng thực tế', maxLength: maxLengthOfNumber),
  unitPrice('Đơn giá', 'Vui lòng nhập đơn giá', maxLength: maxLengthOfNumber),
  totalPrice('Thành tiền', '',);


  final String label;
  final String errorMessage;
  final int maxLength;

  const ReceiptItemField(this.label, this.errorMessage, {this.maxLength = maxLengthOfString});

  bool get isNumberField => this == quantityFromDoc || this == quantityActual || this == unitPrice || this == totalPrice;
  bool get isCurrencyField => this == unitPrice || this == totalPrice;
}