class CustomerChat {
  final String businessName;
  final String logoPath;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final List<CustomerChatMessage> messages;

  const CustomerChat({
    required this.businessName,
    required this.logoPath,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.messages,
  });
}

class CustomerChatMessage {
  final String text;
  final bool isCustomer;
  final String timeLabel;

  const CustomerChatMessage({
    required this.text,
    required this.isCustomer,
    this.timeLabel = 'Now',
  });
}
