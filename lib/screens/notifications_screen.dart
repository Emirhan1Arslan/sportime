import 'package:flutter/material.dart';

import '../app_state.dart';
import '../format.dart';
import '../models.dart';
import '../theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  /// Ekran açıldığında okunmamış olanlar; bu ziyarette vurgulanmaya devam eder.
  late final Set<AppNotice> _fresh;

  @override
  void initState() {
    super.initState();
    final state = AppScope.read(context);
    _fresh = state.notices.where((n) => !n.read).toSet();
    // Açılış sayacını çizim bittikten sonra güncelle (build sırasında
    // notifyListeners çağrılmamalı).
    WidgetsBinding.instance.addPostFrameCallback((_) => state.openNotices());
  }

  @override
  Widget build(BuildContext context) {
    final notices = AppScope.of(context).notices;
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: notices.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Henüz bildirim yok. Takip ettiğin sporcuların maçları '
                  've başvuru hatırlatmaları burada görünür.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              itemCount: notices.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final n = notices[i];
                final fresh = _fresh.contains(n);
                return ListTile(
                  tileColor: fresh ? brandRed.withValues(alpha: 0.05) : null,
                  leading: CircleAvatar(
                    backgroundColor: brandRed.withValues(alpha: 0.1),
                    child: Icon(n.icon, color: brandRed),
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: fresh ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(n.body),
                  trailing: Text(
                    timeAgo(n.time),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                );
              },
            ),
    );
  }
}
