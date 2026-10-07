import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/my_transaction.dart';
import 'add_edit_transaction_screen.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายรับ-รายจ่าย')),
      body: Consumer<TransactionProvider>(
        builder: (context, txProvider, child) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: txProvider.totalBalance >= 0
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Text(
                      'ยอดคงเหลือ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${txProvider.totalBalance.toStringAsFixed(2)} ฿',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: txProvider.totalBalance >= 0
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: txProvider.transactions.isEmpty
                    ? const Center(child: Text('ไม่มีรายการ กด + เพื่อเพิ่ม'))
                    : ListView.builder(
                        itemCount: txProvider.transactions.length,
                        itemBuilder: (ctx, i) {
                          final tx = txProvider.transactions[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: tx.type == TransactionType.income
                                  ? Colors.green
                                  : Colors.red,
                              child: Text(
                                tx.type == TransactionType.income
                                    ? 'รับ'
                                    : 'จ่าย',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(tx.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DateFormat.yMMMd().format(tx.date)),
                                if (tx.note != null && tx.note!.isNotEmpty)
                                  Text(
                                    'Note: ${tx.note}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${tx.amount.toStringAsFixed(2)} ฿',
                                  style: TextStyle(
                                    color: tx.type == TransactionType.income
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => context
                                      .read<TransactionProvider>()
                                      .deleteTransaction(tx.id!),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditTransactionScreen(transaction: tx),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditTransactionScreen(),
            ),
          );
        },
      ),
    );
  }
}
