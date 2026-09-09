import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/storage_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/todo_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/stitch_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = activeBaseUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _showArchitectureDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.layers_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Full-Stack Flow', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How Data Flows Through This App:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              SizedBox(height: 10),
              Text('1️⃣ UI View / Widget: User triggers an action (e.g. Add Task, Toggle).'),
              SizedBox(height: 6),
              Text('2️⃣ Provider (Controller/ViewModel): Updates loading state and calls Repository.'),
              SizedBox(height: 6),
              Text('3️⃣ Repository: Single source of truth. Calls ApiService and manages in-memory cache.'),
              SizedBox(height: 6),
              Text('4️⃣ ApiService / Network Client: Attaches JWT Bearer token and sends HTTP request to REST API.'),
              SizedBox(height: 6),
              Text('5️⃣ Backend (Node.js/Express): authMiddleware validates JWT and extracts user_id.'),
              SizedBox(height: 6),
              Text('6️⃣ SQLite Database: Executes query strictly scoped by WHERE user_id = ? (Strict Isolation!).'),
              SizedBox(height: 6),
              Text('7️⃣ Response: Data models parsed, Provider notifies listeners, and UI re-renders!'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got It!'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateBaseUrl() async {
    final newUrl = _urlController.text.trim();
    if (newUrl.isEmpty) return;

    activeBaseUrl = newUrl;
    final storage = context.read<StorageService>();
    await storage.saveBaseUrl(newUrl);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('API Server URL updated to: $newUrl'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = authProvider.currentUser;

    String formattedDate = 'Recent';
    if (user?.createdAt != null) {
      formattedDate = DateFormat('MMMM yyyy').format(user!.createdAt!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // 1. User Profile Header Card
            StitchCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user != null && user.name.isNotEmpty
                          ? user.name.substring(0, 1).toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Member since $formattedDate',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Preferences & Architecture
            StitchCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Dark Mode Switch
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.dark_mode_outlined, color: AppColors.accent, size: 20),
                    ),
                    title: const Text('Dark Theme', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Toggle between dark and light mode', style: TextStyle(fontSize: 12)),
                    trailing: Switch.adaptive(
                      value: themeProvider.isDarkMode,
                      activeColor: AppColors.primary,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    ),
                  ),
                  const Divider(height: 1),

                  // Architecture Explainer
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.school_outlined, color: AppColors.info, size: 20),
                    ),
                    title: const Text('Architecture Guide', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Understand the complete full-stack flow', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: _showArchitectureDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Backend API Connection Settings
            StitchCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.dns_rounded, color: AppColors.success, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Backend API Server', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          Text('Configure host for Emulator/Device', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _urlController,
                    label: 'Base URL',
                    hint: 'http://localhost:3000 or http://10.0.2.2:3000',
                    prefixIcon: Icons.link_rounded,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _urlController.text = 'http://10.0.2.2:3000';
                            });
                            _updateBaseUrl();
                          },
                          child: const Text('Android (10.0.2.2)', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _urlController.text = 'http://localhost:3000';
                            });
                            _updateBaseUrl();
                          },
                          child: const Text('Localhost:3000', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Save Server URL',
                    height: 44,
                    onPressed: _updateBaseUrl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Logout Button
            CustomButton(
              text: 'Sign Out',
              icon: Icons.logout_rounded,
              backgroundColor: AppColors.error.withOpacity(0.12),
              textColor: AppColors.error,
              isOutlined: true,
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  context.read<TodoProvider>().resetState();
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
