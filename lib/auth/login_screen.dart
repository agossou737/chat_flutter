import 'package:chat_app/providers/auth_provider/auth_provider.dart';
import 'package:chat_app/utilities/asset_manager.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneNumberController = TextEditingController();

  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  Country selectedCountry = Country(
    phoneCode: '229',
    countryCode: 'BJ',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Bénin',
    example: 'Bénin',
    displayName: 'Bénin',
    displayNameNoCountryCode: 'BJ',
    e164Key: '',
  );

  @override
  void dispose() {
    phoneNumberController.dispose();
    // btnController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final _authProvider = Provider.of<AuthentificationProvider>(context);
    final authProvider = context.watch<AuthentificationProvider>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 15.0,
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 200.0,
                width: 200,
                child: Lottie.asset(
                  AssetManager.chatBubble,
                ),
              ),
              Text(
                "Flutter Chat Pro",
                style: GoogleFonts.openSans(
                  textStyle: const TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                "Entrez votre numéro de téléphone",
                style: GoogleFonts.openSans(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14.0,
                      horizontal: 14.0,
                    ),
                    child: InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          countryListTheme: const CountryListThemeData(
                            bottomSheetHeight: 400,
                          ),
                          onSelect: (Country country) {
                            setState(() {
                              selectedCountry = country;
                            });
                          },
                        );
                      },
                      child: Text(
                          "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                          style: GoogleFonts.openSans(
                            textStyle: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          )),
                    ),
                  ),
                  hintText: "Numéro de téléphone",
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: phoneNumberController.text.length == 8
                      ? authProvider.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )
                          : InkWell(
                              onTap: () {
                                authProvider.signInWithPhoneNumber(
                                  phoneNumber:
                                      "+${selectedCountry.phoneCode}${phoneNumberController.text}",
                                  ctx: context,
                                );
                              },
                              child: Container(
                                height: 20,
                                width: 20,
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.done,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            )
                      : null,
                ),
                onChanged: (val) {
                  setState(
                    () {
                      phoneNumberController.text = val;
                    },
                  );
                },
                maxLength: 10,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
