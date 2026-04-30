import 'package:flutter/material.dart';
import 'package:sukisave/core/widgets/app_bottom_nav.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'No messages yet',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 1, onTap: (_) {}),
    );
  }
}
