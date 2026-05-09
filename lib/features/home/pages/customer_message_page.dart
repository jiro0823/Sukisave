import 'package:flutter/material.dart';
import 'package:sukisave/core/widgets/app_bottom_nav.dart';
import 'package:sukisave/features/home/models/customer_chat.dart';
import 'package:sukisave/features/home/widgets/customer_message_widgets.dart';

class CustomerMessagePage extends StatelessWidget {
  final CustomerChat chat;

  const CustomerMessagePage({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomerConversationHeader(chat: chat),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 34, 16, 24),
                itemCount: chat.messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return CustomerMessageBubble(
                    message: chat.messages[index],
                    logoPath: chat.logoPath,
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
