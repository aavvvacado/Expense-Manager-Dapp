import 'dart:math';

import 'package:expensetreckerdapp/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:expensetreckerdapp/features/deposit/deposit.dart';
import 'package:expensetreckerdapp/features/withdraw/withdraw.dart';
import 'package:expensetreckerdapp/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final DashboardBloc dashboardBloc = DashboardBloc();

  // For small interactive tilt on cards
  double _tiltX = 0.0, _tiltY = 0.0;
  // Animation controller for subtle background movement
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    dashboardBloc.add(DashboardInitialFechEvent());
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    dashboardBloc.close();
    super.dispose();
  }

  // handle touch for tilt (normalized)
  void _handlePan(Offset localPos, Size size) {
    final dx = (localPos.dx - size.width / 2) / (size.width / 2);
    final dy = (localPos.dy - size.height / 2) / (size.height / 2);
    setState(() {
      _tiltY = dx.clamp(-0.6, 0.6);
      _tiltX = dy.clamp(-0.6, 0.6);
    });
  }

  void _resetTilt() {
    setState(() {
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
  }

  // helper to create neon-like shadow
  List<BoxShadow> neon(Color c, {double blur = 24, double spread = 2}) => [
        BoxShadow(
            color: c.withOpacity(0.12), blurRadius: blur, spreadRadius: spread),
        BoxShadow(
            color: c.withOpacity(0.06),
            blurRadius: blur * 2,
            spreadRadius: spread * 2),
      ];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isWide = mq.size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFF070712),
      body: SafeArea(
        child: Stack(
          children: [
            // animated gradient background blobs (subtle)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bgController,
                builder: (context, child) {
                  final v = _bgController.value;
                  return CustomPaint(
                    painter: _BackgroundPainter(v),
                    child: const SizedBox.expand(),
                  );
                },
              ),
            ),

            // main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                children: [
                  // Top bar / Title row
                  Row(
                    children: [
                      // left spacer for wide layout
                      if (isWide) const SizedBox(width: 6),
                      Expanded(
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo with subtle glow
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.cyanAccent.withOpacity(0.2),
                                      Colors.transparent
                                    ],
                                  ),
                                  boxShadow: neon(Colors.cyanAccent,
                                      blur: 40, spread: 4),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: SvgPicture.asset('assets/logo.svg',
                                      height: 44, width: 44),
                                ),
                              ),
                              const SizedBox(width: 14),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Colors.cyanAccent,
                                    Colors.purpleAccent
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  "Web3 Bank",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // optional right profile placeholder
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(colors: [
                            Colors.white.withOpacity(0.02),
                            Colors.white.withOpacity(0.03)
                          ]),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.03)),
                        ),
                        child: const Icon(Icons.account_circle,
                            color: Colors.white30, size: 36),
                      )
                    ],
                  ),
                  const SizedBox(height: 18),

                  // content area: balance + actions + transactions
                  Expanded(
                    child: BlocConsumer<DashboardBloc, DashboardState>(
                      bloc: dashboardBloc,
                      listener: (context, state) {},
                      builder: (context, state) {
                        if (state is DashboardLoadingState) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.cyanAccent));
                        } else if (state is DashboardErrorState) {
                          return const Center(
                              child: Text('Something went wrong',
                                  style: TextStyle(color: Colors.redAccent)));
                        } else if (state is DashboardSuccessState) {
                          final success = state;
                          // responsive layout: when wide, show left column with balance and actions and right column with transactions
                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // left column
                                Flexible(
                                  flex: 4,
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onPanDown: (details) => _handlePan(
                                            details.localPosition,
                                            Size(mq.size.width * 0.45, 200)),
                                        onPanUpdate: (details) => _handlePan(
                                            details.localPosition,
                                            Size(mq.size.width * 0.45, 200)),
                                        onPanEnd: (_) => _resetTilt(),
                                        onPanCancel: () => _resetTilt(),
                                        child: Transform(
                                          transform: Matrix4.identity()
                                            ..setEntry(3, 2, 0.001)
                                            ..rotateX(_tiltX * 0.12)
                                            ..rotateY(-_tiltY * 0.12),
                                          alignment: Alignment.center,
                                          child: _BalanceCard(
                                            balance: success.balance.toDouble(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: _ActionButton(
                                            label: ' DEBIT',
                                            icon: Icons.remove,
                                            gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF7F0000),
                                                  Color(0xFFEE2E2E)
                                                ]),
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => WithdrawPage(
                                                        dashboardBloc:
                                                            dashboardBloc))),
                                          )),
                                          const SizedBox(width: 14),
                                          Expanded(
                                              child: _ActionButton(
                                            label: ' CREDIT',
                                            icon: Icons.add,
                                            gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF0B8043),
                                                  Color(0xFF6EFFB3)
                                                ]),
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => DepositPage(
                                                        dashboardBloc:
                                                            dashboardBloc))),
                                          )),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _SummaryChips(success),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // right column - transactions
                                Flexible(
                                  flex: 6,
                                  child: _TransactionsList(
                                      transactions: success.transactions),
                                ),
                              ],
                            );
                          } else {
                            // narrow layout (vertical)
                            return Column(
                              children: [
                                GestureDetector(
                                  onPanDown: (details) => _handlePan(
                                      details.localPosition,
                                      Size(mq.size.width, 180)),
                                  onPanUpdate: (details) => _handlePan(
                                      details.localPosition,
                                      Size(mq.size.width, 180)),
                                  onPanEnd: (_) => _resetTilt(),
                                  onPanCancel: () => _resetTilt(),
                                  child: Transform(
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateX(_tiltX * 0.12)
                                      ..rotateY(-_tiltY * 0.12),
                                    alignment: Alignment.center,
                                    child: _BalanceCard(
                                      balance: success.balance.toDouble(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                        child: _ActionButton(
                                      label: ' DEBIT',
                                      icon: Icons.remove,
                                      gradient: const LinearGradient(colors: [
                                        Color(0xFF7F0000),
                                        Color(0xFFEE2E2E)
                                      ]),
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => WithdrawPage(
                                                  dashboardBloc:
                                                      dashboardBloc))),
                                    )),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: _ActionButton(
                                      label: ' CREDIT',
                                      icon: Icons.add,
                                      gradient: const LinearGradient(colors: [
                                        Color(0xFF0B8043),
                                        Color(0xFF6EFFB3)
                                      ]),
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => DepositPage(
                                                  dashboardBloc:
                                                      dashboardBloc))),
                                    )),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                    child: _TransactionsList(
                                        transactions: success.transactions)),
                              ],
                            );
                          }
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Balance card widget with animated switcher + glow
class _BalanceCard extends StatelessWidget {
  final double balance;
  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    // hero added for potential navigation animations
    return Hero(
      tag: 'balance-hero',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(colors: [
            Colors.white.withOpacity(0.02),
            Colors.white.withOpacity(0.03)
          ]),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.06),
                blurRadius: 40,
                spreadRadius: 2),
            BoxShadow(
                color: Colors.purpleAccent.withOpacity(0.03),
                blurRadius: 60,
                spreadRadius: 4),
          ],
          // subtle glass
          // using backdrop filter would require layering; for simplicity keep translucent gradient
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // left: icon / small spark
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  Colors.cyanAccent.withOpacity(0.16),
                  Colors.transparent
                ]),
              ),
              child: Center(
                  child: SvgPicture.asset('assets/logo.svg',
                      height: 40, width: 40)),
            ),
            const SizedBox(width: 18),
            // center: balance
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Balance',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(scale: anim, child: child)),
                    child: Text(
                      '${balance.toStringAsFixed(4)} ETH',
                      key: ValueKey(balance),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            // right: spark / small stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white10),
                  child: Row(
                    children: const [
                      Icon(Icons.trending_up,
                          size: 14, color: Colors.greenAccent),
                      SizedBox(width: 6),
                      Text('+3.2%',
                          style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(DateTime.now().toLocal().toString().substring(0, 16),
                    style:
                        const TextStyle(color: Colors.white24, fontSize: 11)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// Floating action style buttons with press animation
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label,
      required this.icon,
      required this.gradient,
      required this.onTap});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) {
        setState(() => pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => pressed = false),
      child: AnimatedScale(
        scale: pressed ? 0.95 : 1.0, // nice shrink effect
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: widget.gradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(0, 8),
                blurRadius: pressed ? 10 : 18,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.02),
                blurRadius: 2,
                spreadRadius: 0.2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// small summary chips under actions (totals)
class _SummaryChips extends StatelessWidget {
  final DashboardSuccessState state;
  const _SummaryChips(this.state);

  @override
  Widget build(BuildContext context) {
    // compute totals
    final incomes = state.transactions
        .where((t) => t.type == TransactionType.deposit)
        .fold<double>(0.0, (s, t) => s + t.amount);
    final spends = state.transactions
        .where((t) => t.type != TransactionType.deposit)
        .fold<double>(0.0, (s, t) => s + t.amount);

    return Row(
      children: [
        _tinyChip(label: 'In', value: incomes, color: Colors.greenAccent),
        const SizedBox(width: 10),
        _tinyChip(label: 'Out', value: spends, color: Colors.redAccent),
        const SizedBox(width: 10),
        _tinyChip(
            label: 'Txs',
            value: state.transactions.length.toDouble(),
            color: Colors.cyanAccent),
      ],
    );
  }

  Widget _tinyChip(
      {required String label, required double value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white10,
          border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
              Text(
                  value is double
                      ? (value % 1 == 0
                          ? value.toInt().toString()
                          : value.toStringAsFixed(2))
                      : '$value',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          )
        ],
      ),
    );
  }
}

/// Transactions list with animated entry & expandable item
class _TransactionsList extends StatelessWidget {
  final List<TransactionModel> transactions;
  const _TransactionsList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
          child: Text('No transactions yet',
              style: TextStyle(color: Colors.white38)));
    }

    return LayoutBuilder(builder: (context, constraints) {
      return NotificationListener<ScrollNotification>(
        onNotification: (_) => false,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            return _TransactionTile(transaction: tx, index: index);
          },
        ),
      );
    });
  }
}

