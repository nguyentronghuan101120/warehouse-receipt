import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:warehouse_receipt/constants/receipt_enum.dart';
import 'package:warehouse_receipt/screens/receipt_form_helper.dart';
import 'package:warehouse_receipt/data/models/receipt.dart';
import 'package:warehouse_receipt/data/models/receipt_item.dart';
import 'package:warehouse_receipt/providers/receipt_provider.dart';
import 'package:warehouse_receipt/utils/currency_formatter.dart';

class CreateReceiptScreen extends StatefulWidget {
  final String? receiptId;

  const CreateReceiptScreen({
    super.key,
    this.receiptId,
  });

  @override
  State<CreateReceiptScreen> createState() => _CreateReceiptScreenState();
}

class _CreateReceiptScreenState extends State<CreateReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _items = <ReceiptItem>[];

  @override
  void initState() {
    super.initState();
    ReceiptFormHelper.initialize();
    if (widget.receiptId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final receipt = context.read<ReceiptProvider>().selectedReceipt;
        if (receipt != null) {
          _prefillForm(receipt);
        }
      });
    }
  }

  void _prefillForm(Receipt receipt) {
    // Pre-fill basic info
    ReceiptFormHelper.controllers[ReceiptField.unit]!.text = receipt.unit;
    ReceiptFormHelper.controllers[ReceiptField.department]!.text =
        receipt.department;
    ReceiptFormHelper.controllers[ReceiptField.receiptNumber]!.text =
        receipt.receiptNumber;
    ReceiptFormHelper.dateValues[ReceiptField.importDate] =
        DateTime.fromMillisecondsSinceEpoch(receipt.importDate);
    ReceiptFormHelper.isDebit = receipt.isDebit;

    // Pre-fill delivery info
    ReceiptFormHelper.controllers[ReceiptField.deliverName]!.text =
        receipt.deliverName;
    ReceiptFormHelper.controllers[ReceiptField.followReference]!.text =
        receipt.followReference;
    ReceiptFormHelper.controllers[ReceiptField.deliveryNumber]!.text =
        receipt.deliveryNumber;
    ReceiptFormHelper.dateValues[ReceiptField.deliveryDate] =
        DateTime.fromMillisecondsSinceEpoch(receipt.deliveryDate);
    ReceiptFormHelper.controllers[ReceiptField.deliveryFrom]!.text =
        receipt.deliveryFrom;
    ReceiptFormHelper.controllers[ReceiptField.warehouseName]!.text =
        receipt.warehouseName;
    ReceiptFormHelper.controllers[ReceiptField.warehouseLocation]!.text =
        receipt.warehouseLocation;

    // Pre-fill summary
    ReceiptFormHelper.controllers[ReceiptField.totalAmount]!.text =
        receipt.totalAmount.toString();
    ReceiptFormHelper.controllers[ReceiptField.totalAmountInWords]!.text =
        receipt.totalAmountInWords;
    ReceiptFormHelper.controllers[ReceiptField.numberOfOriginalDocs]!.text =
        receipt.numberOfOriginalDocs.toString();

    // Pre-fill signatures
    ReceiptFormHelper.controllers[ReceiptField.createdBy]!.text =
        receipt.createdBy;
    ReceiptFormHelper.controllers[ReceiptField.deliveredBy]!.text =
        receipt.deliveredBy;
    ReceiptFormHelper.controllers[ReceiptField.warehouseKeeper]!.text =
        receipt.warehouseKeeper;
    ReceiptFormHelper.controllers[ReceiptField.chiefAccountant]!.text =
        receipt.chiefAccountant;

    // Pre-fill items
    setState(() {
      _items.clear();
      _items.addAll(receipt.items);
    });
  }

  @override
  void dispose() {
    ReceiptFormHelper.dispose();
    super.dispose();
  }

  void _addItem([int? editIndex]) {
    final formKey = GlobalKey<FormState>();
    ReceiptFormHelper.clearItemForm();

    // If editing, pre-fill the form with existing item data
    if (editIndex != null) {
      final item = _items[editIndex];
      ReceiptFormHelper.itemControllers[ReceiptItemField.name]!.text =
          item.title;
      ReceiptFormHelper.itemControllers[ReceiptItemField.code]!.text =
          item.code;
      ReceiptFormHelper.itemControllers[ReceiptItemField.calculateUnit]!.text =
          item.unit;
      ReceiptFormHelper.itemControllers[ReceiptItemField.quantityFromDoc]!
          .text = item.quantityFromDoc.toString();
      ReceiptFormHelper.itemControllers[ReceiptItemField.quantityActual]!.text =
          item.quantityActual.toString();
      ReceiptFormHelper.itemControllers[ReceiptItemField.unitPrice]!.text =
          item.unitPrice.toString();
      ReceiptFormHelper.itemControllers[ReceiptItemField.totalPrice]!.text =
          item.totalPrice.toString();
    }

    showDialog(
      context: context,
      builder: (context) => Form(
        key: formKey,
        child: Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Text(
                        editIndex != null ? 'Chỉnh sửa mục' : 'Thêm mục',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                SliverList.builder(
                  itemCount: ReceiptItemField.values.length,
                  itemBuilder: (context, index) {
                    final field = ReceiptItemField.values[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ReceiptFormHelper.buildItemField(field, context),
                    );
                  },
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Hủy'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final values =
                                    ReceiptFormHelper.getItemValues();
                                final item = ReceiptItem(
                                  id: editIndex != null
                                      ? _items[editIndex].id
                                      : const Uuid().v4(),
                                  index: editIndex != null
                                      ? _items[editIndex].index
                                      : _items.length + 1,
                                  title: values[ReceiptItemField.name]!,
                                  code: values[ReceiptItemField.code]!,
                                  unit: values[ReceiptItemField.calculateUnit]!,
                                  quantityFromDoc: int.tryParse(values[
                                          ReceiptItemField.quantityFromDoc]!) ??
                                      0,
                                  quantityActual: int.tryParse(values[
                                          ReceiptItemField.quantityActual]!) ??
                                      0,
                                  unitPrice: double.tryParse(values[
                                          ReceiptItemField.unitPrice]!) ??
                                      0.0,
                                  totalPrice: double.tryParse(values[
                                          ReceiptItemField.totalPrice]!) ??
                                      0.0,
                                );

                                setState(() {
                                  if (editIndex != null) {
                                    _items[editIndex] = item;
                                  } else {
                                    _items.add(item);
                                  }
                                  ReceiptFormHelper.updateTotalAmount(_items);
                                });
                                Navigator.pop(context);
                              }
                            },
                            child: Text(editIndex != null ? 'Lưu' : 'Thêm'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final receipt = Receipt(
        id: widget.receiptId ?? const Uuid().v4(),
        unit: ReceiptFormHelper.controllers[ReceiptField.unit]!.text,
        department:
            ReceiptFormHelper.controllers[ReceiptField.department]!.text,
        importDate: ReceiptFormHelper
            .dateValues[ReceiptField.importDate]!.millisecondsSinceEpoch,
        receiptNumber:
            ReceiptFormHelper.controllers[ReceiptField.receiptNumber]!.text,
        isDebit: ReceiptFormHelper.isDebit,
        deliverName:
            ReceiptFormHelper.controllers[ReceiptField.deliverName]!.text,
        followReference:
            ReceiptFormHelper.controllers[ReceiptField.followReference]!.text,
        deliveryNumber:
            ReceiptFormHelper.controllers[ReceiptField.deliveryNumber]!.text,
        deliveryDate: ReceiptFormHelper
            .dateValues[ReceiptField.deliveryDate]!.millisecondsSinceEpoch,
        deliveryFrom:
            ReceiptFormHelper.controllers[ReceiptField.deliveryFrom]!.text,
        warehouseName:
            ReceiptFormHelper.controllers[ReceiptField.warehouseName]!.text,
        warehouseLocation:
            ReceiptFormHelper.controllers[ReceiptField.warehouseLocation]!.text,
        items: _items,
        totalAmount: double.parse(
            ReceiptFormHelper.controllers[ReceiptField.totalAmount]!.text),
        totalAmountInWords: ReceiptFormHelper
            .controllers[ReceiptField.totalAmountInWords]!.text,
        numberOfOriginalDocs: int.parse(ReceiptFormHelper
            .controllers[ReceiptField.numberOfOriginalDocs]!.text),
        createdBy: ReceiptFormHelper.controllers[ReceiptField.createdBy]!.text,
        deliveredBy:
            ReceiptFormHelper.controllers[ReceiptField.deliveredBy]!.text,
        warehouseKeeper:
            ReceiptFormHelper.controllers[ReceiptField.warehouseKeeper]!.text,
        chiefAccountant:
            ReceiptFormHelper.controllers[ReceiptField.chiefAccountant]!.text,
      );

      if (widget.receiptId != null) {
        context.read<ReceiptProvider>().updateReceipt(receipt);
        Navigator.pop(context, true);
      } else {
        context.read<ReceiptProvider>().addReceipt(receipt);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiptId != null
            ? 'Chỉnh sửa phiếu'
            : 'Tạo phiếu nhập kho'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: widget.receiptId != null
          ? Consumer<ReceiptProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(provider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              provider.selectReceipt(widget.receiptId!),
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

                return _buildForm();
              },
            )
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Thông tin cơ bản',
            ReceiptFormHelper.getBasicInfoFields(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Thông tin giao hàng',
            ReceiptFormHelper.getDeliveryInfoFields(),
          ),
          const SizedBox(height: 24),
          _buildItemsSection(),
          const SizedBox(height: 24),
          _buildSection(
            'Tổng kết',
            ReceiptFormHelper.getSummaryFields(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Chữ ký',
            ReceiptFormHelper.getSignatureFields(),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child:
                Text(widget.receiptId != null ? 'Lưu thay đổi' : 'Tạo phiếu'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<ReceiptField> fields) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...fields.map((field) {
              return Column(
                children: [
                  ReceiptFormHelper.buildField(field, context),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: const Text(
                    'Bảng chi tiết vật tư/hàng hóa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => _addItem(),
                  icon: const Icon(Icons.add),
                  tooltip: 'Thêm mục',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_items.isEmpty)
              const Center(
                child: Text(
                  'Chưa có mục nào',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Số lượng: ${item.quantityActual}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.totalPrice.toVND(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _addItem(index);
                              } else if (value == 'delete') {
                                setState(() {
                                  _items.removeAt(index);
                                  // Update indices of remaining items
                                  for (var i = index; i < _items.length; i++) {
                                    _items[i] = ReceiptItem(
                                      id: _items[i].id,
                                      index: i + 1,
                                      title: _items[i].title,
                                      code: _items[i].code,
                                      unit: _items[i].unit,
                                      quantityFromDoc:
                                          _items[i].quantityFromDoc,
                                      quantityActual: _items[i].quantityActual,
                                      unitPrice: _items[i].unitPrice,
                                      totalPrice: _items[i].totalPrice,
                                    );
                                  }
                                  ReceiptFormHelper.updateTotalAmount(_items);
                                });
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Chỉnh sửa'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Xóa'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
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
}
