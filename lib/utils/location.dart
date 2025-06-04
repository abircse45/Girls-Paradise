import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LocationDropdown extends StatefulWidget {
  late String? selectedCity;
  late  String? selectedZone;
  late String? selectedArea;

   LocationDropdown({super.key, this.selectedCity, this.selectedZone, this.selectedArea});
  @override
  _LocationDropdownState createState() => _LocationDropdownState();
}

class _LocationDropdownState extends State<LocationDropdown> {
  List<dynamic> cityList = [];
  List<dynamic> zoneList = [];
  List<dynamic> areaList = [];



  @override
  void initState() {
    super.initState();


    fetchCities();
  }

  /// Fetch City List
  Future<void> fetchCities() async {
    final url =
        Uri.parse('https://girlsparadisebd.com/api/v1/pathao_city_list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        cityList = jsonData["data"] ?? [];
      });
    } else {
      print("Error fetching cities: ${response.statusCode}");
    }
  }

  /// Fetch Zone List (based on selected city)
  Future<void> fetchZones(String cityId) async {
    final url = Uri.parse(
        'https://girlsparadisebd.com/api/v1/pathao_city_zone_list/$cityId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        zoneList = jsonData["data"] ?? [];
        widget.selectedZone = null;
        areaList = [];
        widget.selectedArea = null;
      });
    } else {
      print("Error fetching zones: ${response.statusCode}");
    }
  }

  /// Fetch Area List (based on selected zone)
  Future<void> fetchAreas(String zoneId) async {
    final url = Uri.parse(
        'https://girlsparadisebd.com/api/v1/pathao_city_zone_area_list/$zoneId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        areaList = jsonData["data"] ?? [];
        widget.selectedArea = null;
      });
    } else {
      print("Error fetching areas: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // City Dropdown
        DropdownButtonFormField<String>(
          value:   widget.selectedCity,
          decoration: const InputDecoration(
            labelText: 'Select City*',
            border: OutlineInputBorder(),
          ),
          items: cityList.map((val) {
            return DropdownMenuItem(
              child: Text(val['city_name'] ?? "Unknown"),
              value: val['city_id']?.toString() ?? "",
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              widget.selectedCity = value;
              widget.selectedZone = null;
              widget.selectedArea = null;
              zoneList = [];
              areaList = [];
            });
            if (  widget.selectedCity != null &&   widget.selectedCity!.isNotEmpty) {
              fetchZones(  widget.selectedCity!);
            }
          },
        ),
        const SizedBox(height: 16),

        // Zone Dropdown (Only Show if City is Selected)
        if (zoneList.isNotEmpty)
          DropdownButtonFormField<String>(
            value:   widget.selectedZone,
            decoration: const InputDecoration(
              labelText: 'Select Zone*',
              border: OutlineInputBorder(),
            ),
            items: zoneList.map((val) {
              return DropdownMenuItem(
                child: Text(val['zone_name'] ?? "Unknown"),
                value: val['zone_id']?.toString() ?? "",
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                widget.selectedZone = value;
                widget.selectedArea = null;
                areaList = [];
              });
              if (  widget.selectedZone != null &&   widget.selectedZone!.isNotEmpty) {
                fetchAreas(  widget.selectedZone!);
              }
            },
          ),
        const SizedBox(height: 16),

        // Area Dropdown (Only Show if Zone is Selected)
        if (areaList.isNotEmpty)
          DropdownButtonFormField<String>(
            value:   widget.selectedArea,
            decoration: const InputDecoration(
              labelText: 'Select Area*',
              border: OutlineInputBorder(),
            ),
            items: areaList.map((val) {
              return DropdownMenuItem(
                child: Text(val['area_name'] ?? "Unknown"),
                value: val['area_id']?.toString() ?? "",
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                widget.selectedArea = value;
              });
            },
          ),
      ],
    );
  }
}