class _TransactionTile extends StatefulWidget {
  final TransactionModel transaction;
  final int index;
  const _TransactionTile({required this.transaction, required this.index});

  @override
  State<_TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<_TransactionTile>
    with SingleTickerProviderStateMixin {
  bool expanded = false;
  late AnimationController _enter;
  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    // staggered entry
    Future.delayed(
        Duration(milliseconds: 80 * widget.index), () => _enter.forward());
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final isDeposit = tx.type == TransactionType.deposit;
    final accent = isDeposit ? Colors.greenAccent : Colors.redAccent;

    return FadeTransition(
      opacity: _enter.drive(
          Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut))),
      child: SlideTransition(
        position: _enter.drive(
            Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOut))),
        child: GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(colors: [
                Colors.white.withOpacity(0.01),
                Colors.white.withOpacity(0.02)
              ]),
              border: Border.all(color: accent.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                    color: accent.withOpacity(0.06),
                    blurRadius: expanded ? 28 : 14,
                    offset: Offset(0, expanded ? 12 : 6)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: accent),
                    child: Icon(
                        isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: Colors.black,
                        size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${isDeposit ? '+' : '-'} ${tx.amount.toStringAsFixed(4)} ETH',
                    style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 16),
                  ),
                  const Spacer(),
                  Text(isDeposit ? 'DEPOSIT' : 'WITHDRAW',
                      style: TextStyle(
                          color: accent.withOpacity(0.9),
                          fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 8),
                Text(tx.reason,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Address: ${tx.address}',
                              style: const TextStyle(
                                  color: Colors.white30, fontSize: 12)),
                          const SizedBox(height: 6),
                          Text(
                              'Time: ${tx.timestamp.toString().substring(0, 16)}',
                              style: const TextStyle(
                                  color: Colors.white24, fontSize: 12)),
                        ]),
                  ),
                  crossFadeState: expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 260),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// custom painter for animated gradient blobs background
class _BackgroundPainter extends CustomPainter {
  final double t;
  _BackgroundPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..blendMode = BlendMode.srcOver;

    // base radial gradient
    final g1 = RadialGradient(
      colors: [Colors.purple.withOpacity(0.06), Colors.transparent],
      radius: 0.6,
    );
    paint.shader = g1.createShader(Rect.fromCircle(
        center:
            Offset(size.width * (0.2 + sin(t * pi) * 0.05), size.height * 0.15),
        radius: size.width * 0.7));
    canvas.drawRect(rect, paint);

    final g2 = RadialGradient(
        colors: [Colors.cyan.withOpacity(0.05), Colors.transparent],
        radius: 0.6);
    paint.shader = g2.createShader(Rect.fromCircle(
        center:
            Offset(size.width * (0.9 - cos(t * pi) * 0.05), size.height * 0.7),
        radius: size.width * 0.6));
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) =>
      oldDelegate.t != t;
}
