import 'package:flutter/material.dart';
import 'package:sukisave/features/vendor/models/vendor_chat.dart';

const Color vendorMessageGreen = Color(0xFF0F5513);
const Color vendorMessageAccentGreen = Color(0xFF63B21F);
const Color vendorMessageSoftBubble = Color(0xFFF1F1F6);

class VendorMessageHeader extends StatelessWidget {
  final List<VendorChat> chats;

  const VendorMessageHeader({super.key, required this.chats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
      decoration: const BoxDecoration(
        color: vendorMessageGreen,
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
                  return const VendorMessageSearchButton();
                }
                return VendorCustomerAvatar(
                  imagePath: chats[index - 1].profilePath,
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

class VendorConversationHeader extends StatelessWidget {
  final VendorChat chat;

  const VendorConversationHeader({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 24),
      decoration: const BoxDecoration(
        color: vendorMessageGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          ),
          VendorCustomerAvatar(
            imagePath: chat.profilePath,
            size: 54,
            borderColor: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.customerName,
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
                  'Customer',
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
          const VendorHeaderAction(icon: Icons.call),
          const SizedBox(width: 10),
          const VendorHeaderAction(icon: Icons.videocam),
        ],
      ),
    );
  }
}

class VendorChatCard extends StatelessWidget {
  final VendorChat chat;
  final VoidCallback onTap;

  const VendorChatCard({super.key, required this.chat, required this.onTap});

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
            VendorCustomerAvatar(imagePath: chat.profilePath, size: 62),
            const SizedBox(width: 14),
            Expanded(child: _VendorChatPreviewText(chat: chat)),
            const SizedBox(width: 10),
            _VendorUnreadInfo(time: chat.time, count: chat.unreadCount),
          ],
        ),
      ),
    );
  }
}

class VendorMessageBubble extends StatelessWidget {
  final VendorChatMessage message;
  final String profilePath;

  const VendorMessageBubble({
    super.key,
    required this.message,
    required this.profilePath,
  });

  @override
  Widget build(BuildContext context) {
    final isVendor = message.isVendor;
    return Row(
      mainAxisAlignment:
          isVendor ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isVendor) ...[
          VendorCustomerAvatar(imagePath: profilePath, size: 46),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment:
                isVendor ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      isVendor ? vendorMessageGreen : vendorMessageSoftBubble,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    color: isVendor ? Colors.white : Colors.black54,
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

class VendorCustomerAvatar extends StatelessWidget {
  final String imagePath;
  final double size;
  final Color borderColor;

  const VendorCustomerAvatar({
    super.key,
    required this.imagePath,
    required this.size,
    this.borderColor = vendorMessageGreen,
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
              color: vendorMessageSoftBubble,
              child: Icon(Icons.person, color: vendorMessageGreen),
            );
          },
        ),
      ),
    );
  }
}

class VendorMessageSearchButton extends StatelessWidget {
  const VendorMessageSearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: vendorMessageAccentGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.search, color: Colors.white, size: 22),
    );
  }
}

class VendorHeaderAction extends StatelessWidget {
  final IconData icon;

  const VendorHeaderAction({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: vendorMessageAccentGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _VendorChatPreviewText extends StatelessWidget {
  final VendorChat chat;

  const _VendorChatPreviewText({required this.chat});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          chat.customerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: vendorMessageGreen,
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

class _VendorUnreadInfo extends StatelessWidget {
  final String time;
  final int count;

  const _VendorUnreadInfo({required this.time, required this.count});

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
            color: vendorMessageGreen,
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
