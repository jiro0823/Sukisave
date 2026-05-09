import 'package:flutter/material.dart';
import 'package:sukisave/features/vendor/data/vendor_message_mock_data.dart';
import 'package:sukisave/features/vendor/models/vendor_chat.dart';
import 'package:sukisave/features/vendor/widgets/vendor_bottom_navbar.dart';
import 'package:sukisave/features/vendor/widgets/vendor_message_widgets.dart';

class VendorMessagePage extends StatelessWidget {
  const VendorMessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const VendorMessageHeader(chats: vendorMockChats),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                itemCount: vendorMockChats.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final chat = vendorMockChats[index];
                  return VendorChatCard(
                    chat: chat,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VendorCustomerMessagePage(chat: chat),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const VendorBottomNavBar(currentIndex: 3),
    );
  }
}

class VendorCustomerMessagePage extends StatelessWidget {
  final VendorChat chat;

  const VendorCustomerMessagePage({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            VendorConversationHeader(chat: chat),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 34, 16, 24),
                itemCount: chat.messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return VendorMessageBubble(
                    message: chat.messages[index],
                    profilePath: chat.profilePath,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const VendorBottomNavBar(currentIndex: 3),
    );
  }
}
