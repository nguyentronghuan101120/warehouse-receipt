import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_receipt/providers/receipt_provider.dart';
import 'package:warehouse_receipt/screens/receipt_detail_screen.dart';
import 'package:warehouse_receipt/screens/create_receipt_screen.dart';
import 'package:intl/intl.dart';
import 'package:warehouse_receipt/utils/currency_formatter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedReceiptIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ReceiptProvider>(context, listen: false);
      // Only load if receipts list is empty
      if (provider.receipts.isEmpty) {
        provider.loadReceipts();
      }
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedReceiptIds.clear();
      }
    });
  }

  void _toggleReceiptSelection(String receiptId) {
    setState(() {
      if (_selectedReceiptIds.contains(receiptId)) {
        _selectedReceiptIds.remove(receiptId);
      } else {
        _selectedReceiptIds.add(receiptId);
      }
    });
  }

  void _deleteSelectedReceipts(BuildContext context, ReceiptProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
            'Bạn có chắc chắn muốn xóa ${_selectedReceiptIds.length} phiếu đã chọn không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              for (final id in _selectedReceiptIds) {
                provider.deleteReceipt(id);
              }
              _toggleSelectionMode();
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phiếu nhập kho'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (!_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _toggleSelectionMode,
              tooltip: 'Chọn nhiều phiếu',
            )
          else ...[
            if (_selectedReceiptIds.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteSelectedReceipts(
                    context, context.read<ReceiptProvider>()),
                tooltip: 'Xóa các phiếu đã chọn',
              ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleSelectionMode,
              tooltip: 'Hủy chọn',
            ),
          ],
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
                    onPressed: () => provider.loadReceipts(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (provider.receipts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Không có phiếu nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateReceiptScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm phiếu mới'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadReceipts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.receipts.length,
              itemBuilder: (context, index) {
                final receipt = provider.receipts[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: _isSelectionMode
                        ? () => _toggleReceiptSelection(receipt.id)
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReceiptDetailScreen(
                                  receiptId: receipt.id,
                                ),
                              ),
                            );
                          },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    if (_isSelectionMode)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: Checkbox(
                                          value: _selectedReceiptIds
                                              .contains(receipt.id),
                                          onChanged: (_) =>
                                              _toggleReceiptSelection(
                                                  receipt.id),
                                        ),
                                      ),
                                    Expanded(
                                      child: Text(
                                        'Phiếu #${receipt.receiptNumber}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: receipt.isDebit
                                      ? Colors.red.withValues(alpha: 0.1)
                                      : Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  receipt.isDebit ? 'Nợ' : 'Không nợ',
                                  style: TextStyle(
                                    color: receipt.isDebit
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Đơn vị: ${receipt.unit}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Phòng ban: ${receipt.department}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ngày nhập: ${DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(receipt.importDate))}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tổng tiền: ${receipt.totalAmount.toVND()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!_isSelectionMode)
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Xác nhận xóa'),
                                            content: const Text(
                                                'Bạn có chắc chắn muốn xóa phiếu này không?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Hủy'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  provider.deleteReceipt(
                                                      receipt.id);
                                                },
                                                child: const Text('Xóa',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    const Icon(Icons.arrow_forward_ios,
                                        size: 16),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: !_isSelectionMode
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateReceiptScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm phiếu mới'),
            )
          : null,
    );
  }
}
