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
  @override
  bool _datafetched=false;
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchrestromenus();
  }

  late SharedPreferences prefs;
  Map<String, dynamic> restaurant_details = {};
  Map<String, dynamic> restaurant_menu_items = {};
  String restaurant_heading = "";
  Future<void> fetchrestromenus() async {
    prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(Uri.parse(
          'https://www.swiggy.com/dapi/menu/pl?page-type=REGULAR_MENU&complete-menu=true&lat=${prefs.getDouble('Latitude')}&lng=${prefs.getDouble('Longitude')}&restaurantId=${prefs.getString('Restro_ID')}&catalog_qa=undefined&submitAction=ENTER'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          restaurant_heading = data['data']['cards'][0]['card']['card']['text'];
          restaurant_details = data['data']['cards'][2]['card']['card'];
          restaurant_menu_items=data['data']['cards'][4]['groupedCard']['cardGroupMap']['REGULAR'];
          _datafetched=true;
        });
        if (kDebugMode) {
          print('Restro Name ${restaurant_menu_items['cards'][1]['card']['card']['title']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
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
      body:!_datafetched?Center(
        child: Center(
          child: LoadingAnimationWidget.discreteCircle(
            color: Colors.orange.shade900,
            size: 50,
          ),
        ),
      ) :SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 220,
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
                      height: 180,
                      width: MediaQuery.sizeOf(context).width,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.white),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 35,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left section with name and SLA/locality
                              Expanded( // <== Wrap to prevent overflow
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Text(
                                            restaurant_details['info']['name'] ?? '',
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 20,
                                            ),
                                            overflow: TextOverflow.ellipsis,
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
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Right section with ratings
                              Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade900,
                                        borderRadius: const BorderRadius.all(Radius.circular(50)),
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              restaurant_details['info']['avgRatingString'],
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            const Icon(
                                              Icons.star,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      restaurant_details['info']['totalRatingsString'],
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

                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                Text(restaurant_menu_items['cards'][1]['card']['card']['title'],style: GoogleFonts.poppins(
                  color: Colors.black,fontWeight: FontWeight.w700,fontSize: 18
                ),)
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                height: 250, // Ensure a fixed height for scrolling content
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(restaurant_menu_items['cards'][1]['card']['card']['carousel'].length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Stack(
                          children: [
                            Positioned(
                              child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://media-assets.swiggy.com/swiggy/image/upload/${restaurant_menu_items['cards'][1]['card']['card']['carousel'][i]['creativeId']}',
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            ),),
                            Positioned(
                                bottom: 10,
                                left: 10,
                                child: Text(
                                  (restaurant_menu_items['cards'][1]['card']['card']['carousel'][i]['dish']['info']['finalPrice'] != null
                                      ? ('₹'+(restaurant_menu_items['cards'][1]['card']['card']['carousel'][i]['dish']['info']['finalPrice'] / 100).toStringAsFixed(2))
                                      : 'Coming Soon'),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )

                            )
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
