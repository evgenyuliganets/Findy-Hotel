class SearchFilterModel{
  final num radius;
  final String keyword;
  final String minprice;
  final String maxprice;
  final String pagetoken;
  final String rankby;
  SearchFilterModel({this.rankby,this.radius,this.keyword,this.minprice, this.maxprice, this.pagetoken,});
}