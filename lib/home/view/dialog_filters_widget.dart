import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FiltersWidget extends StatefulWidget {
  final SearchFilterModel filterModel;
  FiltersWidget({this.filterModel});
  @override
  _FiltersWidgetState createState() => _FiltersWidgetState();

}
class _FiltersWidgetState extends State<FiltersWidget> {
  String _finalKeyword;
  String _finalMin;
  String _finalMax;
  int _finalMinNum;
  int _finalMaxNum;
  final chipsValues =
      List<String>.of(['Restaurant', 'Bar', 'Spa', 'Campground']);
  final chipsValuesMinPrice = List<String>.of(['Null','Free', 'Inexpensive', 'Moderate', 'Expensive','Very Expensive']);
  final chipsValuesMaxPrice = List<String>.of(['Null','Free', 'Inexpensive', 'Moderate', 'Expensive','Very Expensive']);
  @override
  void initState() {
    super.initState();
    _finalMinNum = 0;
    _finalMaxNum= 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 100, top: 20),
        height: 200,
        child: Material(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: Container(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
                            icon: Icon(Icons.close,color: Colors.black38,))
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Radius: ' +
                      widget.filterModel.radius.round().toString() +
                      ' meters',
                  style: TextStyle(fontSize: 15),
                ),
                Slider(
                  activeColor: Color(0xff636e86),
                  inactiveColor: Color(0xff9baed5),
                  value: widget.filterModel.radius.toDouble(),
                  min: 50,
                  max: 30000,
                  label: widget.filterModel.radius.toString(),
                  onChanged: (double value) {
                    setState(() =>
                    widget.filterModel.radius = value.toInt()
                    );
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
                                  _finalKeyword=chipsValues[index];
                                widget.filterModel.keyword=_finalKeyword;
                              });
                            },
                            selected: widget.filterModel.keyword==(chipsValues[index]),
                            selectedColor: Color(0xff9baed5),
                          ),
                        );
                      }),
                ),
                SizedBox(
                  height: 10,
                ),
                Text('Minimum Price'),
                Container(
                  height: 50,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: 6,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: FilterChip(
                            labelStyle: TextStyle(),
                            label: Text(chipsValuesMinPrice[index]),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(5.0))),
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  if (_finalMinNum <= _finalMaxNum) {
                                    _finalMin = chipsValuesMinPrice[index];
                                    _finalMinNum = index;
                                    widget.filterModel.minprice= _finalMin;
                                  } else {
                                    _finalMin = chipsValuesMinPrice[0];
                                    _finalMinNum = 0;
                                    widget.filterModel.minprice= _finalMin;
                                  }
                                }
                              });
                            },
                            selected: widget.filterModel.minprice==chipsValuesMinPrice[index]&&_finalMinNum<=_finalMaxNum,
                            selectedColor: Color(0xff9baed5),
                          ),
                        );
                      }),
                ),
                SizedBox(
                  height: 10,
                ),
                Text('Maximum Price'),
                Container(
                  height: 50,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: 6,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: FilterChip(
                            labelStyle: TextStyle(),
                            label: Text(chipsValuesMaxPrice[index]),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(5.0))),
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  if (_finalMaxNum >= _finalMinNum) {
                                    _finalMax = chipsValuesMaxPrice[index];
                                    _finalMaxNum = index;
                                    widget.filterModel.maxprice= _finalMax;
                                  }
                                  else {
                                    _finalMax = chipsValuesMaxPrice[0];
                                    _finalMaxNum = 0;
                                    widget.filterModel.maxprice= _finalMax;
                                  }
                                }
                              });
                            },
                            selected: widget.filterModel.maxprice==chipsValuesMaxPrice[index]&&_finalMaxNum>=_finalMinNum,
                            selectedColor: Color(0xff9baed5),
                          ),
                        );
                      }),
                ),
                Spacer(),
                Row(
                  children: [
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 10,bottom: 5),
                      child: OutlinedButton(onPressed: (){
                        Navigator.of(context).pop(widget.filterModel);

                      },
                        child: Text('Apply',style: TextStyle(color: Colors.black87),),),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
