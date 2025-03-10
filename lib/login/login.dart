import 'package:flutter/material.dart';
import 'validation.dart';
import 'input_field_containers.dart';
import '../usser/usserObject.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoginMode = true;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double width = size.width;
    final double height = size.height;

    // this function will be called when submit button is pressed
    void submitAction() async {
      print('BUTTON PRESSED');
      setState(() {
        emailErrorText = null;
        usernameErrorText = null;
        passwordErrorText = null;
      });
      print('BUTTON PRESSED2');

      // validates form
      if (_formKey.currentState!.validate()) {
        print('BUTTON PRESSED3');
        // if form validates successfully then this block executes

        Usser user = Usser(username.text, email.text, password.text, 'Light', null, 0, {});
        // the user is trying to login
        if (isLoginMode) {
          // will query to check the user's id in the database if they exist,
          // will also update the object's usserId if it exists
          String id = await user.getID();
          print(id);
          if (id == '') {
            // this means that the user does not exist within the database

            // need a way to be able to call the form field to add validation
            // to the input box to tell the user the username and email does not
            // exist
          }
          else {
            // the user exists within the database. Have to check the user's
            // inputted password with the stored password
            bool? isPasswordCorrect =  await user.passwordCorrect();

            // not worrying about it being null because the id check before
            // hand will check to see if the user is stored in the database
            if (isPasswordCorrect == true) {
              // this means that the user exists and the password is correct so
              // you can navigate the user to the appropriate screen

              // need to get the user's username as if they are logging in,
              // they won't be prompted to enter their username
              user.updateUsername();

              // ADD NAVIGATION TO OTHER SCREEN
              print("can add navigation to other screen");
            }
            else {
              // the password is incorrect so need to update the text form field
              // to let the user know that they've inputted the incorrect password
              setState(() { passwordErrorText = "Incorrect Password";});

            }
          }
        }
        // the user is trying to sign up
        else {
          print("USER IF TRYING TO SIGN UP");

          bool? usserExists = await user.checkUsserExists();

          print("CALLED METHOD");

          // can't simplify expression because method may return null
          if (usserExists == false) {
            // if the user does not exist, then you can insert the user into the
            // database
            print("going to create profile in database...");
            user.uploadUsser();
            print("uploaded user");

            // navigate to appropriate screen
            // NOW YOU CAN INSERT THE NAVIGATION TO THE PROJECT SCREEN
          }
          else if (usserExists == true) {
            // user exists
            setState(() {
              emailErrorText = "Email already in use";
            });
            print("email already exists!");
          }
          else {
            // null, means there was an error communicating with flask
            print("Error: $usserExists");
          }
        }
      }
    }

    void changePageState() {
      setState(() {
        isLoginMode = !isLoginMode;
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: Row(
        children: [
          // first half of the login screen DECORATION
          SizedBox(
            height: height,
            width: width * 0.5,
            child: Container(
              color: Colors.blue[800],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 200, width: 300 ,child: Image.asset("assets/login/welcome_image.jpg")),
                  const SizedBox(height: 20,),
                  Text("Welcome!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.grey[300])),
                ],
              ),
            ),
          ),
          // second half of the login screen USER DETAILS
          SizedBox(
            height: height,
            width: width * 0.5,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text((isLoginMode)?"Login":"Sign Up" , style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue[800]),),
                  // const SizedBox(height: 70),
                  emailContainer(),
                  (isLoginMode)?  const SizedBox(height: 50) : usernameContainer(),
                  const SizedBox(height: 50),
                  passwordContainer(),
                  const SizedBox(height: 50),
                  // confirm button
                  ElevatedButton(
                      onPressed: submitAction,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
                      child: const Text("confirm", style: TextStyle(color: Colors.white))),
                  const SizedBox(height: 20,),
                  // switch mode button
                  GestureDetector(
                    onTap: () {
                      changePageState();
                    },
                    child: Text((isLoginMode)?"Want to Sign Up?":"Want to Login?", style: const TextStyle(color: Colors.white70)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}