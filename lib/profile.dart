import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'mission_dashboard.dart';
import 'SettingsPage.dart';
import 'app_localizations.dart'; // Import for localization

class ProfilePage extends StatefulWidget {
  final String token;

  const ProfilePage({Key? key, required this.token}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
  Map<String, dynamic>? profileData;
  List<dynamic>? patrols = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3030/api/patrols/supervisor/patrols'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          profileData = data[0]['supervisor'];
          patrols = data;
          isLoading = false;
        });
      } else {
        _showErrorDialog(AppLocalizations.of(context)!.failedToLoadProfileData);
        setState(() => isLoading = false);
      }
    } catch (e) {
      _showErrorDialog('${AppLocalizations.of(context)!.errorFetchingProfileData}: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog('${AppLocalizations.of(context)!.errorSelectingImageFromCamera}: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog('${AppLocalizations.of(context)!.errorSelectingImageFromGallery}: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.error),
          content: Text(message),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Consistent background color

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileData == null
          ? Center(child: Text(AppLocalizations.of(context)!.failedToLoadProfileData))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : const AssetImage('assets/profile.png')
                        as ImageProvider,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${profileData!['name']}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 5),
                      ElevatedButton.icon(
                        onPressed: _pickImageFromCamera,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        icon: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.onPrimary),
                        label: Text(
                          AppLocalizations.of(context)!.updateProfilePicture,
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.email, color: Theme.of(context).colorScheme.primary),
                      title: Text(AppLocalizations.of(context)!.email),
                      subtitle: Text(
                        '${profileData!['email']}',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
                      title: Text(AppLocalizations.of(context)!.rank),
                      subtitle: Text(
                        '${profileData!['rank']}',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.group, color: Theme.of(context).colorScheme.primary),
                      title: Text(AppLocalizations.of(context)!.teamMembers),
                      subtitle: Text(
                        patrols!.isNotEmpty && patrols![0]['teamMembers'] != null
                            ? patrols![0]['teamMembers'].join(', ')
                            : AppLocalizations.of(context)!.noTeamMembers,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Index 1 for ProfilePage
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MissionDashboard(token: widget.token)));
              break;
            case 1:
            // Current page
              break;
            case 2:
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SettingsPage(token: widget.token)));
              break;
          }
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).unselectedWidgetColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: AppLocalizations.of(context)!.missions,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppLocalizations.of(context)!.profile,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }
}
