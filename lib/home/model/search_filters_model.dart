class SearchFilterModel{
   num radius;
   String keyword;
   String minprice;
   String maxprice;
   String pagetoken;
   String rankBy;
  SearchFilterModel({this.radius=3000,this.keyword='',this.minprice='Null', this.maxprice='Null', this.pagetoken,this.rankBy=''});
}