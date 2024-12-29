// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_sizer/flutter_sizer.dart';
// import 'constants.dart';

// class CustomTheme {
//   var baseTheme = ThemeData.light().copyWith(
//     scaffoldBackgroundColor: kPrimaryColor,
//     primaryColor: kPrimaryColor,
//     appBarTheme: AppBarTheme(
//       // Height for both phone and tablet
//       toolbarHeight: Device.screenType == ScreenType.tablet ? 9.h : 7.h,
//       backgroundColor: kPrimaryColor,
//       titleTextStyle: GoogleFonts.poppins(
//         fontSize: Device.screenType == ScreenType.tablet ? 12.sp : 13.sp,
//         fontWeight: FontWeight.w500,
//         letterSpacing: 2.0,
//       ),
//       iconTheme: IconThemeData(
//         color: kOtherColor,
//         size: Device.screenType == ScreenType.tablet ? 17.sp : 18.sp,
//       ),
//       elevation: 0,
//     ),
//     // Input decoration theme for all our app
//     inputDecorationTheme: InputDecorationTheme(
//       // Label style for formField
//       labelStyle: TextStyle(
//         fontSize: 11.sp,
//         color: kTextLightColor,
//         fontWeight: FontWeight.w400,
//       ),
//       // Hint style
//       hintStyle: TextStyle(
//         fontSize: 16.0,
//         color: kTextBlackColor,
//         height: 0.5,
//       ),
//       // Using underline input border (not outline)
//       enabledBorder: UnderlineInputBorder(
//         borderSide: BorderSide(color: kTextLightColor, width: 0.7),
//       ),
//       border: UnderlineInputBorder(
//         borderSide: BorderSide(color: kTextLightColor),
//       ),
//       disabledBorder: UnderlineInputBorder(
//         borderSide: BorderSide(color: kTextLightColor),
//       ),
//       // On focus, change color
//       focusedBorder: UnderlineInputBorder(
//         borderSide: BorderSide(
//           color: kPrimaryColor,
//         ),
//       ),
//       // Color changes when user enters wrong information,
//       // Validators will handle this
//       errorBorder: UnderlineInputBorder(
//         borderSide: BorderSide(color: kErrorBorderColor, width: 1.2),
//       ),
//       // Same on focus error color
//       focusedErrorBorder: UnderlineInputBorder(
//         borderSide: BorderSide(
//           color: kErrorBorderColor,
//           width: 1.2,
//         ),
//       ),
//     ),
//     textTheme: GoogleFonts.poppinsTextTheme().copyWith(
//       // Custom text for bodyText1
//       headlineSmall: GoogleFonts.chewy(
//         color: kTextWhiteColor,
//         // Condition if device is tablet or a phone
//         fontSize: Device.screenType == ScreenType.tablet ? 45.sp : 40.sp,
//       ),
//       bodyLarge: TextStyle(
//         color: kTextWhiteColor,
//         fontSize: 35.0,
//         fontWeight: FontWeight.bold,
//       ),
//       bodyMedium: TextStyle(
//         color: kTextWhiteColor,
//         fontSize: 28.0,
//       ),
//       titleMedium: TextStyle(
//         color: kTextWhiteColor,
//         fontSize: Device.screenType == ScreenType.tablet ? 14.sp : 17.sp,
//         fontWeight: FontWeight.w700,
//       ),
//       titleSmall: GoogleFonts.poppins(
//         color: kTextWhiteColor,
//         fontSize: Device.screenType == ScreenType.tablet ? 12.sp : 13.sp,
//         fontWeight: FontWeight.w200,
//       ),
//       bodySmall: GoogleFonts.poppins(
//         color: kTextLightColor,
//         fontSize: Device.screenType == ScreenType.tablet ? 5.sp : 7.sp,
//         fontWeight: FontWeight.w300,
//       ),
//     ),
//   );
// }
