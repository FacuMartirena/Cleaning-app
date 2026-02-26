import 'package:flutter/material.dart';

import 'package:bo_cleaning/core/constants/globals.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Globals.white,
      body: Center(child: Text('Products')),
    );
  }
}
