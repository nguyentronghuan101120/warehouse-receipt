⚠️ Bài test này được thực hiện bởi Nguyễn Trọng Huân, chỉ dùng cho mục đích đánh giá tuyển dụng tại Công ty CP Phần mềm Y tế Việt Nam. Mọi hành vi sử dụng lại một phần hay toàn bộ nội dung trong bài test này với mục đích thương mại mà không có sự đồng ý bằng văn bản đều bị nghiêm cấm.

### 🔐 Firebase Configuration

Do lý do bảo mật, tôi không đẩy file cấu hình Firebase (`google-services.json`, `GoogleService-Info.plist`) lên GitHub public.

Nếu cần kiểm thử, tôi có thể gửi trực tiếp file cấu hình qua email hoặc hướng dẫn cài đặt Firebase riêng.

# Hệ Thống Quản Lý Phiếu Nhập Kho

Ứng dụng Flutter để quản lý phiếu nhập kho và theo dõi hàng tồn kho.

Phiên bản web có sẵn tại: https://warehouse-receipt-a9ad9.web.app, có thể truy cập để test nhanh mà không cần build

## Tính Năng

- Tạo và quản lý phiếu nhập kho
- Xem chi tiết và lịch sử phiếu
- Đồng bộ dữ liệu thời gian thực với Firebase
- Giao diện Material Design 3 với thẩm mỹ hiện đại
- Bố cục responsive cho nhiều kích thước màn hình

## Yêu Cầu

- Flutter SDK (phiên bản 3.6.0 trở lên)
- Dart SDK (phiên bản 3.6.0 trở lên)
- Tài khoản và dự án Firebase
- Android Studio / VS Code với các extension Flutter

## Bắt Đầu

1. Clone repository:

```bash
git clone https://github.com/yourusername/warehouse_receipt.git
```

2. Di chuyển vào thư mục dự án:

```bash
cd warehouse_receipt
```

3. Cài đặt các dependencies:

```bash
flutter pub get
```

4. Cấu hình Firebase:

   - Tạo dự án Firebase mới
   - Thêm ứng dụng Android/iOS vào dự án Firebase
   - Tải và thêm các file cấu hình:
     - `google-services.json` cho Android
     - `GoogleService-Info.plist` cho iOS
   - Bật Firestore trong Firebase console

5. Chạy ứng dụng:

```bash
flutter run
```

## Cấu Trúc Dự Án

```
lib/
├── constants/     # Các hằng số và cấu hình toàn cục
├── data/         # Tầng dữ liệu (repositories, data sources)
├── providers/    # Quản lý trạng thái sử dụng Provider
├── screens/      # Các màn hình UI
└── utils/        # Các hàm và công cụ tiện ích
```

## Kiểm Thử

Dự án bao gồm bộ test toàn diện được tổ chức theo cấu trúc sau:

```
test/
├── data/                # Test tầng dữ liệu
│   ├── data_sources/    # Test remote data source
│   └── repositories/    # Test repository implementation
├── mock/               # Dữ liệu và model giả lập
└── providers/          # Test quản lý trạng thái
```

### Thiết Lập Test

- Sử dụng `mockito` để giả lập các dependencies
- Bao gồm dữ liệu giả lập dạng JSON
- Tuân theo phương pháp test phân tầng:
  - Unit test cho providers
  - Integration test cho repositories
  - Unit test cho data sources

### Chạy Test

Để chạy bộ test:

```bash
flutter test
```

Để chạy test với báo cáo độ phủ:

```bash
flutter test --coverage
```

<img width="1193" alt="image" src="https://github.com/user-attachments/assets/9f86d2ef-6f97-4b54-9ff8-519d202d9e9a" />

## Cấu Trúc Cơ Sở Dữ Liệu

Ứng dụng sử dụng Firestore làm cơ sở dữ liệu với cấu trúc sau:

Dựa theo hình ảnh trên phiếu nhập kho, database schema sẽ có dạng như sau

### Receipt Collection

```json
{
  "id": "string", // Id tự sinh
  "unit": "string", // Đơn vị
  "department": "string", // Bộ phận
  "importDate": "timestamp", // Ngày tháng nhập phiếu
  "receiptNumber": "string", // Số phiếu
  "isDebit": "boolean", // Nợ
  "deliverName": "string", // Họ tên người giao
  "followReference": "string", // Theo
  "deliveryNumber": "string", // Số
  "deliveryDate": "timestamp", // Ngày tháng năm
  "deliveryFrom": "string", // Của
  "warehouseName": "string", // Nhập tại kho
  "warehouseLocation": "string", // Địa điểm
  "items": [
    // Array of items
    {
      "id": "string", // ID tự sinh
      "index": "number", // Số thứ tự
      "title": "string", // Tên, nhãn hiệu, quy cách,...
      "code": "string", // Mã số
      "unit": "string", // Đơn vị
      "quantityFromDoc": "number", // Số lượng theo chứng từ
      "quantityActual": "number", // Số lượng thực cấp
      "unitPrice": "number", // Đơn giá
      "totalPrice": "number" // Thành tiền
    }
  ],
  "totalAmount": "number", // Tổng số tiền
  "totalAmountInWords": "string", // Tổng số tiền viết bằng chữ
  "numberOfOriginalDocs": "number", // Số chứng từ gốc kèm theo
  "createdBy": "string", // Người lập phiếu
  "deliveredBy": "string", // Người giao hàng
  "warehouseKeeper": "string", // Thủ kho
  "chiefAccountant": "string" // Kế toán trưởng
}
```

### Tính Năng Chính

- **Định Danh Duy Nhất**: Mỗi phiếu và mục hàng có ID riêng
- **Trường Thời Gian**: Sử dụng Unix timestamp cho ngày tháng
- **Cấu Trúc Lồng Nhau**: Các mục hàng được lưu dưới dạng subcollection trong mỗi phiếu
- **Quy Tắc Xác Thực**:
  - Số lượng phải không âm
  - Tổng tiền được tính từ các mục hàng
  - Tất cả các trường bắt buộc phải có

## Dependencies

- `firebase_core`: ^2.24.2 - Chức năng cốt lõi Firebase
- `cloud_firestore`: ^4.14.0 - Cơ sở dữ liệu Cloud Firestore
- `provider`: ^6.1.5 - Quản lý trạng thái
- `intl`: ^0.20.2 - Quốc tế hóa và định dạng
- `uuid`: ^4.5.1 - Tạo ID duy nhất
