import 'package:flutter/material.dart';
import 'package:visiting_card_app/Screens/dashboard/dashboard_screen.dart';
import '../Model/user_profile.dart';
import '../utils/stream_builder.dart';
import '../widgets/profile_card.dart';

class DisplayProfileScreen extends StatelessWidget {
  final VisitingCard card;
  const DisplayProfileScreen({required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Received')),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Hero(tag: 'avatar', child: ProfileCard(profile: card, showQR: true)),
      ),
    );
  }
}
