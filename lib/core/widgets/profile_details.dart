import 'package:flutter/material.dart';

class ProfileDetailItem {
  final String label;
  final String value;
  final VoidCallback? onEdit;

  const ProfileDetailItem({
    required this.label,
    required this.value,
    this.onEdit,
  });
}

class ConnectedAccountItem {
  final String iconPath;
  final String label;
  final String status;

  const ConnectedAccountItem({
    required this.iconPath,
    required this.label,
    required this.status,
  });
}

class ProfileDetailsPage extends StatelessWidget {
  final String title;
  final List<ProfileDetailItem> details;
  final List<ConnectedAccountItem> connectedAccounts;
  final VoidCallback onDeleteAccount;

  const ProfileDetailsPage({
    super.key,
    required this.title,
    required this.details,
    required this.connectedAccounts,
    required this.onDeleteAccount,
  });

  static const Color _brandGreen = Color(0xFF0F5513);
  static const Color _panelWhite = Color(0xFFF3F3F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _panelWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: const Color.fromARGB(255, 248, 249, 248),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 229, 224, 224),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: _brandGreen,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: _brandGreen,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...details.expand(
                      (detail) => [
                        _InfoPanel(
                          label: detail.label,
                          value: detail.value,
                          onEdit: detail.onEdit ?? () {},
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Connected accounts',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _brandGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...connectedAccounts.expand(
                      (account) => [
                        _ConnectedPanel(
                          iconPath: account.iconPath,
                          label: account.label,
                          status: account.status,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onDeleteAccount,
                      child: const Text(
                        'Delete account',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;

  const _InfoPanel({
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF0F5513)),
          ),
        ],
      ),
    );
  }
}

class _ConnectedPanel extends StatelessWidget {
  final String iconPath;
  final String label;
  final String status;

  const _ConnectedPanel({
    required this.iconPath,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(iconPath, width: 28, height: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined, color: Color(0xFF0F5513)),
        ],
      ),
    );
  }
}
