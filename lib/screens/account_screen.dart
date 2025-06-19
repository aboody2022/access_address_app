// import 'package:access_address_app/screens/login_page.dart';
// import 'package:adaptive_theme/adaptive_theme.dart';
// import 'package:auto_animated/auto_animated.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:hugeicons/hugeicons.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'edit_profile_screen.dart';
//
// class AccountScreen extends StatefulWidget {
//   final Map<String, dynamic>? userData;
//
//   const AccountScreen({Key? key, this.userData}) : super(key: key);
//
//   @override
//   State<AccountScreen> createState() => _AccountScreenState();
// }
//
// class _AccountScreenState extends State<AccountScreen> {
//   bool isNotificationsEnabled = true;
//   bool _isLoading = false;
//
//   late String fullName;
//   late String email;
//   late String password;
//   late String phoneNumber;
//   String? profileImagePath;
//   late int userID;
//
//   final _supabase = Supabase.instance.client;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeUserData();
//     _loadThemeMode();
//   }
//
//   Future<void> _loadThemeMode() async {
//     final savedThemeMode = await AdaptiveTheme.getThemeMode();
//     if (savedThemeMode != null && mounted) {
//       if (savedThemeMode == AdaptiveThemeMode.dark) {
//         AdaptiveTheme.of(context).setDark();
//       } else {
//         AdaptiveTheme.of(context).setLight();
//       }
//     }
//   }
//
//   void _initializeUserData() {
//     try {
//       if (widget.userData == null || widget.userData!['user_id'] == null) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _showMessage('خطأ: لم يتم العثور على بيانات المستخدم', true);
//           if (Navigator.canPop(context)) {
//             Navigator.pop(context);
//           }
//         });
//         return;
//       }
//
//       userID = widget.userData!['user_id'];
//       fullName = widget.userData?['full_name'] ?? 'مستخدم';
//       phoneNumber = widget.userData?['phone_number'] ?? 'غير متوفر';
//       email = widget.userData?['email'] ?? 'غير متوفر';
//       password = widget.userData?['password'] ?? '';
//       profileImagePath = widget.userData?['profile_picture'];
//
//       _refreshUserData();
//     } catch (e) {
//       print('Error initializing user data: $e');
//       _showMessage('حدث خطأ أثناء تحميل البيانات', true);
//     }
//   }
//
//   Future<void> _refreshUserData() async {
//     try {
//       setState(() => _isLoading = true);
//
//       final response = await _supabase
//           .from('users')
//           .select()
//           .eq('user_id', userID)
//           .single();
//
//       if (response.isNotEmpty) {
//         setState(() {
//           fullName = response['full_name'] ?? 'مستخدم';
//           phoneNumber = response['phone_number'] ?? 'غير متوفر';
//           email = response['email'] ?? 'غير متوفر';
//           password = response['password'] ?? '';
//           profileImagePath = response['profile_picture'];
//         });
//       }
//     } catch (e) {
//       print('Error refreshing user data: $e');
//       _showMessage('حدث خطأ أثناء تحديث البيانات', true);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _showMessage(String message, bool isError) {
//     if (!mounted) return;
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: TextStyle(
//             color: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark
//                 ? Colors.white
//                 : Colors.black,
//           ),
//         ),
//         backgroundColor: isError
//             ? Colors.red.withValues(alpha:0.9)
//             : Colors.green.withValues(alpha:0.9),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
//
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         body: RefreshIndicator(
//           onRefresh: _refreshUserData,
//           child: Stack(
//             children: [
//               Column(
//                 children: [
//                   // Header Container
//                   Container(
//                     width: size.width,
//                     height: size.height * 0.35,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: isDarkMode
//                             ? [Colors.grey[800]!, Colors.grey[900]!]
//                             : [const Color(0xFF4CB8C4), const Color(0xFF3CD3AD)],
//                         begin: Alignment.topRight,
//                         end: Alignment.bottomLeft,
//                       ),
//                       borderRadius: const BorderRadius.only(
//                         bottomLeft: Radius.circular(40),
//                         bottomRight: Radius.circular(40),
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         _buildProfileSection(),
//                         const SizedBox(height: 10),
//                         Text(
//                           fullName,
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: isDarkMode ? Colors.white : Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         Text(
//                           phoneNumber,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: isDarkMode
//                                 ? Colors.white70
//                                 : Colors.white.withValues(alpha:0.9),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Menu Items
//                   Expanded(
//                     child: LiveList(
//                       padding: const EdgeInsets.all(16.0),
//                       showItemInterval: const Duration(milliseconds: 100),
//                       showItemDuration: const Duration(milliseconds: 300),
//                       itemCount: _menuItems.length,
//                       itemBuilder: (context, index, animation) {
//                         final item = _menuItems[index];
//                         return FadeTransition(
//                           opacity: animation,
//                           child: SlideTransition(
//                             position: Tween<Offset>(
//                               begin: const Offset(0, 0.3),
//                               end: Offset.zero,
//                             ).animate(animation),
//                             child: item,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//
//                   // Version
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 16.0),
//                     child: Text(
//                       'Version 8.2.12',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: isDarkMode
//                             ? Colors.grey[400]
//                             : const Color(0xFF3CD3AD),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               if (_isLoading)
//                 Container(
//                   color: isDarkMode
//                       ? Colors.black.withValues(alpha:0.7)
//                       : Colors.black26,
//                   child: Center(
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         isDarkMode ? Colors.white : const Color(0xFF4CB8C4),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileSection() {
//     final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
//     return Stack(
//       alignment: Alignment.bottomRight,
//       children: [
//         CircleAvatar(
//           radius: 50,
//           backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
//           child: ClipOval(
//             child: _buildProfileImage(),
//           ),
//         ),
//         GestureDetector(
//           onTap: _showEditScreen,
//           child: CircleAvatar(
//             radius: 15,
//             backgroundColor: isDarkMode ? Colors.grey[700] : Colors.white,
//             child: Icon(
//               HugeIcons.strokeRoundedUserEdit01,
//               size: 16,
//               color: isDarkMode ? Colors.white : const Color(0xFF3CD3AD),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildProfileImage() {
//     final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
//     return Container(
//       width: 100,
//       height: 100,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: isDarkMode ? Colors.grey[800] : Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: isDarkMode
//                 ? Colors.black.withValues(alpha:0.3)
//                 : Colors.black.withValues(alpha:0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: ClipOval(
//         child: Image.asset(
//           'assets/images/user_profile.png',
//           width: 100,
//           height: 100,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) => Icon(
//             Icons.person,
//             size: 50,
//             color: isDarkMode ? Colors.white : const Color(0xFF4CB8C4),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildThemeSwitchTile() {
//     final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: isDarkMode ? Colors.grey[800] : Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: isDarkMode
//                 ? Colors.black.withValues(alpha:0.2)
//                 : Colors.grey.withValues(alpha:0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         leading: AnimatedSwitcher(
//           duration: const Duration(milliseconds: 300),
//           child: Icon(
//             isDarkMode ? Icons.dark_mode : Icons.light_mode,
//             key: ValueKey(isDarkMode),
//             color: isDarkMode ? Colors.amber : Colors.blue,
//             size: 24,
//           ),
//         ),
//         title: Text(
//           'الوضع الليلي',
//           style: TextStyle(
//             fontFamily: 'Cairo',
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: isDarkMode ? Colors.white : Colors.black87,
//           ),
//         ),
//         subtitle: Text(
//           isDarkMode ? 'مفعل' : 'غير مفعل',
//           style: TextStyle(
//             fontSize: 12,
//             color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//           ),
//         ),
//         trailing: Switch.adaptive(
//           value: isDarkMode,
//           activeColor: const Color(0xFF3CD3AD),
//           onChanged: (value) async {
//             await HapticFeedback.lightImpact();
//             if (value) {
//               AdaptiveTheme.of(context).setDark();
//             } else {
//               AdaptiveTheme.of(context).setLight();
//             }
//           },
//         ),
//       ),
//     );
//   }
//
//   List<Widget> get _menuItems => [
//     _buildSwitchTile('الإشعارات', isNotificationsEnabled, (value) {
//       setState(() => isNotificationsEnabled = value);
//     }),
//     _buildThemeSwitchTile(),
//     _buildNavigationTile('اللغة', 'العربية', Icons.language, () {}),
//     _buildNavigationTile('مساعدة', '', Icons.help_outline, () {}),
//     _buildNavigationTile(
//       'تسجيل خروج',
//       '',
//       Icons.logout,
//       _handleLogout,
//       iconColor: Colors.red,
//     ),
//   ];
//
//   Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
//     final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: isDarkMode ? Colors.grey[800] : Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: isDarkMode
//                 ? Colors.black.withValues(alpha:0.2)
//                 : Colors.grey.withValues(alpha:0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         title: Text(
//           title,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: isDarkMode ? Colors.white : Colors.black87,
//           ),
//         ),
//         trailing: Switch.adaptive(
//           value: value,
//           activeColor: const Color(0xFF3CD3AD),
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNavigationTile(
//       String title,
//       String subtitle,
//       IconData icon,
//       VoidCallback onTap, {
//         Color? iconColor,
//       }) {
//     final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: isDarkMode ? Colors.grey[800] : Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: isDarkMode
//                 ? Colors.black.withValues(alpha:0.2)
//                 : Colors.grey.withValues(alpha:0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         title: Text(
//           title,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: isDarkMode ? Colors.white : Colors.black87,
//           ),
//         ),
//         subtitle: subtitle.isNotEmpty
//             ? Text(
//           subtitle,
//           style: TextStyle(
//             fontSize: 14,
//             color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//           ),
//         )
//             : null,
//         trailing: Icon(
//           icon,
//           color: iconColor ??
//               (isDarkMode ? Colors.grey[400] : const Color(0xFF3CD3AD)),
//         ),
//         onTap: onTap,
//       ),
//     );
//   }
//
//   Future<void> _handleLogout() async {
//     try {
//       await _supabase.auth.signOut();
//       if (!mounted) return;
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoginPage()),
//       );
//     } catch (e) {
//       _showMessage('فشل تسجيل الخروج، يرجى المحاولة مرة أخرى.', true);
//     }
//   }
//
//   void _showEditScreen() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditProfileScreen(
//           initialName: fullName,
//           initialEmail:email,
//           initialPhoneNumber:phoneNumber,
//           initialPassword: password,
//           isDarkMode: Theme.of(context).brightness == Brightness.dark,
//           userData: widget.userData,
//         ),
//       ),
//     ).then((result) async {
//       if (result != null && result is Map<String, dynamic>) {
//         setState(() {
//           fullName = result['full_name'] ?? fullName;
//           phoneNumber = result['phone_number'] ?? phoneNumber;
//           email = result['email'] ?? email;
//           password = result['password'] ?? password;
//           profileImagePath = result['profile_picture'] ?? profileImagePath;
//         });
//         await _refreshUserData();
//       }
//     });
//   }
// }
import 'package:access_address_app/screens/login_page.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'edit_profile_screen.dart';

class AccountScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AccountScreen({Key? key, this.userData}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isNotificationsEnabled = true;
  bool _isLoading = false;

  late String fullName;
  late String email;
  late String password;
  late String phoneNumber;
  String? profileImagePath;
  late int userID;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _loadThemeMode();
  }


  Future<void> _loadThemeMode() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    if (savedThemeMode != null && mounted) {
      if (savedThemeMode == AdaptiveThemeMode.dark) {
        AdaptiveTheme.of(context).setDark();
      } else {
        AdaptiveTheme.of(context).setLight();
      }
    }
  }

  void _initializeUserData() {
    try {
      if (widget.userData == null || widget.userData!['user_id'] == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showMessage('خطأ: لم يتم العثور على بيانات المستخدم', true);
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        return;
      }

      userID = widget.userData!['user_id'];
      fullName = widget.userData?['full_name'] ?? 'مستخدم';
      phoneNumber = widget.userData?['phone_number'] ?? 'غير متوفر';
      email = widget.userData?['email'] ?? 'غير متوفر';
      password = widget.userData?['password'] ?? '';
      profileImagePath = widget.userData?['profile_picture'];

      _refreshUserData();
    } catch (e) {
      _showMessage('حدث خطأ أثناء تحميل البيانات', true);
    }
  }

  Future<void> _refreshUserData() async {
    try {
      setState(() => _isLoading = true);

      final response = await _supabase
          .from('users')
          .select()
          .eq('user_id', userID)
          .single();

      if (response.isNotEmpty) {
        setState(() {
          fullName = response['full_name'] ?? 'مستخدم';
          phoneNumber = response['phone_number'] ?? 'غير متوفر';
          email = response['email'] ?? 'غير متوفر';
          password = response['password'] ?? '';
          profileImagePath = response['profile_picture'];
        });
      }
    } catch (e) {
      _showMessage('حدث خطأ أثناء تحديث البيانات', true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, bool isError) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        backgroundColor: isError
            ? Colors.red.withValues(alpha:0.9)
            : Colors.green.withValues(alpha:0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _refreshUserData,
          child: Stack(
            children: [
              Column(
                children: [
                  // Header Container
                  Container(
                    width: size.width,
                    height: size.height * 0.35,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [Colors.grey[800]!, Colors.grey[900]!]
                            : [const Color(0xFF4CB8C4), const Color(0xFF3CD3AD)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildProfileSection(),
                        const SizedBox(height: 10),
                        Text(
                          fullName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          phoneNumber,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? Colors.white70
                                : Colors.white.withValues(alpha:0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu Items
                  Expanded(
                    child: LiveList(
                      padding: const EdgeInsets.all(16.0),
                      showItemInterval: const Duration(milliseconds: 100),
                      showItemDuration: const Duration(milliseconds: 300),
                      itemCount: _menuItems.length,
                      itemBuilder: (context, index, animation) {
                        final item = _menuItems[index];
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(animation),
                            child: item,
                          ),
                        );
                      },
                    ),
                  ),

                  // Version
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'الإصدار 1.0.2',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? Colors.grey[400]
                            : const Color(0xFF3CD3AD),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isLoading)
                Container(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha:0.7)
                      : Colors.black26,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? Colors.white : const Color(0xFF4CB8C4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          child: ClipOval(
            child: _buildProfileImage(),
          ),
        ),
        GestureDetector(
          onTap: _showEditScreen,
          child: CircleAvatar(
            radius: 15,
            backgroundColor: isDarkMode ? Colors.grey[700] : Colors.white,
            child: Icon(
              HugeIcons.strokeRoundedUserEdit01,
              size: 16,
              color: isDarkMode ? Colors.white : const Color(0xFF3CD3AD),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha:0.3)
                : Colors.black.withValues(alpha:0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/user_profile.png',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.person,
            size: 50,
            color: isDarkMode ? Colors.white : const Color(0xFF4CB8C4),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSwitchTile() {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha:0.2)
                : Colors.grey.withValues(alpha:0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            isDarkMode ? Icons.dark_mode : Icons.light_mode,
            key: ValueKey(isDarkMode),
            color: isDarkMode ? Colors.amber : Colors.blue,
            size: 24,
          ),
        ),
        title: Text(
          'الوضع الليلي',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          isDarkMode ? 'مفعل' : 'غير مفعل',
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: Switch.adaptive(
          value: isDarkMode,
          activeColor: const Color(0xFF3CD3AD),
          onChanged: (value) async {
            await HapticFeedback.lightImpact();
            if (value) {
              AdaptiveTheme.of(context).setDark();
            } else {
              AdaptiveTheme.of(context).setLight();
            }
          },
        ),
      ),
    );
  }

  List<Widget> get _menuItems => [
    _buildSwitchTile('الإشعارات', isNotificationsEnabled, (value) {
      setState(() => isNotificationsEnabled = value);
    }),
    _buildThemeSwitchTile(),
    _buildNavigationTile('اللغة', 'العربية', Icons.language, () {}),
    _buildNavigationTile(
      'مساعدة',
      '',
      Icons.help_outline,
          () {
        _showHelpDialog(context, AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark);
      },
    ),    _buildNavigationTile(
      'حذف الحساب',
      '',
      Icons.delete_forever,
      _handleDeleteAccount,
      iconColor: Colors.red,
    ),
    _buildNavigationTile(
      'تسجيل خروج',
      '',
      Icons.logout,
      _handleLogout,
      iconColor: Colors.red,
    ),
  ];

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha:0.2)
                : Colors.grey.withValues(alpha:0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        trailing: Switch.adaptive(
          value: value,
          activeColor: const Color(0xFF3CD3AD),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNavigationTile(
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap, {
        Color? iconColor,
      }) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha:0.2)
                : Colors.grey.withValues(alpha:0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        )
            : null,
        trailing: Icon(
          icon,
          color: iconColor ??
              (isDarkMode ? Colors.grey[400] : const Color(0xFF3CD3AD)),
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await _supabase.auth.signOut();
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      _showMessage('فشل تسجيل الخروج، يرجى المحاولة مرة أخرى.', true);
    }
  }

  Future<void> _handleDeleteAccount() async {
    final bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد حذف الحساب'),
          content: const Text('هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('حذف'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmDelete) {
      try {
        setState(() => _isLoading = true);
        // Delete user from Supabase auth
        await _supabase.rpc('delete_user_and_data', params: {'user_id_param': userID});

        // Sign out the user after deletion
        await _supabase.auth.signOut();

        if (!mounted) return;

        _showMessage('تم حذف الحساب بنجاح.', false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (e) {
        _showMessage('فشل حذف الحساب، يرجى المحاولة مرة أخرى.', true);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          initialName: fullName,
          initialEmail:email,
          initialPhoneNumber:phoneNumber,
          initialPassword: password,
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
          userData: widget.userData,
        ),
      ),
    ).then((result) async {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          fullName = result['full_name'] ?? fullName;
          phoneNumber = result['phone_number'] ?? phoneNumber;
          email = result['email'] ?? email;
          password = result['password'] ?? password;
          profileImagePath = result['profile_picture'] ?? profileImagePath;
        });
        await _refreshUserData();
      }
    });
  }


  void _showHelpDialog(BuildContext context, bool isDarkMode) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'مساعدة',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 48,
                    color: isDarkMode ? Colors.tealAccent : Color(0xFF1E1E1E),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'مساعدة تطبيق عنوان الوصول',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'يقدم التطبيق خدمات صيانة السيارات بجودة عالية وسرعة في التنفيذ.',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      final Uri telUri = Uri(scheme: 'tel', path: '+966507274427');
                      if (await canLaunchUrl(telUri)) {
                        await launchUrl(telUri);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('لا يمكن فتح تطبيق الاتصال')),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone,
                            color: isDarkMode ? Colors.tealAccent : Color(0xFF3CD3AD)),
                        const SizedBox(width: 8),
                        Text(
                          '+966 50 727 4427',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.tealAccent : Color(0xFF1E1E1E),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.tealAccent : Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'إغلاق',
                      style: TextStyle(
                        color: isDarkMode ? Colors.black : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }
}