class SearchFilterModel{
   num radius;
   String keyword;
   int minprice;
   int maxprice;
   String pagetoken;
   bool rankBy;
  SearchFilterModel({this.radius=3000,this.keyword='',this.minprice=null, this.maxprice=null, this.pagetoken,this.rankBy=false});
}