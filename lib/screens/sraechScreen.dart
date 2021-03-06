import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart';
import 'package:pai_nai/Assistants/requestAssistant.dart';
import 'package:pai_nai/DataHandler/appData.dart';
import 'package:pai_nai/Models/address.dart';
import 'package:pai_nai/Models/placePredictions.dart';
import 'package:pai_nai/configMaps.dart';
import 'package:pai_nai/newscrssns/app_localizations.dart';
import 'package:pai_nai/widgets/Divider.dart';
import 'package:pai_nai/widgets/progressDialog.dart';
import 'package:provider/provider.dart';

class SearchScreens extends StatefulWidget {
  @override
  _SearchScreensState createState() => _SearchScreensState();
}

class _SearchScreensState extends State<SearchScreens> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<PlacePredictions> placePredictionList = [];
  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation.placeName ?? '';
    pickUpTextEditingController.text = placeAddress;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 215,
            decoration: BoxDecoration(
              color: HexColor("#29557a"),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18)),
              boxShadow: [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 6,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ],
            ),
            child: Padding(
              padding:
                  EdgeInsets.only(left: 25, top: 20, right: 25, bottom: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          )),
                      Center(
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('Set Drop Off'),
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Brand-Bold',
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.account_circle,
                        color: Colors.white,
                      ),
                      /* Image.asset(
                        'images/pickicon.png',
                        height: 20,
                        width: 20,
                        //color: Colors.white,
                      ), */
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: TextField(
                          onChanged: (val) {
                            findPlace(val);
                          },
                          controller: pickUpTextEditingController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)
                                .translate('PickUp Location'),
                            fillColor: Colors.white,
                            filled: true,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                EdgeInsets.only(left: 11, top: 8, bottom: 8),
                          ),
                        ),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.pin_drop,
                        color: Colors.white,
                      ),
                      /* Image.asset(
                        'images/desticon.png',
                        height: 20,
                        width: 20,
                      ), */
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: TextField(
                          onChanged: (val) {
                            findPlace(val);
                          },
                          controller: dropOffTextEditingController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)
                                .translate('Where to?'),
                            fillColor: Colors.white,
                            filled: true,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                EdgeInsets.only(left: 11, top: 8, bottom: 8),
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          (placePredictionList.length > 0)
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListView.separated(
                    padding: EdgeInsets.all(0),
                    itemBuilder: (context, index) {
                      return PredictionTile(
                        placePredictions: placePredictionList[index],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        DividerWidget(),
                    itemCount: placePredictionList.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:th';

      var res = await RequestAssistant.getRequest(autoCompleteUrl);

      if (res == 'failed') {
        return;
      }
      print('Place Prediction Response :: ');
      print(res);
      if (res['status'] == 'OK') {
        var predictions = res['predictions'];

        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();
        setState(() {
          placePredictionList = placesList;
        });
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePredictions;
  PredictionTile({Key key, this.placePredictions}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: () {
        getPlacerAddressDetails(placePredictions.place_id, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(
              width: 10,
            ),
            Row(
              children: [
                Icon(
                  Icons.add_location,
                  color: HexColor("#29557a"),
                ),
                SizedBox(
                  width: 14,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        placePredictions.main_text.toString(),
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(fontSize: 16, color: HexColor("#29557a")),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        placePredictions.secondary_text.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }

  void getPlacerAddressDetails(String placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: AppLocalizations.of(context)
                              .translate('Setting Dropoff, Please wait...'),
            ));
    String placeDetailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';

    var res = await RequestAssistant.getRequest(placeDetailsUrl);
    Navigator.pop(context);
    if (res == 'failed') {
      return;
    }
    if (res['status'] == 'OK') {
      Address address = Address();
      address.placeName = res['result']['name'];
      address.placeId = placeId;
      address.latitude = res['result']['geometry']['location']['lat'];
      address.longitude = res['result']['geometry']['location']['lng'];
      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocationaddress(address);
      print('This is Drop Off Location ::');
      print(address.placeName);
      Navigator.pop(context, 'obtainDirection');
    }
  }
}
