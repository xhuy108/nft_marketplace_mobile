import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nft_marketplace_mobile/config/themes/media_resource.dart';
import 'package:nft_marketplace_mobile/presentation/collection/pages/create_collection_page.dart';
import 'package:nft_marketplace_mobile/presentation/home/pages/marketplace_screen.dart';
import 'package:nft_marketplace_mobile/presentation/nft/pages/create_nft_screen.dart';
import 'package:nft_marketplace_mobile/presentation/search/pages/search_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class MainScreen extends StatelessWidget {
  final int initialIndex;

  MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  late final PersistentTabController _controller =
      PersistentTabController(initialIndex: initialIndex);

  List<Widget> _buildScreens() {
    return [
      const MarketplaceScreen(),
      const SearchPage(),
      const CreateNFTScreen(),
      const CreateCollectionPage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(MediaResource.homeActiveIcon),
        inactiveIcon: SvgPicture.asset(MediaResource.homeIcon),
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: MarketplaceScreen.routeName,
          routes: {
            // CollectionDetailScreen.routeName: (context) =>
            //     CollectionDetailScreen(
            //       collection: NFTCollection(
            //         name: '',
            //         image: '',
            //         floor: '',
            //         volume: 0,
            //         changePercentage: 0,
            //         isVerified: false,
            //       ),
            //     ),
          },
        ),
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
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      hideNavigationBarWhenKeyboardAppears: true,
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
      backgroundColor: Colors.white,
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
      navBarHeight: kBottomNavigationBarHeight,
      navBarStyle:
          NavBarStyle.style3, // Choose the nav bar style with this property
    );
  }
}
