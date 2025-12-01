import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartshop_app/models/user_model.dart';
import 'package:smartshop_app/services/auth_service.dart';
import 'package:smartshop_app/services/firestore_service.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _displayNameController;
  late TextEditingController _businessNameController;
  late TextEditingController _businessPhoneController;
  late TextEditingController _businessAddressController;

  bool _isLoading = false;
  bool _isEditing = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _businessNameController = TextEditingController();
    _businessPhoneController = TextEditingController();
    _businessAddressController = TextEditingController();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _businessNameController.dispose();
    _businessPhoneController.dispose();
    _businessAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _firestoreService.getCurrentUser();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _displayNameController.text = user.displayName ?? '';
          _businessNameController.text = user.businessName ?? '';
          _businessPhoneController.text = user.businessPhone ?? '';
          _businessAddressController.text = user.businessAddress ?? '';
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error loading profile: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestoreService.updateUser(user.uid, {
        'displayName': _displayNameController.text.trim(),
        'businessName': _businessNameController.text.trim(),
        'businessPhone': _businessPhoneController.text.trim(),
        'businessAddress': _businessAddressController.text.trim(),
      });

      setState(() => _isEditing = false);
      _showSuccessSnackBar('Profile updated successfully');
      _loadUserProfile();
    } catch (e) {
      _showErrorSnackBar('Error saving profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.blue.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue,
                          child: Text(
                            (_currentUser!.displayName ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Display Name or Email
                        Text(
                          _currentUser!.displayName ?? user?.email ?? 'User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Email
                        Text(
                          user?.email ?? 'N/A',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Member since
                        Text(
                          'Member since ${_formatDate(_currentUser!.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Form or View Mode
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: _isEditing
                        ? _buildEditForm()
                        : _buildViewMode(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Business Information Section
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Business Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Business Name', _currentUser!.businessName),
                const SizedBox(height: 12),
                _buildInfoRow('Phone', _currentUser!.businessPhone),
                const SizedBox(height: 12),
                _buildInfoRow('Address', _currentUser!.businessAddress),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Edit Button
        ElevatedButton.icon(
          onPressed: () => setState(() => _isEditing = true),
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        // Logout Button
        ElevatedButton.icon(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Display Name
          TextFormField(
            controller: _displayNameController,
            decoration: InputDecoration(
              labelText: 'Display Name',
              hintText: 'Enter your name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Business Name
          TextFormField(
            controller: _businessNameController,
            decoration: InputDecoration(
              labelText: 'Business Name',
              hintText: 'Enter your business name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 16),
          // Business Phone
          TextFormField(
            controller: _businessPhoneController,
            decoration: InputDecoration(
              labelText: 'Business Phone',
              hintText: 'Enter phone number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          // Business Address
          TextFormField(
            controller: _businessAddressController,
            decoration: InputDecoration(
              labelText: 'Business Address',
              hintText: 'Enter your business address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.location_on),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() => _isEditing = false);
                          _loadUserProfile();
                        },
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value?.isNotEmpty == true ? value! : 'Not set',
          style: TextStyle(
            fontSize: 14,
            color: value?.isNotEmpty == true ? Colors.black : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}
