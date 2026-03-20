import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ubel/features/auction/presentation/screens/auction_detail_screen.dart';
import 'package:ubel/features/auction/presentation/screens/create_auction_screen.dart';
import 'package:ubel/features/auction/presentation/screens/home_screen.dart';
import 'package:ubel/features/auth/presentation/screens/login_screen.dart';
import 'package:ubel/features/auth/presentation/screens/register_screen.dart';
import 'package:ubel/features/bidding/presentation/screens/bids_screen.dart';
import 'package:ubel/features/profile/presentation/screens/profile_screen.dart';
import 'package:ubel/features/auth/presentation/providers/auth_provider.dart';
import 'package:ubel/widgets/bottom_nav.dart';
import 'package:ubel/widgets/sell_menu_dialog.dart';

// Import your custom solid nav bar widget here
// import 'package:ubel/widgets/custom_solid_bottom_nav.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/';

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: 'search',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(
                    icon: Icons.search,
                    title: 'Search',
                    message: 'Search functionality coming soon',
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-bids',
                name: 'my-bids',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child:
                      BidsScreen(), // Replace Placeholder with the real screen
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // Routes without bottom nav
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auction/:id',
        name: 'auction-detail',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: AuctionDetailScreen(
              auctionId: state.pathParameters['id']!,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // This Offset defines the slide starting point (1.0 = far right)
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;

              // Luxury Curve: fast start, slow smooth finish
              const curve = Curves.easeOutQuint;

              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            // Slightly slower duration feels more "Premium" and heavy
            transitionDuration: const Duration(milliseconds: 400),
          );
        },
      ),
      GoRoute(
        path: '/create-auction',
        name: 'create-auction',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const CreateAuctionScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // Defines the slide starting point (1.0 = far right)
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;

              // Using easeOutQuint for that "Premium" snap-to-place feel
              const curve = Curves.easeOutQuint;

              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            // 400ms matches your Detail screen for consistency
            transitionDuration: const Duration(milliseconds: 400),
          );
        },
      ),
    ],
  );
});

// --- REFACTORED SCAFFOLD ---
class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // 1. The Main Content with FADE THROUGH
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              // Curves.easeInOutCubic gives it that "Liquid" luxury feel
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOutCubic)
                      .animate(animation),
                  child: child,
                );
              },
              // The Key is CRITICAL. Without it, Flutter won't know the tab changed.
              child: Container(
                key: ValueKey<int>(navigationShell.currentIndex),
                child: navigationShell,
              ),
            ),
          ),

          // 2. The Floating Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: CustomSolidBottomNav(
                currentIndex: navigationShell.currentIndex,
                onTap: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
                onCenterTap: () {
                  // 1. Give physical feedback
                  HapticFeedback.mediumImpact();

                  // 2. Trigger the "Fusing" menu
                  showSellPopup(
                    context,
                  );
                },
                // onCenterTap: () => context.pushNamed('create-auction'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- PLACEHOLDER SCREEN ---

class PlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const PlaceholderScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
