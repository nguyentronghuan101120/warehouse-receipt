import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_receipt/data/models/receipt.dart';
import 'package:warehouse_receipt/providers/receipt_provider.dart';
import 'package:intl/intl.dart';
import 'package:warehouse_receipt/screens/create_receipt_screen.dart';
import 'package:warehouse_receipt/utils/currency_formatter.dart';

class ReceiptDetailScreen extends StatefulWidget {
  final String receiptId;

  const ReceiptDetailScreen({
    super.key,
    required this.receiptId,
  });

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReceiptProvider>();
      // Only load if not already loaded or if selected receipt is different
      if (provider.selectedReceipt?.id != widget.receiptId) {
        provider.selectReceipt(widget.receiptId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết phiếu'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateReceiptScreen(
                    receiptId: widget.receiptId,
                  ),
                ),
              );

              if (result == true) {
                // Refresh data when returning from edit screen
                if (context.mounted) {
                  context
                      .read<ReceiptProvider>()
                      .selectReceipt(widget.receiptId);
                }
              }
            },
          ),
        ],
      ),
      body: Consumer<ReceiptProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.selectReceipt(widget.receiptId),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final receipt = provider.selectedReceipt;
          if (receipt == null) {
            return const Center(
              child: Text('Phiếu không tồn tại'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(receipt),
                const SizedBox(height: 24),
                _buildDeliveryInfo(receipt),
                const SizedBox(height: 24),
                _buildItemsList(receipt),
                const SizedBox(height: 24),
                _buildSummary(receipt),
                const SizedBox(height: 24),
                _buildSignatures(receipt),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Receipt receipt) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phiếu #${receipt.receiptNumber}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: receipt.isDebit
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    receipt.isDebit ? 'Nợ' : 'Không nợ',
                    style: TextStyle(
                      color: receipt.isDebit ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Đơn vị', receipt.unit),
            _buildInfoRow('Phòng ban', receipt.department),
            _buildInfoRow(
              'Ngày nhập',
              DateFormat('dd/MM/yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(receipt.importDate),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo(Receipt receipt) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin giao hàng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Tên giao hàng', receipt.deliverName),
            _buildInfoRow('Follow Reference', receipt.followReference),
            _buildInfoRow('Số giao hàng', receipt.deliveryNumber),
            _buildInfoRow(
              'Ngày giao hàng',
              DateFormat('dd/MM/yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(receipt.deliveryDate),
              ),
            ),
            _buildInfoRow('Từ', receipt.deliveryFrom),
            _buildInfoRow('Tên kho', receipt.warehouseName),
            _buildInfoRow('Vị trí kho', receipt.warehouseLocation),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(Receipt receipt) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danh sách hàng hóa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: receipt.items.length,
              itemBuilder: (context, index) {
                final item = receipt.items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item.title),
                    subtitle: Text('Quantity: ${item.quantityActual}'),
                    trailing: Text(
                      item.unitPrice.toVND(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(Receipt receipt) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng tiền',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Tổng tiền',
              receipt.totalAmount.toVND(),
            ),
            _buildInfoRow(
              'Tổng tiền bằng chữ',
              receipt.totalAmountInWords,
            ),
            _buildInfoRow(
              'Số lượng tài liệu gốc',
              receipt.numberOfOriginalDocs.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatures(Receipt receipt) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chữ ký',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Tạo bởi', receipt.createdBy),
            _buildInfoRow('Giao hàng bởi', receipt.deliveredBy),
            _buildInfoRow('Trưởng kho', receipt.warehouseKeeper),
            _buildInfoRow('Trưởng kế toán', receipt.chiefAccountant),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
