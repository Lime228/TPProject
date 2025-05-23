import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/settings_provider.dart';

class UpperNavigation extends StatelessWidget {
  final void Function()? onInfoPressed;

  const UpperNavigation({Key? key, this.onInfoPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: true);

    return Container(
      width: double.infinity,
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFF937DF3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: settingsProvider.avatarBytes != null
                    ? FileImage(settingsProvider.avatarBytes! as File)
                    : null,
                child: settingsProvider.avatarBytes == null
                    ? const Icon(Icons.person, color: Colors.deepPurple)
                    : null,
              ),
              const SizedBox(width: 16),
              Text(
                settingsProvider.userName ?? authProvider.user?.name ?? 'Гость',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 30),
            onSelected: (value) {
              if (value == 'info' && groupProvider.isInGroup) {
                onInfoPressed?.call();
              } else if (!groupProvider.isInGroup) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Вы не состоите в группе')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'info',
                child: Text('Информация о группе'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
