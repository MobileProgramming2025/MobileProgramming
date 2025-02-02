import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:sizer/sizer.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
//colors
const Color kPrimaryColor = Color(0xFF345FB4);
const Color kSecondaryColor = Color(0xFF6789CA);
const Color kTextBlackColor = Color(0xFF313131);
const Color kTextWhiteColor = Color(0xFFFFFFFF);
const Color kContainerColor = Color(0xFF777777);
const Color kOtherColor = Color(0xFFF4F6F7);
const Color kTextLightColor = Color(0xFFA5A5A5);
const Color kErrorBorderColor = Color(0xFFE74C3C);
const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);

const defaultPadding = 16.0;

//default value
const kDefaultPadding = 20.0;

const sizedBox = SizedBox(
  height: kDefaultPadding,
);
const kWidthSizedBox = SizedBox(
  width: kDefaultPadding,
);

const kHalfSizedBox = SizedBox(
  height: kDefaultPadding / 2,
);

const kHalfWidthSizedBox = SizedBox(
  width: kDefaultPadding / 2,
);

// Dynamically determine border radius based on screen size
BorderRadius kTopBorderRadius(BuildContext context) {
  final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
  return BorderRadius.only(
    topLeft: Radius.circular(isTablet ? 40 : 20),
    topRight: Radius.circular(isTablet ? 40 : 20),
  );
}

final kInputTextStyle = GoogleFonts.poppins(
  color: kTextBlackColor,
  fontSize: 11.dp,
  fontWeight: FontWeight.w500,
);

//validation for mobile
const String mobilePattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';

//validation for email
const String emailPattern =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';


