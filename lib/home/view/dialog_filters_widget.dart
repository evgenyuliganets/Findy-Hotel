import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FiltersWidget extends StatefulWidget {
  @override
  _FiltersWidgetState createState() => _FiltersWidgetState();
}

class _FiltersWidgetState extends State<FiltersWidget> {
  final filter = SearchFilterModel();
  String _finalType;
  double _currentSliderValue;
  final chipsValues =
      List<String>.of(['Restaurant', 'Bar', 'Spa', 'Campground']);

  @override
  void initState() {
    super.initState();
    _currentSliderValue= 1000;
    _finalType = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 200, top: 20),
        height: 200,
        child: Material(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Select Filters',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close))
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Radius: ' +
                      _currentSliderValue.round().toString() +
                      ' meters',
                  style: TextStyle(fontSize: 15),
                ),
                Slider(
                  activeColor: Color(0xff636e86),
                  inactiveColor: Color(0xff9baed5),
                  value: _currentSliderValue,
                  min: 50,
                  max: 30000,
                  label: _currentSliderValue.toString(),
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value;
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Text('Additional type of search'),
                Container(
                  height: 50,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: 4,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: FilterChip(
                            labelStyle: TextStyle(),
                            label: Text(chipsValues[index]),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(5.0))),
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected)
                                  _finalType=chipsValues[index];
                              });
                            },
                            selected: _finalType==(chipsValues[index]),
                            selectedColor: Color(0xff9baed5),
                          ),
                        );
                      }),
                )
              ],
            ),
          ),
        ));
  }
}
