import 'dart:convert';
import 'package:Spark/models/user_profile.dart';
import 'package:Spark/widgets/swipe_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Spark/screens/home/notifications_screen.dart';
import 'package:Spark/widgets/choice_button.dart';

// Services
import 'package:Spark/services/profile_service.dart';
import 'package:Spark/widgets/lazy_loading_page.dart';

class HomePage extends StatefulWidget with LazyLoadingPage {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();

  @override
  Future<void> loadData() async {
    // Custom method to load data for this page
    await _HomePageState().getProfiles();
  }
}

class _HomePageState extends State<HomePage> {
  final ProfileServiceAPI _profileServiceAPI = ProfileServiceAPI();
  late Future<List<UserProfile>> _futureProfiles;

  @override
  void initState() {
    super.initState();
    _futureProfiles = getProfiles();
  }

  Future<List<UserProfile>> getProfiles() async {
    final response = await _profileServiceAPI.getPotentialMatches();
    if (response.statusCode == 200) {
      final List<UserProfile> profiles = [];
      for (final userId in jsonDecode(response.body)) {
        final userResponse = await _profileServiceAPI.getUserByID(userId);
        final profile = jsonDecode(userResponse.body);
        profiles.add(UserProfile.fromJson(profile));
      }
      return profiles;
    } else {
      return [];
    }
  }

  void _refreshProfiles() {
    setState(() {
      _futureProfiles = getProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: SvgPicture.asset(
                'assets/logo_Spark.svg',
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              flex: 7,
              child: Text(
                'Spark',
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Lobster',
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProfiles,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<UserProfile>>(
              future: _futureProfiles,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No profiles available'));
                } else {
                  List<UserProfile> profiles = snapshot.data!;
                  return SwipeCardWidget(profiles: profiles);
                }
              },
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 135.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ChoiceButton(
                  width: 50,
                  height: 50,
                  size: 25,
                  color: Theme.of(context).colorScheme.primary,
                  icon: Icons.clear_rounded,
                  onTap: () {
                    // Blocage de l'utilisateur
                    // await blockUser(user.id);
                  },
                ),
                ChoiceButton(
                  width: 50,
                  height: 50,
                  size: 25,
                  color: Theme.of(context).colorScheme.primary,
                  icon: Icons.favorite,
                  onTap: () {
                    // Ajout de l'utilisateur aux favoris
                    // await addFavorite(user.id);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}