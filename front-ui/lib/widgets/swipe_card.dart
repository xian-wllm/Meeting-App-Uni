// ========== IMPORTS ========== //
// Flutter
import 'dart:ffi';

import 'package:Spark/models/user_profile.dart';
import 'package:Spark/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ========== SWIPE CARD ========== //
class SwipeCardWidget extends StatefulWidget {
  final List<UserProfile> profiles;

  const SwipeCardWidget({super.key, required this.profiles});

  @override
  _SwipeCardWidgetState createState() => _SwipeCardWidgetState();
}

class _SwipeCardWidgetState extends State<SwipeCardWidget> {
  final CardSwiperController controller = CardSwiperController();
  final ProfileServiceAPI _profileServiceAPI = ProfileServiceAPI();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        height: 750,
        child: CardSwiper(
          controller: controller,
          cardsCount: widget.profiles.length,
          numberOfCardsDisplayed: 1,
          onSwipe: (previousIndex, current, direction) => _onSwipe(previousIndex, current, direction),
          cardBuilder: (context, index, x, y) {
            UserProfile user = widget.profiles[index];
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 650,
                    child: Image.network(
                      user.profilePic ?? '', // Utilisation de ?? pour gérer le cas où profilePic est null
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(200, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullname,
                        style: const TextStyle(
                          fontSize: 30,
                          fontFamily: 'Lobster',
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        user.faculte ?? 'Faculté non renseignée',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30,
                    ),
                    onPressed: () {
                      _showProfileDialog(user);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _onSwipe(previousIndex, current, direction) {
    currentIndex = current!;
    if (direction == CardSwiperDirection.right) {
      _profileServiceAPI.acceptMatch(widget.profiles[currentIndex].id);
      Fluttertoast.showToast(msg: '🔥', backgroundColor: Colors.white, fontSize: 28);
    } else if (direction == CardSwiperDirection.left) {
      _profileServiceAPI.refuseMatch(widget.profiles[currentIndex].id);
      Fluttertoast.showToast(msg: '😖', backgroundColor: Colors.white, fontSize: 28);
    }
    return true;
  }

  void _showProfileDialog(UserProfile user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user.fullname),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                // Text('Date de naissance: ${user.dateOfBirth ?? "Non renseignée"}'),
                // const SizedBox(height: 15),
                Text('📧 Email: ${user.email}'),
                const SizedBox(height: 15),
                Text('📝 Description: ${user.description ?? "Non renseignée"}'),
                const SizedBox(height: 15),
                Text('🎓 Faculté: ${user.faculte ?? "Non renseignée"}'),
                const SizedBox(height: 15),
                Text('🚻 Genre: ${user.gender ?? "Non renseigné"}'),
                const SizedBox(height: 15),
                Text('🎨 Couleur préférée: ${user.couleur ?? "Non renseignée"}'),
                const SizedBox(height: 15),
                Text('💞 Intérêts: ${user.interests?.join(", ") ?? "Non renseignés"}'),
                const SizedBox(height: 15),
                Text('🗽 Centres d\'intérêt: ${user.centersOfInterest?.join(", ") ?? "Non renseignés"}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
