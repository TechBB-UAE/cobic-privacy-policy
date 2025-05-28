import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cobic/providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user info khi màn hình được tạo
    Provider.of<ProfileProvider>(context, listen: false).fetchUserInfo();
  }

  void _navigateToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userInfo = profileProvider.userInfo;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: _navigateToHome,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (profileProvider.isLoading)
              const CircularProgressIndicator()
            else if (profileProvider.error != null)
              Text(
                'Lỗi: ${profileProvider.error}',
                style: const TextStyle(color: Colors.red),
              )
            else if (userInfo == null)
              const Text('Không có dữ liệu tài khoản!')
            else
              Text(
                'Xin chào, ${userInfo['username'] ?? "Khách"}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToHome,
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
} 