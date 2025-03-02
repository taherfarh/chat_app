import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ✅ MessageBubble المُعدل ليشمل الوقت فقط بدون الاسم
class MessageBubble extends StatelessWidget {
  // 🔹 Constructor للرسالة الأولى في التسلسل
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.message,
    required this.isMe,
    required this.timestamp, // 🟢 إضافة الوقت
  }) : isFirstInSequence = true;

  // 🔹 Constructor للرسالة التالية في التسلسل
  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
    required this.timestamp, // 🟢 إضافة الوقت
  })  : isFirstInSequence = false,
        userImage = null;

  final bool isFirstInSequence;
  final String? userImage;
  final String message;
  final bool isMe;
  final dynamic timestamp; // 🟢 تخزين الوقت

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedTime = timestamp != null
        ? DateFormat('hh:mm a').format(timestamp.toDate())
        : "";

    return Stack(
      children: [
        if (userImage != null)
          Positioned(
            top: 15,
            right: isMe ? 0 : null,
            left: isMe ? null : 0,
            child: CircleAvatar(
              backgroundImage:
                  userImage != null ? NetworkImage(userImage!) : null,
              backgroundColor: Colors.grey[400],
              radius: 23,
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (isFirstInSequence) const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.blue[300]
                          : theme.colorScheme.secondary.withAlpha(200),
                      borderRadius: BorderRadius.only(
                        topLeft: !isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                        topRight: isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                        bottomLeft: const Radius.circular(12),
                        bottomRight: const Radius.circular(12),
                      ),
                    ),
                    constraints: const BoxConstraints(maxWidth: 250),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message,
                          style: TextStyle(color: Colors.white, height: 1.3),
                          softWrap: true,
                        ),
                        SizedBox(height: 5),
                        Text(
                          formattedTime,
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
