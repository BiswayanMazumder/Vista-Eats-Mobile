import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  String _address = "Loading...";
  String full_address = "";
  double longitude = 0;
  double latitude = 0;
  List<String> imageId = [];
  bool _datafetched=false;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    fetchapidata();
    fetchnearbytoprestaurants();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _address = "Location service disabled";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _address = "Location permission denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _address = "Location permission permanently denied";
      });
      return;
    }

    Position position =
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      _address = "${place.street}";
      full_address =
      "${place.street}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
    });
  }

  Future<void> fetchapidata() async {
    try {
      final response = await http.get(Uri.parse(
        'https://www.swiggy.com/dapi/restaurants/list/v5?lat=20.3168359&lng=85.8179029&is-seo-homepage-enabled=true&page_type=MOBILE_LISTING',
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> infoList =
        data['data']['cards'][0]['card']['card']['imageGridCards']['info'];

        final List<String> imageIds =
        infoList.map((item) => item['imageId'] as String).toList();

        setState(() {
          imageId = imageIds;
        });
      } else {
        if (kDebugMode) {
          print("Failed with status code: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in API: $e");
      }
    }
  }
  List<dynamic> restaurant_details=[];
  String restaurant_heading="";
  Future<void> fetchnearbytoprestaurants() async {
    final response = await http.get(Uri.parse(
        'https://www.swiggy.com/dapi/restaurants/list/v5?lat=20.3168359&lng=85.8179029&is-seo-homepage-enabled=true&page_type=MOBILE_LISTING'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        restaurant_heading=data['data']['cards'][1]['card']['card']['header']['title'];
      });
      final List<dynamic> infoList =
      data['data']['cards'][1]['card']['card']['gridElements']['infoWithStyle']['restaurants'];
      setState(() {
        restaurant_details=infoList;
        _datafetched=true;
      });

      if (kDebugMode) {
        print("Restaurant Details: $restaurant_details");
      }
    } else {
      if (kDebugMode) {
        print('Failed to load data');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with location and search
            Container(
              height: 185,
              width: MediaQuery.sizeOf(context).width,
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 15),
                          Icon(CupertinoIcons.location_fill, color: Colors.orange.shade900),
                          const SizedBox(width: 8),
                          Text(_address,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
                          InkWell(
                            onTap: _getCurrentLocation,
                            child: const Icon(Icons.arrow_drop_down_outlined),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {},
                            child: const CircleAvatar(
                              backgroundColor: Colors.black,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10)
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        color: Colors.grey.shade300,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          InkWell(
                            child: Icon(CupertinoIcons.mic_fill, color: Colors.orange.shade900),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Section title
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "What's on your mind?",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Horizontally scrollable images
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 100, // Ensure a fixed height for scrolling content
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(imageId.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'https://media-assets.swiggy.com/swiggy/image/upload/${imageId[i]}',
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                Text(restaurant_heading,style: GoogleFonts.poppins(
                  color: Colors.black,fontWeight: FontWeight.w600
                ),),
              ],
            ),
            // const SizedBox(height: 30),
           !_datafetched? Column(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               const SizedBox(
                 height: 80,
               ),
               LoadingAnimationWidget.discreteCircle(
                 color: Colors.orange.shade900,
                 size: 50,
               ),
             ],
           ): Column(
              children: [
                for(int j=0;j<restaurant_details.length;j++)
                  Padding(
                    padding: const EdgeInsets.only(left: 20,right: 20,top: 30),
                    child:restaurant_details[j]['info']['isOpen']? InkWell(
                      onTap: (){
                        if (kDebugMode) {
                          print("Restaurant ID:${restaurant_details[j]['info']['id']}");
                        }
                      },
                      child: Container(
                        // height: 400,
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.all(Radius.circular(20))
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                // Background Image
                                Positioned(
                                  child: Image.network(
                                    "https://media-assets.swiggy.com/swiggy/image/upload/${restaurant_details[j]['info']['cloudinaryImageId']}",
                                    width: MediaQuery.sizeOf(context).width,
                                    height: 220,
                                    fit: BoxFit.fill,
                                  ),
                                ),

                                // Small Box at Bottom Right
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "${restaurant_details[j]['info']['sla']['slaString']}",
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(restaurant_details[j]['info']['name'],style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20
                                ),),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                const CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 8,
                                  child: Icon(Icons.star,color: Colors.white,size: 11,),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text("${restaurant_details[j]['info']['avgRatingString']} (${restaurant_details[j]['info']['totalRatingsString']}) ${restaurant_details[j]['info']['locality']}, ${restaurant_details[j]['info']['sla']['lastMileTravelString']}",style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,color: Colors.grey
                                ),),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    restaurant_details[j]['info']['cuisines'].join(', '),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Text("${restaurant_details[j]['info']['costForTwo']}",style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,color: Colors.grey
                                ),),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Text("${restaurant_details[j]['info']['aggregatedDiscountInfoV3']['header']} ${restaurant_details[j]['info']['aggregatedDiscountInfoV3']['subHeader']}",style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,color: Colors.grey
                                ),),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ):Container(),
                  ),
                const SizedBox(
                  height: 30,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
