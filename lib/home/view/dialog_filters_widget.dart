import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FiltersWidget extends StatefulWidget {
  final SearchFilterModel filterModel;
  FiltersWidget({this.filterModel});
  @override
  _FiltersWidgetState createState() => _FiltersWidgetState();

}
class _FiltersWidgetState extends State<FiltersWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final chipsValuesKeywords = List<String>.of([
      AppLocalizations.of(context).searchFilterKeyword1,
      AppLocalizations.of(context).searchFilterKeyword2,
      AppLocalizations.of(context).searchFilterKeyword3,
      AppLocalizations.of(context).searchFilterKeyword4,]);
    final chipsValuesMinPrice = List<String>.of([
      AppLocalizations.of(context).searchFilterPriceLevel1,
      AppLocalizations.of(context).searchFilterPriceLevel2,
      AppLocalizations.of(context).searchFilterPriceLevel3,
      AppLocalizations.of(context).searchFilterPriceLevel4,
      AppLocalizations.of(context).searchFilterPriceLevel5,]);
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
                     AppLocalizations.of(context).searchFilterHeader,
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
                Text(widget.filterModel.rankBy?
                AppLocalizations.of(context).searchFilterError
                  :AppLocalizations.of(context).searchFilterRadius+
                      widget.filterModel.radius.round().toString() +
                    AppLocalizations.of(context).searchFilterMeters,
                  style: TextStyle(fontSize: 15),
                ),
                Container(
                  margin: EdgeInsets.only(top:2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(5)),
                      shape: BoxShape.rectangle,
                      border: Border.all(
                          color: Color(0xffdbdbdb))),
                  padding:
                  EdgeInsets.only(left: 5, right: 5),
                  child: Slider(
                    activeColor: Color(0xff636e86),
                    inactiveColor: Color(0xff9baed5),
                    value: widget.filterModel.radius.toDouble(),
                    min: 50,
                    max: 30000,
                    label: widget.filterModel.radius.toString(),
                    onChanged: (double value) {
                      if(widget.filterModel.rankBy){

                      }else{
                      setState(() =>
                      widget.filterModel.radius = value.toInt()
                      );
                    }},
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(AppLocalizations.of(context).searchFilterKeywordHeader),
                Container(
                  margin: EdgeInsets.only(top:2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(5)),
                      shape: BoxShape.rectangle,
                      border: Border.all(
                          color: Color(0xffdbdbdb))),
                  padding:
                  EdgeInsets.only(left: 5, right: 5),
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
                            label: Text(chipsValuesKeywords[index]),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(5.0))),
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  widget.filterModel.keyword = chipsValuesKeywords[index];

                                } else {
                                  widget.filterModel.keyword = null;
                                }
                              });
                            },
                            selected: widget.filterModel.keyword==(chipsValuesKeywords[index]),
                            selectedColor: Color(0xff9baed5),
                          ),
                        );
                      }),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(AppLocalizations.of(context).searchFilterMinPriceHeader),
                Container(
                  margin: EdgeInsets.only(top:2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(5)),
                      shape: BoxShape.rectangle,
                      border: Border.all(
                          color: Color(0xffdbdbdb))),
                  padding:
                  EdgeInsets.only(left: 5, right: 5),
                  height: 50,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: 5,
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
                                  widget.filterModel.minPrice = index;
                                  print(index);
                                }
                                else {
                                    widget.filterModel.minPrice= null;
                                    print(widget.filterModel.minPrice);
                                  }
                                }
                              );
                            },
                            selected: widget.filterModel.minPrice==index,
                            selectedColor: Color(0xff9baed5),
                          ),
                        );
                      }),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(AppLocalizations.of(context).searchFilterMaxPriceHeader),
                Container(
                  margin: EdgeInsets.only(top:2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(5)),
                      shape: BoxShape.rectangle,
                      border: Border.all(
                          color: Color(0xffdbdbdb))),
                  padding:
                  EdgeInsets.only(left: 5, right: 5),
                  height: 50,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: 5,
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
                                  {
                                    widget.filterModel.maxPrice= index;
                                  print(index);}
                                }
                                else {
                                  widget.filterModel.maxPrice= null;
                                  print(widget.filterModel.maxPrice);
                                }
                              });
                            },
                            selected: widget.filterModel.maxPrice==index,
                            selectedColor: Color(0xff9baed5),
                          ),
                        );
                      }),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(AppLocalizations.of(context).searchOrderHeader),
                Container(
                  margin: EdgeInsets.only(top:2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(5)),
                      shape: BoxShape.rectangle,
                      border: Border.all(
                          color: Color(0xffdbdbdb))),
                  padding:
                  EdgeInsets.only(left: 5, right: 5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: [
                      Text(AppLocalizations.of(context).searchOrder1),
                      Container(
                        height: 37,
                        width: 60,
                        child: Switch(
                            activeColor: Color(0xff636e86),
                            value: widget.filterModel.rankBy,
                            onChanged: (bool value) {
                              setState(() {
                                widget.filterModel.rankBy = value;
                              });
                            }),
                      ),
                      Text(AppLocalizations.of(context).searchOrder2),
                    ]),
                  ),
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
                        child: Text(AppLocalizations.of(context).searchFilterApplyButton,style: TextStyle(color: Colors.black87),),),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
