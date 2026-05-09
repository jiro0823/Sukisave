import 'package:flutter/material.dart';
import 'package:sukisave/core/widgets/app_bottom_nav.dart';
import 'package:sukisave/features/home/data/customer_message_mock_data.dart';
import 'package:sukisave/features/home/pages/customer_message_page.dart';
import 'package:sukisave/features/home/widgets/customer_message_widgets.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const CustomerMessageHeader(chats: customerMockChats),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                itemCount: customerMockChats.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final chat = customerMockChats[index];
                  return CustomerChatCard(
                    chat: chat,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CustomerMessagePage(chat: chat),
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
      bottomNavigationBar: AppBottomNavBar(currentIndex: 1, onTap: (_) {}),
    );
  }
}
