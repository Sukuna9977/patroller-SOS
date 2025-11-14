import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MissionDetails extends StatefulWidget {
  final String title;
  final String description;
  final String location;
  final String time;
  final String priority;
  final String imagePath;
  final String patrolId;
  final String missionId;

  const MissionDetails({
    required this.title,
    required this.description,
    required this.location,
    required this.time,
    required this.priority,
    required this.imagePath,
    required this.patrolId,
    required this.missionId,
  });

  @override
  _MissionDetailsState createState() => _MissionDetailsState();
}

class _MissionDetailsState extends State<MissionDetails> {
  bool _hasStarted = false;
  bool _showReportForm = false;
  bool _missionFinished = false;
  final TextEditingController _reportController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.missionDetails),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            const SizedBox(height: 20),
            _buildDetailsSection(localizations),
            const SizedBox(height: 20),
            _startButton(localizations),
            if (_showReportForm) _buildReportForm(localizations),
            if (_missionFinished) _missionFinishedText(localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Image.asset(
          widget.imagePath,
          width: MediaQuery.of(context).size.width,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDetailsSection(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.description,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 20),
          _infoSection(Icons.location_on, localizations.location, widget.location),
          _infoSection(Icons.access_time, localizations.time, widget.time),
          _infoSection(Icons.priority_high, localizations.priority, widget.priority),
        ],
      ),
    );
  }

  Widget _infoSection(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Text(
            "$label: $value",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateMission(String missionId, String report) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3030/api/urgences/update/$missionId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Include Authorization header if needed
          // 'Authorization': 'Bearer ${widget.token}',
        },
        body: json.encode({
          'cloture': 'true',
          'other': report,
        }),
      );
      if (response.statusCode == 200) {
        print('Mission updated successfully');
      } else {
        print('Failed to update mission: ${response.body}');
      }
    } catch (e) {
      print('Error updating mission: $e');
    }
  }

  Future<void> _updatePatrolStatus(String status) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3030/api/patrols/update/${widget.patrolId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({'status': status}),
      );
      if (response.statusCode == 200) {
        print('Patrol status updated');
      } else {
        print('Failed to update patrol status: ${response.body}');
      }
    } catch (e) {
      print('Error updating patrol status: $e');
    }
  }

  Widget _startButton(AppLocalizations localizations) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            if (_hasStarted) {
              _showReportForm = true;
              _updatePatrolStatus('standby');
            } else {
              _hasStarted = true;
              _updatePatrolStatus('on_mission');
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _hasStarted
              ? Colors.green
              : Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          minimumSize: const Size(200, 50),
        ),
        child: Text(
          _hasStarted ? localizations.markAsComplete : localizations.start,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildReportForm(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.report,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _reportController,
          decoration: InputDecoration(
            labelText: localizations.enterYourReport,
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              if (widget.missionId.isNotEmpty) {
                _updateMission(widget.missionId, _reportController.text);
                setState(() {
                  _showReportForm = false;
                  _hasStarted = false;
                  _missionFinished = true;
                  _reportController.clear();
                });
              } else {
                print('Mission ID is not set');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(200, 50),
            ),
            child: Text(
              localizations.submit,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _missionFinishedText(AppLocalizations localizations) {
    return Center(
      child: Text(
        localizations.missionFinished,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
