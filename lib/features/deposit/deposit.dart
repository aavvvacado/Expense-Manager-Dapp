import 'package:expensetreckerdapp/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:expensetreckerdapp/models/transaction_model.dart';
import 'package:flutter/material.dart';

class DepositPage extends StatefulWidget {
  final DashboardBloc dashboardBloc;
  const DepositPage({super.key, required this.dashboardBloc});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController reasonsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A), // dark theme background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.cyanAccent, Colors.purpleAccent],
          ).createShader(bounds),
          child: const Text(
            "Deposit",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              "Deposit Details",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Address
            // _buildInputField(
            //   controller: addressController,
            //   hint: "Enter Wallet Address",
            //   icon: Icons.account_balance_wallet,
            // ),
            const SizedBox(height: 16),

            // Amount
            _buildInputField(
              controller: amountController,
              hint: "Enter Amount (ETH)",
              icon: Icons.currency_bitcoin,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Reason
            _buildInputField(
              controller: reasonsController,
              hint: "Enter Reason",
              icon: Icons.text_fields,
            ),
            const SizedBox(height: 32),

            // Deposit Button
            Center(
              child: GestureDetector(
                onTap: () {
                  widget.dashboardBloc.add(DashboardDepositEvent(
                    transactionModel: TransactionModel(
                      addressController.text,
                      int.tryParse(amountController.text) ?? 0,
                      reasonsController.text,
                      DateTime.now(),
                      TransactionType.deposit,
                    ),
                  ));
                  Navigator.pop(context);
                },
                child: Container(
                  width: screenWidth > 500 ? 400 : double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Colors.greenAccent, Colors.teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.5),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "+ DEPOSIT",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [Colors.grey.shade900, Colors.grey.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.cyanAccent),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
