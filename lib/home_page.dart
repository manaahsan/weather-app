import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// components
import 'package:weather_app/additional_info.dart';
import 'package:weather_app/hourly_forecast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Map<String, dynamic>> getWeather() async {
    try {
      String q = 'London';
      final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$q,uk&APPID=8fff5955e13ecbb88a9e065238bb9dc4'));
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw Exception('Error occurred');
      }
      return data;
    } catch (err) {
      throw Exception('Error fetching weather data: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          // if (snapshot.hasError) {
          //   return const Center(child: Text('Error occured'));
          // }

          // if (!snapshot.hasData || snapshot.data == null) {
          //   return const Center(child: Text('No data available'));
          // }
          final data = snapshot.data!;
          final base = data['list'][0];
          final temp = base['main']['temp'];
          final seasion = base['weather'][0]['main'];
          final humidity = base['main']['humidity'];
          final pressure = base['main']['pressure'];
          final speed = base['wind']['speed'];
          return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Scaffold(
                appBar: AppBar(
                  title: const Text(
                    "Weather App",
                    style: TextStyle(color: Colors.white),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: const Icon(Icons.refresh))
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    '$temp k',
                                    style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  Icon(
                                    seasion == 'Clouds' || seasion == 'Rain'
                                        ? Icons.cloud
                                        : Icons.sunny,
                                    size: 64,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '$seasion',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Hourly Forecast",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 130,
                        child: ListView.builder(
                            itemCount: 5,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final time = data['list'][index + 1]['dt_txt'];
                              final icon = data['list'][index + 1]['weather'][0]
                                              ['main']
                                          .toString() ==
                                      'Clouds'
                                  ? Icons.cloud
                                  : Icons.sunny;
                              final temp = data['list'][index]['main']['temp'];
                              final timeFormat = DateTime.parse(time);

                              return HourlyForeCast(
                                time: DateFormat.j().format(timeFormat),
                                icon: icon,
                                temperature: temp.toString(),
                              );
                            }),
                      ),
                      // SingleChildScrollView(
                      //   scrollDirection: Axis.horizontal,
                      //   child: Row(
                      //     children: [
                      //       for (int i = 1; i < 5; i++)
                      //         HourlyForeCast(
                      //           time: data['list'][i]['dt'].toString(),
                      //           icon: data['list'][i]['weather'][0]['main']
                      //                       .toString() ==
                      //                   'Clouds'
                      //               ? Icons.cloud
                      //               : Icons.sunny,
                      //           temperature:
                      //               data['list'][i]['main']['temp'].toString(),
                      //         ),
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Additional Information',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          AdditionalInfo(
                              icon: Icons.water_drop,
                              label: 'Humidity',
                              value: '$humidity'),
                          AdditionalInfo(
                              icon: Icons.air,
                              label: 'Wind Speed',
                              value: '$speed'),
                          AdditionalInfo(
                              icon: Icons.umbrella,
                              label: 'Pressure',
                              value: '$pressure')
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ));
        });
  }
}
