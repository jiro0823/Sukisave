class VendorChat {
  final String customerName;
  final String profilePath;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final List<VendorChatMessage> messages;

  const VendorChat({
    required this.customerName,
    required this.profilePath,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.messages,
  });
}

class VendorChatMessage {
  final String text;
  final bool isVendor;
  final String timeLabel;

  const VendorChatMessage({
    required this.text,
    required this.isVendor,
    this.timeLabel = 'Now',
  });
}
