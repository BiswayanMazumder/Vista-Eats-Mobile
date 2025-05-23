import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Menu_Details extends StatefulWidget {
  const Menu_Details({super.key});

  @override
  State<Menu_Details> createState() => _Menu_DetailsState();
}

class _Menu_DetailsState extends State<Menu_Details> {
  bool _datafetched = false;
  late SharedPreferences prefs;
  Map<String, dynamic> restaurant_details = {};
  Map<String, dynamic> restaurant_menu_items = {};
  Map<String, dynamic> restaurant_offers = {};
  String restaurant_heading = "";

  int _currentOfferIndex = 0;
  Timer? _offerTimer;

  @override
  void initState() {
    super.initState();
    fetchrestromenus();
    fetchrestrooffers();
  }

  Future<void> fetchrestromenus() async {
    prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(Uri.parse(
        'https://www.swiggy.com/dapi/menu/pl?page-type=REGULAR_MENU&complete-menu=true&lat=${prefs.getDouble('Latitude')}&lng=${prefs.getDouble('Longitude')}&restaurantId=${prefs.getString('Restro_ID')}&catalog_qa=undefined&submitAction=ENTER',
      ));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          restaurant_heading = data['data']['cards'][0]['card']['card']['text'];
          restaurant_details = data['data']['cards'][2]['card']['card'];
          restaurant_menu_items = data['data']['cards'][4]['groupedCard']
              ['cardGroupMap']['REGULAR'];
          _datafetched = true;
        });
        if (kDebugMode) {
          print(
              'Restro Name ${restaurant_menu_items['cards'][1]['card']['card']['title']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Picks error:$e");
      }
    }
  }

  Future<void> fetchrestrooffers() async {
    prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(Uri.parse(
        'https://www.swiggy.com/dapi/menu/pl?page-type=REGULAR_MENU&complete-menu=true&lat=${prefs.getDouble('Latitude')}&lng=${prefs.getDouble('Longitude')}&restaurantId=${prefs.getString('Restro_ID')}&catalog_qa=undefined&submitAction=ENTER',
      ));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          restaurant_offers = data['data']['cards'][3]['card']['card'];
          _datafetched = true;
        });
        _startOfferRotation();
        if (kDebugMode) {
          print('Restro Offers: $restaurant_offers');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _startOfferRotation() {
    _offerTimer?.cancel();
    _offerTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (!mounted) return;
      setState(() {
        int totalOffers =
            restaurant_offers['gridElements']['infoWithStyle']['offers'].length;
        _currentOfferIndex = (_currentOfferIndex + 1) % totalOffers;
      });
    });
  }

  @override
  void dispose() {
    _offerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
        ),
      ),
      body: !_datafetched
          ? Center(
              child: LoadingAnimationWidget.discreteCircle(
                color: Colors.orange.shade900,
                size: 50,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width,
                    decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(40)),
                      color: Colors.black,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 35),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const SizedBox(width: 20),
                                              Expanded(
                                                child: Text(
                                                  restaurant_details['info']
                                                          ['name'] ??
                                                      '',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 20,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const SizedBox(width: 20),
                                              Expanded(
                                                child: Text(
                                                  '${restaurant_details['info']['sla']['slaString']} | ${restaurant_details['info']['locality']}',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 15.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 30,
                                            width: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade900,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(50)),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    restaurant_details['info']
                                                        ['avgRatingString'],
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  const Icon(Icons.star,
                                                      color: Colors.white,
                                                      size: 15),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            restaurant_details['info']
                                                ['totalRatingsString'],
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey,
                                              fontSize: 10,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (restaurant_offers['gridElements']
                                        ['infoWithStyle']['offers']
                                    .isNotEmpty)
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(width: 20),
                                          Image.network(
                                            'https://media-assets.swiggy.com/swiggy/image/upload/${restaurant_offers['gridElements']['infoWithStyle']['offers'][_currentOfferIndex]['info']['logoBottom']}',
                                            height: 30,
                                            width: 30,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            restaurant_offers['gridElements']
                                                            ['infoWithStyle']
                                                        ['offers']
                                                    [_currentOfferIndex]['info']
                                                ['header'],
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Additional content like menu items can go here
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      restaurant_menu_items['cards'][1]['card']['card']['carousel'] !=
                              null
                          ? Text(
                              restaurant_menu_items['cards'][1]['card']['card']
                                  ['title'],
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18),
                            )
                          : Container(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  restaurant_menu_items['cards'][1]['card']['card']
                              ['carousel'] !=
                          null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(
                                  restaurant_menu_items['cards'][1]['card']
                                          ['card']['carousel']
                                      .length,
                                  (i) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 20.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          'https://media-assets.swiggy.com/swiggy/image/upload/${restaurant_menu_items['cards'][1]['card']['card']['carousel'][i]['creativeId']}',
                                          height: 200,
                                          width: 280,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
    );
  }
}
