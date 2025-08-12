import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visiting_card_app/Theme/theme.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../Database/database.dart';
import '../Model/user_profile.dart';
import '../utils/app_helper.dart';
import '../widgets/profile_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _visible = false;
  bool _isLocked = false;
  File? _profileImage;
  VisitingCard? _visitingCard;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _loadCardData();
    _slideController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -1),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 300), () {
      setState(() => _visible = true);
    });
  }

  Future<void> _loadCardData() async {
    final allCards = await DBService.getAllVisitingCards();
    final userCards = allCards.where((card) => card.type == CardType.user);

    setState(() {
      _visitingCard = userCards.isNotEmpty ? userCards.first : null;
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await AppHelper.pickImageFromGallery();
    if (image != null) {
      setState(() => _profileImage = image);
    }
  }

  void _unlockScreen() async {
    await _slideController.forward();
    setState(() => _isLocked = false);
    _slideController.reset();
  }

  Widget _buildLockOverlay(BuildContext context) {
    return AnimatedSlide(
      offset: _isLocked ? Offset.zero : Offset(0, -1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! < -20) {
            _unlockScreen();
          }
        },
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Blur effect
              BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: Container(color: Colors.black.withOpacity(0.5))),
              // Lock content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_rounded, size: 90, color: Colors.white70),
                  SizedBox(height: 16),
                  Text("Screen Locked", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white70)),
                  SizedBox(height: 8),
                  Text("Swipe up to unlock", style: TextStyle(fontSize: 16, color: Colors.white60)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          !_isLocked
              ? Container(
                padding: EdgeInsets.all(5.r),
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.lightPurple),
                child: IconButton(
                  onPressed: () => setState(() => _isLocked = true),
                  icon: Icon(Icons.lock_outline, color: AppColors.white),
                ),
              )
              : null,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB39DDB), Color(0xFFFFF9F0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: Duration(milliseconds: 700),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      _visitingCard != null
                          ? ProfileCard(
                            profile: _visitingCard!, // null-asserted here after check
                            showQR: true,
                            imageFile: _profileImage,
                            onImagePick: _pickImage,
                          )
                          : Center(child: Text("No card found", style: TextStyle(color: Colors.black54, fontSize: 16))),
                ),
              ),
            ),
          ),
          if (_isLocked) _buildLockOverlay(context),
        ],
      ),
    );
  }
}
