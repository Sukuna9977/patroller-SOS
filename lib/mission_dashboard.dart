import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'mission_details.dart';
import 'SettingsPage.dart';
import 'profile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';  // Import localization class

class MissionDashboard extends StatefulWidget {
  final String token;

  const MissionDashboard({Key? key, required this.token}) : super(key: key);

  @override
  _MissionDashboardState createState() => _MissionDashboardState();
}

class _MissionDashboardState extends State<MissionDashboard> {
  List<Map<String, dynamic>> missions = [];
  List<Map<String, dynamic>> filteredMissions = [];
  bool isLoading = true;
  String searchQuery = "";
  String selectedUrgency = 'All';
  final Map<String, String> emergencyTypeToImage = {
    'ship collision': 'ship_collision.jpg',
    'grounding': 'grounding.jpg',
    'flooding': 'flooding.jpg',
    'fire': 'fire.jpg',
    'man overboard': 'man_overboard.jpg',
    'Machinery Failure': 'machinery_failure.jpg',
    'piracy and armed attacks': 'piracy.jpg',
    'medical emergency': 'medical_emergency.jpg',
    'search and rescue': 'search_and_rescue.jpg',
    'adverse weather conditions': 'adverse_weather_conditions.jpg',
  };

  final List<String> urgencyLevels = [
    'All',
    'Low (1-2)',
    'Medium (3)',
    'High (4)',
    'Critical (5)'
  ];

  @override
  void initState() {
    super.initState();
    fetchAssignedMissions();
  }

