import 'package:sukisave/features/vendor/models/vendor_chat.dart';

const List<VendorChat> vendorMockChats = [
  VendorChat(
    customerName: 'Hazel Mae',
    profilePath: 'assets/images/message-customer-profile/hazel.jpg',
    lastMessage: 'Okay po, I will pick it up.',
    time: '12:15',
    unreadCount: 2,
    messages: [
      VendorChatMessage(
        text: 'Hi maam, your order is accepted.',
        isVendor: true,
      ),
      VendorChatMessage(text: 'Thank you po! Is it ready now?', isVendor: false),
      VendorChatMessage(text: 'Yes, ready in 5 minutes.', isVendor: true),
      VendorChatMessage(text: 'Okay po, I will pick it up.', isVendor: false),
    ],
  ),
  VendorChat(
    customerName: 'Kevin Santos',
    profilePath: 'assets/images/message-customer-profile/kevin.png',
    lastMessage: 'Please add extra soup.',
    time: '11:40',
    unreadCount: 1,
    messages: [
      VendorChatMessage(
        text: 'Sir, we still have pares rice meals.',
        isVendor: true,
      ),
      VendorChatMessage(text: 'Nice. I will order two.', isVendor: false),
      VendorChatMessage(text: 'Noted, preparing two meals now.', isVendor: true),
      VendorChatMessage(text: 'Please add extra soup.', isVendor: false),
    ],
  ),
  VendorChat(
    customerName: 'Marj Flores',
    profilePath: 'assets/images/message-customer-profile/marj.jpg',
    lastMessage: 'Thanks, I will send payment.',
    time: '10:05',
    unreadCount: 3,
    messages: [
      VendorChatMessage(
        text: 'Hello, your reserved cake slice is available.',
        isVendor: true,
      ),
      VendorChatMessage(text: 'Can I get it before 2 PM?', isVendor: false),
      VendorChatMessage(text: 'Yes, we will keep it for you.', isVendor: true),
      VendorChatMessage(text: 'Thanks, I will send payment.', isVendor: false),
    ],
  ),
];
