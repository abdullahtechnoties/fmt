import 'package:flutter/material.dart';
import '../utilities/colors.dart';

class NotificationCard extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String imageAsset;
  final String status; // 'Read', 'Unread', 'Pending'
  final bool isOnline;

  const NotificationCard({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.imageAsset,
    this.status = 'Unread',
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status color and icon
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.check;
    
    if (status == 'Read') {
      statusColor = Colors.green;
      statusIcon = Icons.done_all;
    } else if (status == 'Pending') {
      statusColor = Colors.grey;
      statusIcon = Icons.check;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with Online Indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(imageAsset),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  top: 5,
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Row(
                      children: [
                        Text(
                          status,
                          style: TextStyle(color: statusColor, fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Icon(statusIcon, color: statusColor, size: 16),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}