  Future<void> fetchAssignedMissions() async {
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
        if (mounted) {
          setState(() {
            missions = data.expand<Map<String, dynamic>>((patrol) =>
                patrol['assignedMissions']
                    .where((mission) => mission['cloture'] == 'false')
                    .map<Map<String, dynamic>>((mission) =>
                {
                  'title': mission['type'] ?? 'No Title',
                  'description': "Urgency: ${mission['niveau']} - ${mission['type']}",
                  'detailedDescription': getDetailedDescription(mission),
                  'location': '${mission['latitude']}, ${mission['longitude']}',
                  'time': mission['createdAt'] ?? 'Unknown Time',
                  'priority': mission['niveau'].toString() ?? 'Low',
                  'type': mission['type'] ?? 'Unknown',
                  'patrolId': patrol['_id'],
                  'missionId': mission['_id']
                })
            ).toList();
            filterMissions();
          });
        }
      } else {
        print('Failed to load patrols: ${response.body}');
      }
    } catch (e) {
      print('Error fetching patrols: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  void filterMissions() {
    List<Map<String, dynamic>> tempMissions = missions.where((mission) {
      return mission['title'].toLowerCase().contains(
          searchQuery.toLowerCase()) ||
          mission['description'].toLowerCase().contains(
              searchQuery.toLowerCase());
    }).toList();

    if (selectedUrgency != 'All') {
      int minLevel, maxLevel;
      switch (selectedUrgency) {
        case 'Low (1-2)':
          minLevel = 1;
          maxLevel = 2;
          break;
        case 'Medium (3)':
          minLevel = 3;
          maxLevel = 3;
          break;
        case 'High (4)':
          minLevel = 4;
          maxLevel = 4;
          break;
        case 'Critical (5)':
          minLevel = 5;
          maxLevel = 5;
          break;
        default:
          minLevel = 1;
          maxLevel = 5;
      }
      tempMissions = tempMissions.where((mission) {
        int level = int.tryParse(mission['priority']) ?? 0;
        return level >= minLevel && level <= maxLevel;
      }).toList();
    }

    setState(() {
      filteredMissions = tempMissions;
    });
  }

  String getDetailedDescription(Map<String, dynamic> mission) {
    return "${AppLocalizations.of(context)!.missionType}: ${mission['type']}\n"
        "${AppLocalizations.of(context)!.numberOfPeople}: ${mission['nbrpersonne']}\n"
        "${AppLocalizations.of(context)!.location}: ${mission['latitude']}, ${mission['longitude']}\n"
        "${AppLocalizations.of(context)!.departure}: ${mission['depart']}\n"
        "${AppLocalizations.of(context)!.sizeOfBoat}: ${mission['taille']}\n"
        "${AppLocalizations.of(context)!.currentStatus}: ${mission['status']}\n"
        "${AppLocalizations.of(context)!.urgencyLevel}: ${mission['niveau']}\n"
        "${AppLocalizations.of(context)!.reportedOn}: ${DateTime.parse(mission['createdAt']).toLocal()}\n"
        "${AppLocalizations.of(context)!.requiresImmediateAttention}";
  }

  Icon getMissionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'ship collision':
        return Icon(Icons.directions_boat, color: Colors.blue);
      case 'grounding':
        return Icon(Icons.landscape, color: Colors.brown);
      case 'flooding':
        return Icon(Icons.invert_colors, color: Colors.blue);
      case 'fire':
        return Icon(Icons.local_fire_department, color: Colors.red);
      case 'man overboard':
        return Icon(Icons.man, color: Colors.orange);
      case 'machinery failure':
        return Icon(Icons.build, color: Colors.grey);
      case 'piracy and armed attacks':
        return Icon(Icons.security, color: Colors.black);
      case 'medical emergency':
        return Icon(Icons.local_hospital, color: Colors.red);
      case 'search and rescue':
        return Icon(Icons.search, color: Colors.green);
      case 'adverse weather conditions':
        return Icon(Icons.cloud, color: Colors.grey);
      default:
        return Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [Colors.blueGrey.shade700, Colors.blueGrey.shade900]
                      : [Colors.blue.shade400, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black26
                        : Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    filterMissions();
                  });
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchMissions,
                  hintStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.8)
                          : Colors.white.withOpacity(0.8)),
                  prefixIcon: Icon(Icons.search,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.white),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blueGrey.shade800
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black26
                        : Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButton<String>(
                value: selectedUrgency,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUrgency = newValue!;
                    filterMissions();
                  });
                },
                items: urgencyLevels.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        _getUrgencyIcon(value),
                        const SizedBox(width: 10),
                        Text(value,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color)),
                      ],
                    ),
                  );
                }).toList(),
                isExpanded: true,
                dropdownColor: Theme.of(context).cardColor,
                underline: const SizedBox(),
                iconEnabledColor:
                Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredMissions.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.noMissionsFound))
                : ListView.builder(
              itemCount: filteredMissions.length,
              itemBuilder: (context, index) {
                final mission = filteredMissions[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  color: Theme.of(context).cardColor,
                  child: ListTile(
                    leading: getMissionIcon(mission['type']),
                    title: Text(
                      mission['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color,
                      ),
                    ),
                    subtitle: Text(
                      mission['description'],
                      style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MissionDetails(
                                title: mission['title'],
                                description: mission[
                                'detailedDescription'],
                                location: mission['location'],
                                time: mission['time'],
                                priority: mission['priority'],
                                imagePath: emergencyTypeToImage[
                                mission['type']] ??
                                    'flooding.jpg',
                                patrolId: mission['patrolId'],
                                missionId: mission['missionId']),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.details,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Icon _getUrgencyIcon(String urgency) {
    switch (urgency) {
      case 'Low (1-2)':
        return Icon(Icons.low_priority, color: Colors.green);
      case 'Medium (3)':
        return Icon(Icons.priority_high, color: Colors.orange);
      case 'High (4)':
        return Icon(Icons.warning, color: Colors.red);
      case 'Critical (5)':
        return Icon(Icons.error, color: Colors.purple);
      default:
        return Icon(Icons.all_inclusive, color: Colors.blue);
    }
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => ProfilePage(token: widget.token)));
            break;
          case 2:
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => SettingsPage(token: widget.token)));
            break;
        }
      },
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
      selectedItemColor: Theme
          .of(context)
          .colorScheme
          .primary,
      // Use primary color for selected item
      unselectedItemColor: Theme
          .of(context)
          .textTheme
          .bodyMedium
          ?.color ?? Colors.grey,
      // Ensure unselected items have a visible color
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
    );
  }
}
