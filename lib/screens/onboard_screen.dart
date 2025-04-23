import 'package:access_address_app/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Color gradientColor1 = Color(0xFF4CB8C4);
Color gradientColor2 = Color(0xFF3CD3AD);
Color primaryTextColor = Colors.white;

const kAnimationDuration = Duration(milliseconds: 300);

class OnboardScreen extends StatefulWidget {
  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  int currentIndex = 0;
  late PageController _pageController;

  List<Map<String, String>> _screens = [
    {
      "title": "ابدأ صيانة سيارتك",
      "description": "استخدم تطبيقنا لطلب خدمات صيانة سيارتك بسهولة ويسر.",
      "image": "assets/images/splash-4.png",
    },
    {
      "title": "اختر الخدمة المناسبة",
      "description": "استعرض قائمة الخدمات المتاحة واختر ما يناسب احتياجات سيارتك.",
      "image": "assets/images/splash-5.png",
    },
    {
      "title": "احصل على الخدمة في الوقت المناسب",
      "description": "واحصل على صيانة سيارتك في الوقت المحدد.",
      "image": "assets/images/splash-6.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('isFirstLaunch');

    if (isFirstLaunch == null || isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false); // تعيين العلم إلى false
    } else {
      // إذا لم يكن أول تشغيل، التنقل مباشرة إلى صفحة تسجيل الدخول
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientColor1, gradientColor2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          PageView.builder(
            controller: _pageController,
            onPageChanged: (value) {
              setState(() {
                currentIndex = value;
              });
            },
            itemCount: _screens.length,
            itemBuilder: (context, index) {
              return PageBuilderWidget(
                title: _screens[index]["title"]!,
                description: _screens[index]["description"]!,
                imgurl: _screens[index]["image"]!,
              );
            },
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _screens.length,
                    (index) => buildDot(index: index),
              ),
            ),
          ),
          if (currentIndex == 0)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.1,
              left: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                children: [
                  Icon(
                    Icons.swipe,
                    color: primaryTextColor,
                    size: 30,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "اسحب للمتابعة",
                    style: TextStyle(color: primaryTextColor),
                  ),
                ],
              ),
            ),
          if (currentIndex == _screens.length - 1)
            Positioned(
              bottom: 50,
              left: MediaQuery.of(context).size.width * 0.2,
              right: MediaQuery.of(context).size.width * 0.2,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTextColor,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "ابدأ",
                  style: TextStyle(
                    color: Color(0xFF00A8A8),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: EdgeInsets.only(right: 5),
      height: 10,
      width: currentIndex == index ? 20 : 10,
      decoration: BoxDecoration(
        color: currentIndex == index ? primaryTextColor : Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class PageBuilderWidget extends StatelessWidget {
  final String title;
  final String description;
  final String imgurl;

  PageBuilderWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.imgurl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: kAnimationDuration,
      child: Container(
        key: ValueKey<String>(title),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imgurl,
                  fit: BoxFit.cover,
                  height: 300,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
