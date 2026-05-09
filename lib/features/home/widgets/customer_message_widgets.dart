import 'package:flutter/material.dart';
import 'package:sukisave/features/home/models/customer_chat.dart';

const Color customerMessageGreen = Color(0xFF0F5513);
const Color customerMessageAccentGreen = Color(0xFF63B21F);
const Color customerMessageSoftBubble = Color(0xFFF1F1F6);

class CustomerMessageHeader extends StatelessWidget {
  final List<CustomerChat> chats;

  const CustomerMessageHeader({super.key, required this.chats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
      decoration: const BoxDecoration(
        color: customerMessageGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Messages',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: chats.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const CustomerSearchButton();
                }
                return CustomerBusinessLogo(
                  imagePath: chats[index - 1].logoPath,
                  size: 48,
                  borderColor: Colors.white,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerConversationHeader extends StatelessWidget {
  final CustomerChat chat;

  const CustomerConversationHeader({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 24),
      decoration: const BoxDecoration(
        color: customerMessageGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          ),
          CustomerBusinessLogo(
            imagePath: chat.logoPath,
            size: 54,
            borderColor: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.businessName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Food Business',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const CustomerHeaderAction(icon: Icons.call),
          const SizedBox(width: 10),
          const CustomerHeaderAction(icon: Icons.videocam),
        ],
      ),
    );
  }
}

class CustomerChatCard extends StatelessWidget {
  final CustomerChat chat;
  final VoidCallback onTap;

  const CustomerChatCard({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomerBusinessLogo(imagePath: chat.logoPath, size: 62),
            const SizedBox(width: 14),
            Expanded(child: _ChatPreviewText(chat: chat)),
            const SizedBox(width: 10),
            _UnreadInfo(time: chat.time, count: chat.unreadCount),
          ],
        ),
      ),
    );
  }
}

class CustomerMessageBubble extends StatelessWidget {
  final CustomerChatMessage message;
  final String logoPath;

  const CustomerMessageBubble({
    super.key,
    required this.message,
    required this.logoPath,
  });

  @override
  Widget build(BuildContext context) {
    final isCustomer = message.isCustomer;
    return Row(
      mainAxisAlignment:
          isCustomer ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isCustomer) ...[
          CustomerBusinessLogo(imagePath: logoPath, size: 46),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment:
                isCustomer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isCustomer
                      ? customerMessageGreen
                      : customerMessageSoftBubble,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    color: isCustomer ? Colors.white : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message.timeLabel,
                style: const TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 9,
                  color: Colors.black26,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomerBusinessLogo extends StatelessWidget {
  final String imagePath;
  final double size;
  final Color borderColor;

  const CustomerBusinessLogo({
    super.key,
    required this.imagePath,
    required this.size,
    this.borderColor = customerMessageGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const ColoredBox(
              color: customerMessageSoftBubble,
              child: Icon(Icons.store, color: customerMessageGreen),
            );
          },
        ),
      ),
    );
  }
}

class CustomerSearchButton extends StatelessWidget {
  const CustomerSearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: customerMessageAccentGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.search, color: Colors.white, size: 22),
    );
  }
}

class CustomerHeaderAction extends StatelessWidget {
  final IconData icon;

  const CustomerHeaderAction({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: customerMessageAccentGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _ChatPreviewText extends StatelessWidget {
  final CustomerChat chat;

  const _ChatPreviewText({required this.chat});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          chat.businessName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: customerMessageGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          chat.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _UnreadInfo extends StatelessWidget {
  final String time;
  final int count;

  const _UnreadInfo({required this.time, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          time,
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 10,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: customerMessageGreen,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
