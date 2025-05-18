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
          _datafetched=true;
        });
        if (kDebugMode) {
          print('Restro Name ${restaurant_details}');
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
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        restaurant_details['info']['name'],
                                        style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        '${restaurant_details['info']['sla']['slaString']} | ${restaurant_details['info']['locality']}',
                                        style: GoogleFonts.poppins(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 30,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade900,
                                          borderRadius: const BorderRadius.all(Radius.circular(50))
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(restaurant_details['info']['avgRatingString'],style: GoogleFonts.poppins(
                                                color: Colors.white,fontWeight: FontWeight.w700
                                              ),),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              const Icon(Icons.star,color: Colors.white,size: 15,)
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(restaurant_details['info']['totalRatingsString'],style: GoogleFonts.poppins(color: Colors.grey,
                                      fontSize: 10
                                      ),)
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
