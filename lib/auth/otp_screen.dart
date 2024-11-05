import 'package:chat_app/providers/auth_provider/auth_provider.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController controller = TextEditingController();

  final FocusNode focusNode = FocusNode();

  String? otpCode;

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final phoneNumber = args[Constants.phoneNumber] as String;
    final verificationId = args[Constants.verificationId] as String;

    final AuthentificationProvider _authProvider =
        context.watch<AuthentificationProvider>();

    final defaultTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.openSans(
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade200,
        border: Border.all(
          color: Colors.transparent,
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Text("Vérification",
                      style: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                  const SizedBox(height: 50),
                  Text(
                    "Veuillez entrer le code à 6 chiffres que vous avez reçu",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    phoneNumber,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  _authProvider.isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          height: 68,
                          child: Pinput(
                            length: 6,
                            controller: controller,
                            focusNode: focusNode,
                            defaultPinTheme: defaultTheme,
                            onCompleted: (v) {
                              print(v);
                              setState(() {
                                otpCode = v;
                              });

                              _verifyOtp(
                                verificationId: verificationId,
                                otpCode: otpCode!,
                              );
                            },
                            focusedPinTheme: defaultTheme.copyWith(
                              height: 68,
                              width: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade200,
                                border: Border.all(
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                            errorPinTheme: defaultTheme.copyWith(
                              height: 68,
                              width: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade200,
                                border: Border.all(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 50,
                  ),
                  // _authProvider.isLoading
                  //     ? const CircularProgressIndicator()
                  //     : const SizedBox.shrink(),
                  _authProvider.isSuccessFul
                      ? Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.done,
                            color: Colors.white,
                            size: 30,
                          ),
                        )
                      : const SizedBox.shrink(),
                  _authProvider.isLoading
                      ? const SizedBox.shrink()
                      : Text(
                          "Code non reçu ?",
                          style: GoogleFonts.openSans(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  _authProvider.isLoading
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: () {
                            // TODO: resend otp
                          },
                          child: Text(
                            "Renvoyez le code",
                            style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _verifyOtp({
    required String verificationId,
    required String otpCode,
  }) async {
    final AuthentificationProvider authProvider =
        context.read<AuthentificationProvider>();
    authProvider.verifyOtpCode(
      verificationId: verificationId,
      otpCode: otpCode,
      ctx: context,
      onSuccess: () async {
        // 1- check if user exists in firestore
        bool userExists = await authProvider.checkUserExists();

        if (userExists) {
          //2- if yes,
          // * get user informations from firestore
          await authProvider.getUserDataFromFireStore();
          // * save user informations to provider in shared preferences
          await authProvider.saveUserDataToSharedPreferences();
          // * navigate to home screen

          navigate(userExists: true);
        } else {
          //3- if not, create user

          Navigator.of(context).pushNamed(
            Constants.userInformationsScreen,
          );
        }
      },
    );
  }

  void navigate({required bool userExists}) {
    if (userExists) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Constants.homeScreen,
        (route) => false,
      );
    } else {
      Navigator.pushNamed(
        context,
        Constants.userInformationsScreen,
      );
    }
  }
}
