import 'package:flash_chat/components/roundedButton.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller; //for getting linear value.
  Animation animation; //for curve animation.

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 5),
      vsync:
          this, //to use object of current coding class we use 'this keyword'.
    );

//    curved animation.
//    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

//    color animation that show transition between colors.
    animation = ColorTween(begin: Colors.red, end: Colors.lightBlue)
        .animate(controller);

    controller.forward(); // start the animation.

//    infinite looping the animation.
    //we 1st set if animation completed then we will start another to like infinite loop.
//    animation.addStatusListener((status){
//      if (status == AnimationStatus.completed){
//        controller.reverse(from: 1);
//      }else if(status == AnimationStatus.dismissed){
//       controller.forward();
//      }
//    });

//    to get the value of controller
    controller.addListener(() {
      setState(() {});
    });
  }

//  dispose animation when we navigate to another page.
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'thunderLogo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 60,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  text: ['Flash Chat'],
                  textStyle: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.start,
                  totalRepeatCount: 1,
                  speed: Duration(milliseconds: 400),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              buttonName: 'Log In',
              colour: Colors.deepPurpleAccent,
              onPress: (){
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            RoundedButton(
              buttonName: 'Register',
              colour: Colors.purple,
              onPress: (){
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

