import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationsProvider = context.watch<NotificationProvider>();
    final notifications = notificationsProvider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: notificationsProvider.unreadCount == 0
                ? null
                : () => notificationsProvider.markAllAsRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notificationsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications yet.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                )
              : ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return ListTile(
                      leading: Icon(
                        item.isRead
                            ? Icons.notifications_none_rounded
                            : Icons.notifications_active_rounded,
                        color: item.isRead
                            ? Colors.grey.shade500
                            : Colors.blueAccent,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight:
                              item.isRead ? FontWeight.w600 : FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(item.message),
                      trailing: Text(
                        '${item.createdAt.day.toString().padLeft(2, '0')}/${item.createdAt.month.toString().padLeft(2, '0')} ${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                      onTap: () => notificationsProvider.markAsRead(item.id),
                    );
                  },
                ),
    );
  }
}
