import 'dart:io';

import 'package:flutter/material.dart';

class AppBarBackBtn {
  static Widget appBarBackBtn(onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios_new,
      ),
    );
  }
}
