import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:weather/Weather.dart';
import 'package:http/http.dart' as http;
import 'package:weather/chooseLocation.dart';
import 'package:weather/forecast.dart';
import 'package:weather/widgets/dailyListView.dart';
import 'package:weather/widgets/hoursListView.dart';
import 'package:weather/widgets/weatherBox.dart';

class CurrentWeatherPage extends StatefulWidget {
  late String cityName;
  CurrentWeatherPage({Key? key, required this.cityName}) : super(key: key);

  @override
  State<CurrentWeatherPage> createState() => _CurrentWeatherPageState();
}

class _CurrentWeatherPageState extends State<CurrentWeatherPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: const Color(0xFFE5E5E5),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
            child: SingleChildScrollView(
              child: FutureBuilder(
                  future: getCurrentWeather(widget.cityName),
                  builder: (context, snapshot) {
                    Weather? weather;
                    if (snapshot != null) {
                      weather = snapshot.data as Weather?;
                      if (weather == null) {
                        return SizedBox(
                          height: screenHeight,
                          width: screenWidth,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: LoadingAnimationWidget.bouncingBall(
                                    color: Colors.black,
                                    size: 75,
                                  ),
                                ),
                                const Text(
                                  'Loading ... ',
                                  style: TextStyle(fontSize: 50),
                                )
                              ],
                            ),
                          ),
                        );
                      } else {
                        return SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: SizedBox(
                                  height: screenHeight * 0.4,
                                  width: screenWidth,
                                  child: WeatherBox(weather),
                                ),
                              ),
                              FutureBuilder(
                                future: getLocation(widget.cityName),
                                builder: (BuildContext context,
                                    AsyncSnapshot<dynamic> snapshot2) {
                                  return Column(children: [
                                    SizedBox(
                                      height: screenHeight * 0.2,
                                      child: hourlyListView(
                                          snapshot2.data!['lon'],
                                          snapshot2.data['lat']),
                                    ),
                                    dailyListView(snapshot2.data!['lon'],
                                        snapshot2.data['lat']),
                                  ]);
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      return errorIcon();
                    }
                  }),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (() {
            cities = allcities;
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: ((context) => const ChooseLocation())));
          }),
          backgroundColor: const Color(0xffe5e5e5),
          elevation: 3,
          child: const Icon(
            CupertinoIcons.location_fill,
            color: Color(0xFF14213D),
          ),
        ));
  }
}

Future getCurrentWeather(String city) async {
  Weather weather;

  final response = await http.get(Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=f54be8866d65f0cc3b9473f77b310168"));

  if (response.statusCode == 200) {
    weather = Weather.fromJson(jsonDecode(response.body));
    return weather;
  } else {
    return errorIcon();
  }
}

Widget errorIcon() {
  return Center(
      child:
          Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
    Icon(
      Icons.error,
      size: 40,
    ),
    Text(
      'Oups, we got a problem',
      style: TextStyle(
        fontSize: 25,
      ),
    )
  ]));
}
