import 'package:sukisave/features/home/models/customer_chat.dart';

const List<CustomerChat> customerMockChats = [
  CustomerChat(
    businessName: 'Paris Dabaw',
    logoPath: 'assets/images/business-logo/pares-dabaw.png',
    lastMessage: 'Are this all your order sir?',
    time: '12:00',
    unreadCount: 3,
    messages: [
      CustomerChatMessage(
        text: 'Welcome! Order pa, sir/maam?',
        isCustomer: false,
      ),
      CustomerChatMessage(text: 'Beef pares with rice.', isCustomer: true),
      CustomerChatMessage(text: 'Soup with it?', isCustomer: false),
      CustomerChatMessage(text: 'Yes.', isCustomer: true),
      CustomerChatMessage(text: 'Ready in 5 mins!', isCustomer: false),
    ],
  ),
  CustomerChat(
    businessName: 'M&M Snacks',
    logoPath: 'assets/images/business-logo/MnM.png',
    lastMessage: 'We can prepare that now.',
    time: '11:45',
    unreadCount: 2,
    messages: [
      CustomerChatMessage(
        text: 'Hi! Is the combo still available?',
        isCustomer: true,
      ),
      CustomerChatMessage(
        text: 'Yes, we still have 4 servings.',
        isCustomer: false,
      ),
      CustomerChatMessage(text: 'Great, please reserve one.', isCustomer: true),
      CustomerChatMessage(text: 'We can prepare that now.', isCustomer: false),
    ],
  ),
  CustomerChat(
    businessName: 'Native Letchon',
    logoPath: 'assets/images/business-logo/native-letchon.png',
    lastMessage: 'Pickup is okay after 1 PM.',
    time: '10:30',
    unreadCount: 1,
    messages: [
      CustomerChatMessage(
        text: 'Do you have lechon rice meals?',
        isCustomer: true,
      ),
      CustomerChatMessage(text: 'Yes, fresh batch today.', isCustomer: false),
      CustomerChatMessage(text: 'Pickup is okay after 1 PM.', isCustomer: false),
    ],
  ),
  CustomerChat(
    businessName: 'Cake & Pastry',
    logoPath: 'assets/images/business-logo/cake-pastry.png',
    lastMessage: 'Thank you, we saved one slice.',
    time: '09:20',
    unreadCount: 4,
    messages: [
      CustomerChatMessage(
        text: 'Is chocolate cake discounted?',
        isCustomer: true,
      ),
      CustomerChatMessage(
        text: 'Yes, 30% off until closing.',
        isCustomer: false,
      ),
      CustomerChatMessage(text: 'I will get one slice.', isCustomer: true),
      CustomerChatMessage(
        text: 'Thank you, we saved one slice.',
        isCustomer: false,
      ),
    ],
  ),
  CustomerChat(
    businessName: 'Silog Express',
    logoPath: 'assets/images/business-logo/silog.png',
    lastMessage: 'Your tapsilog is almost ready.',
    time: '08:55',
    unreadCount: 1,
    messages: [
      CustomerChatMessage(text: 'One tapsilog please.', isCustomer: true),
      CustomerChatMessage(text: 'Sure, regular or spicy?', isCustomer: false),
      CustomerChatMessage(text: 'Spicy.', isCustomer: true),
      CustomerChatMessage(
        text: 'Your tapsilog is almost ready.',
        isCustomer: false,
      ),
    ],
  ),
];
