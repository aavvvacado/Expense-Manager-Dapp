import 'package:expensetreckerdapp/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:expensetreckerdapp/models/transaction_model.dart';
import 'package:flutter/material.dart';

class WithdrawPage extends StatefulWidget {
  final DashboardBloc dashboardBloc;
  const WithdrawPage({super.key, required this.dashboardBloc});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController reasonsController = TextEditingController();

  Widget _buildInputField({
    required IconData icon,
    required String hint,
    TextEditingController? controller,
    TextInputType? type,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: Colors.cyanAccent, size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.cyanAccent, Colors.greenAccent],
          ).createShader(bounds),
          child: const Text(
            "Withdraw",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Withdraw Details",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),

            // Amount
            _buildInputField(
              icon: Icons.currency_bitcoin,
              hint: "Enter Amount (ETH)",
              controller: amountController,
              type: TextInputType.number,
            ),
            const SizedBox(height: 18),

            // Reason
            _buildInputField(
              icon: Icons.text_fields,
              hint: "Enter Reason",
              controller: reasonsController,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),

      // Floating neon Withdraw button
      floatingActionButton: GestureDetector(
        onTap: () {
          widget.dashboardBloc.add(
            DashboardWithdrawEvent(
              transactionModel: TransactionModel(
                addressController.text,
                int.tryParse(amountController.text) ?? 0,
                reasonsController.text,
                DateTime.now(),
                TransactionType.withdrawal,
              ),
            ),
          );
          Navigator.pop(context);
        },
        child: Container(
          width: size.width * 0.9,
          height: 60,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Colors.cyanAccent, Colors.greenAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "- WITHDRAW",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
