import 'package:flutter/material.dart';

class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Add all your localization strings here
  String get appTitle => 'Patroller SOS';
  String get searchMissions => 'Search Missions';
  String get missions => 'Missions';
  String get profile => 'Profile';
  String get settings => 'Settings';
  String get details => 'Details';
  String get noMissionsFound => 'No missions found';
  String get missionType => 'Mission Type';
  String get numberOfPeople => 'Number of People';
  String get location => 'Location';
  String get departure => 'Departure';
  String get sizeOfBoat => 'Size of Boat';
  String get currentStatus => 'Current Status';
  String get urgencyLevel => 'Urgency Level';
  String get reportedOn => 'Reported On';
  String get requiresImmediateAttention => 'Requires Immediate Attention';
  String get error => 'Error';
  String get ok => 'OK';
  String get pageNotFound => 'Page Not Found';
  String get errorTokenNotFound => 'Error: Token not found';
  String get failedToLoadProfileData => 'Failed to load profile data';
  String get errorFetchingProfileData => 'Error fetching profile data';
  String get errorSelectingImageFromCamera => 'Error selecting image from camera';
  String get errorSelectingImageFromGallery => 'Error selecting image from gallery';
  String get updateProfilePicture => 'Update Profile Picture';
  String get email => 'Email';
  String get rank => 'Rank';
  String get teamMembers => 'Team Members';
  String get noTeamMembers => 'No Team Members';
  String get startMission => 'Start Mission';
  String get missionInProgress => 'Mission in Progress';
  String get submitReport => 'Submit Report';
  String get missionCompleted => 'Mission Completed';
  String get missionReport => 'Mission Report';
  String get missionFinished => 'Mission Finished';
  String get reportSubmitted => 'Report Submitted';
  
  // ADD THESE MISSING STRINGS:
  String get missionDetails => 'Mission Details';
  String get time => 'Time';
  String get priority => 'Priority';
  String get markAsComplete => 'Mark as Complete';
  String get start => 'Start';
  String get report => 'Report';
  String get enterYourReport => 'Enter your report';
  String get submit => 'Submit';
  String get language => 'Language';
  String get darkMode => 'Dark Mode';
  String get changePassword => 'Change Password';
  String get logOut => 'Log Out';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations();

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
