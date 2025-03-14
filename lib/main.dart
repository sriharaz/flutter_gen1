import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'amplifyconfiguration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  void _configureAmplify() async {
    try {
      await Amplify.addPlugin(AmplifyAuthCognito());
      await Amplify.configure(amplifyconfig);
      safePrint('Successfully configured');
    } on Exception catch (e) {
      safePrint('Error configuring Amplify: $e');
    }
  }

  /// Signs a user up with a username, password, and email. The required
/// attributes may be different depending on your app's configuration.
Future<void> signUpUser({
 required String username,
 required String password,
 required String email,
 String? phoneNumber,
}) async {
 try {
   final userAttributes = {
     AuthUserAttributeKey.email: email,
     if (phoneNumber != null) AuthUserAttributeKey.phoneNumber: phoneNumber,
     // additional attributes as needed
   };
   final result = await Amplify.Auth.signUp(
     username: username,
     password: password,
     options: SignUpOptions(
       userAttributes: userAttributes,
     ),
   );
   await _handleSignUpResult(result);
 } on AuthException catch (e) {
   safePrint('Error signing up user: ${e.message}');
 }
}

Future<void> _handleSignUpResult(SignUpResult result) async {
  switch (result.nextStep.signUpStep) {
    case AuthSignUpStep.confirmSignUp:
      final codeDeliveryDetails = result.nextStep.codeDeliveryDetails!;
      _handleCodeDelivery(codeDeliveryDetails);
      break;
    case AuthSignUpStep.done:
      safePrint('Sign up is complete');
      break;
  }
}

void _handleCodeDelivery(AuthCodeDeliveryDetails codeDeliveryDetails) {
  safePrint(
    'A confirmation code has been sent to ${codeDeliveryDetails.destination}. '
    'Please check your ${codeDeliveryDetails.deliveryMedium.name} for the code.',
  );
}

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        builder: Authenticator.builder(),
        home: const Scaffold(
          body: Center(
            child: Text('You are logged in!'),
          ),
        ),
      ),
    );
  }
}