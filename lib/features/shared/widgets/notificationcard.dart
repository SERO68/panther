import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String? timestamp;
  final IconData icon;
  final VoidCallback? onClose;
  final bool showWarningIcon;

  const NotificationCard({
    super.key,
    this.title = 'Alert',
    this.message = '',
    this.timestamp,
    this.icon = Icons.warning,
    this.onClose,
    this.showWarningIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350, // Adjust width as needed
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showWarningIcon)
                Icon(
                  icon,
                  color: Colors.red,
                ),
              if (showWarningIcon)
                const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  if (onClose != null)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: onClose,
                    ),
                  if (timestamp != null && onClose == null)
                    Text(
                      timestamp!,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}