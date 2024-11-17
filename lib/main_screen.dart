import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nft_marketplace_mobile/config/themes/media_resource.dart';
import 'package:nft_marketplace_mobile/presentation/collection/pages/create_collection.dart';
import 'package:nft_marketplace_mobile/presentation/event/pages/event_page.dart';
import 'package:nft_marketplace_mobile/presentation/search/pages/search_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:nft_marketplace_mobile/core/common/widgets/custom_bottom_nav_bar.dart';
import 'package:nft_marketplace_mobile/presentation/home/pages/home_page.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final PersistentTabController _controller = PersistentTabController();

  List<Widget> _buildScreens() {
    return [
      const HomePage(),
      const SearchPage(),
      const CreateNFTScreen(),
      const CreateCollectionScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(MediaResource.homeActiveIcon),
        inactiveIcon: SvgPicture.asset(MediaResource.homeIcon),
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(MediaResource.searchActiveIcon),
        inactiveIcon: SvgPicture.asset(MediaResource.searchIcon),
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(MediaResource.calendarActiveIcon),
        inactiveIcon: SvgPicture.asset(MediaResource.calendarIcon),
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(MediaResource.profileActiveIcon),
        inactiveIcon: SvgPicture.asset(MediaResource.profileIcon),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        handleAndroidBackButtonPress: true, // Default is true.
        resizeToAvoidBottomInset:
            true, // This needs to be true if you want to move up the screen on a non-scrollable screen when keyboard appears. Default is true.
        stateManagement: true, // Default is true.
        hideNavigationBarWhenKeyboardAppears: true,
        popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
        backgroundColor: Colors.white,
        isVisible: true,
        animationSettings: const NavBarAnimationSettings(
          navBarItemAnimation: ItemAnimationSettings(
            // Navigation Bar's items animation properties.
            duration: Duration(milliseconds: 400),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: ScreenTransitionAnimationSettings(
            // Screen transition animation on change of selected tab.
            animateTabTransition: true,
            duration: Duration(milliseconds: 200),
            screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
          ),
        ),
        confineToSafeArea: true,
        navBarHeight: kBottomNavigationBarHeight,
        navBarStyle:
            NavBarStyle.style3, // Choose the nav bar style with this property
      ),
    );
  }
}
