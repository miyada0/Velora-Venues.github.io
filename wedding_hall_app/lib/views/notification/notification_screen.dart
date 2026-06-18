import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../services/notification_service.dart';
import '../../services/safe_api.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final NotificationService service = NotificationService();

  List notifications = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final data = await service.getNotifications();
      if (mounted) {
        setState(() {
          notifications = data;
          loading = false;
          error = null;
        });
      }
    } catch (e) {
      if (!mounted) return;

      // ✅ FIX: Check if 401 Unauthorized
      bool is401 = false;
      if (e is DioException) {
        is401 = e.response?.statusCode == 401;
      }

      if (is401) {
        SafeApi.handle401(context, ref);
      } else {
        final errorMsg = e is DioException
            ? (e.response?.data["error"] ??
                e.message ??
                "Failed to load notifications")
            : "Failed to load notifications";

        setState(() {
          error = errorMsg;
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 60, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          error ?? "Something went wrong",
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            loading = true;
                            error = null;
                          });
                          load();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Try Again"),
                      ),
                    ],
                  ),
                )
              : notifications.isEmpty
                  ? const Center(
                      child: Text("No notifications yet"),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final n = notifications[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(n["title"]),
                            subtitle: Text(n["message"]),
                            trailing: n["isRead"] == true
                                ? null
                                : const Icon(
                                    Icons.circle,
                                    color: Colors.red,
                                    size: 10,
                                  ),
                            onTap: () async {
                              try {
                                await service.markAsRead(n["_id"]);
                                load();
                              } catch (e) {
                                bool is401 = false;
                                if (e is DioException) {
                                  is401 = e.response?.statusCode == 401;
                                }

                                if (is401 && mounted) {
                                  SafeApi.handle401(context, ref);
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
