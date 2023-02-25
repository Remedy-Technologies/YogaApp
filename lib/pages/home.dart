// ignore_for_file: prefer_const_constructors
//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:yoga_app/db/db.dart';
import 'package:yoga_app/pages/tracker.dart';
import 'package:yoga_app/pages/personaldet.dart';
import 'package:yoga_app/pages/settings.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:flutter/services.dart'; // take json
import 'dart:convert'; //json decode encode
import 'package:yoga_app/models/catalog.dart';
import 'package:yoga_app/utils/date_time.dart';

import '../utils/parq_check.dart';
import '../widgets/drawer.dart';
import 'dolist.dart';
import 'yoga_details.dart';
import 'package:yoga_app/utils/routes.dart';

import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    // Extracting json file
    //await Future.delayed(Duration(seconds: 2));
    var catalogJson = await rootBundle.loadString("assets/files/catalog.json");
    var decodeData = jsonDecode(catalogJson);
    var productsData = decodeData["sections"]; //Only products required
    CatalogModels.items = List.from(productsData)
        .map<Item>((item) => Item.fromMap(item))
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //String appName = "organizer";
    //final dummylist = List.generate(20, (index) => CatalogModels.items[0]);
    final habitbox = Hive.box("Habit_db");
    HabitDatabase db = HabitDatabase();
    return Scaffold(
      //Velocity Xp
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      drawer: AppDrawer(//creates menu button
          ),

      backgroundColor: context.cardColor,

      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 5, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CatalogHeader(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
                  child: CircularPercentIndicator(
                    radius: 200.0,
                    lineWidth: 12.0,
                    percent: double.parse(habitbox
                        .get("PERCENTAGE_SUMMARY_${todaysDateFormatted()}")),
                    center: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset("assets/images/bgless_app_logo.png"),
                    ),
                    progressColor: Colors.deepPurple,
                    backgroundColor: Colors.purpleAccent,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                ),
              ),
              if (CatalogModels.items.isNotEmpty) CatalogList().expand(),
            ],
          ),
        ),
      ),
    );
  }
}

class CatalogHeader extends StatelessWidget {
  const CatalogHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        "yogcare"
            .text
            .xl5
            .color(Colors.deepPurple)
            .textStyle(GoogleFonts.comfortaa(fontWeight: FontWeight.bold))
            .make(), // same as Text() but easy to use
        "Creating a Healthy Lifestyle"
            .text
            .xl
            .textStyle(GoogleFonts.comfortaa())
            .make()
      ],
    );
  }
}

class CatalogList extends StatefulWidget {
  const CatalogList({super.key});
  @override
  State<StatefulWidget> createState() => _CatalogListState();
}

class _CatalogListState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: CatalogModels.items.length,
      itemBuilder: (context, index) {
        final catalog = CatalogModels.items[index];
        // If else for diff pages
        if (catalog.id.toString() == "1") {
          return InkWell(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ParqCheck())),
              child: CatalogItem(catalog: catalog));
        }
        if (catalog.id.toString() == "2") {
          return InkWell(
              onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HabitPage()))
                  .then((value) => setState(() {})),
              child: CatalogItem(catalog: catalog));
        } else {
          return InkWell(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DoListPage())),
              child: CatalogItem(catalog: catalog));
        }
      },
    ).py12();
  }
}

class CatalogItem extends StatelessWidget {
  final Item catalog;
  const CatalogItem({super.key, required this.catalog});
  @override
  Widget build(BuildContext context) {
    return VxBox(
        //same as container but easy

        child: Row(
      children: [
        Hero(
          tag: Key(catalog.id.toString()), //tag on both sides
          child: Container(
            child: Image.network(catalog.img) //prod image
                .box
                .p12
                .roundedSM
                .color(context.cardColor)
                .make()
                .p16()
                .w32(context),
          ),
        ),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              catalog.name.text.xl
                  .textStyle(context.captionStyle)
                  .bold
                  .color(context.theme.buttonColor)
                  .make(), //prod name
              catalog.desc.text.make().py8(), //prod description
            ]))
      ],
    )).color(context.canvasColor).roundedSM.square(150).make().py16();
  }
}
