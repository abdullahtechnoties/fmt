import 'package:get/get.dart';

class ProductDetailsController extends GetxController {
  // Dummy Data to match the exact image
  final title = 'K-890 Kaisi Auto Ranging 6000 Counts AC/DC NCV Large-Screen Digital Multimeter'.obs;
  final currentPrice = 5250.0.obs;
  final oldPrice = 5900.0.obs;
  final rating = 4.5.obs;
  
  // Provide your actual dummy asset or network image here
  final productImages = [
    'https://www.fmtonlinestore.com/storage/5078/971433.jpg' // REPLACE WITH ASSET
  ].obs;

  final description = 'K-890 Kaisi Auto Ranging 6000 Counts AC/DC NCV Large-Screen Digital Multimeter.'.obs;
  final specificationsText = '''K-890 is a 3 5/6 high-precision digital instrument with functions of stable performance, battery-powered, high reliability and high accuracy.\nThe instrument is with 21mm supersized screen to keep a clear reading and peak value.\nAnd it is also can be used to test some parameters such as DC voltage, AC voltage, DC alternating current, resistors, capacitors, diodes, temperature, on and off, electric field induction, and frequency.\nThe entire machine takes double integral A / D conversion as the core, this is a superior power tool and ideal home furnishing tool for the laboratory, factories, radio enthusiasts.'''.obs;
  
  final features = [
    '1. Real effective measured value',
    '2. Supramaximal capacity measurement',
    '3. NCV electric field measurement',
    '4. 6000 bit range digital display',
    '5. 15 seconds backlight time',
    '6. Maximum / minimum value measurement',
    '7. Auto power-off'
  ].obs;

  final packageContent = '1 x Kaisi K-890 Professional LCD Electric Handheld Digital Multimeter Tester'.obs;

  final sku = 'K-890 Kaisi Auto Ranging 6000 Counts AC/DC NCV Large Screen Digital Multimeter'.obs;
  final category = 'Digital Multimeters'.obs;
  final availability = 'In Stock'.obs;
  final productType = 'Simple'.obs;
}