import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/my_transaction.dart';
import '../providers/transaction_provider.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final MyTransaction? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _amount;
  late DateTime _selectedDate;
  late TransactionType _type;
  String? _note; // ตัวแปรสำหรับเก็บ Note

  @override
  void initState() {
    super.initState();
    _title = widget.transaction?.title ?? '';
    _amount = widget.transaction?.amount ?? 0.0;
    _selectedDate = widget.transaction?.date ?? DateTime.now();
    _type = widget.transaction?.type ?? TransactionType.expense;
    _note = widget.transaction?.note; // โหลดข้อมูล Note เดิม (ถ้ามี)
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final provider = context.read<TransactionProvider>();

    if (widget.transaction == null) {
      // เพิ่มรายการใหม่ พร้อมส่ง note
      provider.addTransaction(
        _title,
        _amount,
        _selectedDate,
        _type,
        note: _note,
      );
    } else {
      // แก้ไขรายการเดิม พร้อมอัปเดต note
      final updatedTx = MyTransaction(
        id: widget.transaction!.id,
        title: _title,
        amount: _amount,
        date: _selectedDate,
        type: _type,
        note: _note,
      );
      provider.updateTransaction(widget.transaction!.id!, updatedTx);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'เพิ่มรายการ' : 'แก้ไขรายการ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'ชื่อรายการ'),
                validator: (value) =>
                    value!.isEmpty ? 'กรุณาใส่ชื่อรายการ' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _amount == 0 ? '' : _amount.toString(),
                decoration: const InputDecoration(labelText: 'จำนวนเงิน'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty || double.tryParse(value) == null
                    ? 'กรุณาใส่ตัวเลขที่ถูกต้อง'
                    : null,
                onSaved: (value) => _amount = double.parse(value!),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'วันที่: ${DateFormat.yMd().format(_selectedDate)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: const Text('เลือกวันที่'),
                  ),
                ],
              ),
              DropdownButtonFormField<TransactionType>(
                value: _type,
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text('รายจ่าย'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text('รายรับ'),
                  ),
                ],
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: 10),

              // กล่องสำหรับกรอก Note ที่เพิ่มเข้ามาใหม่
              TextFormField(
                initialValue: _note,
                decoration: const InputDecoration(
                  labelText: 'บันทึกเพิ่มเติม (Note)',
                ),
                onSaved: (value) => _note = value,
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('บันทึกข้อมูล'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
