class SearchFilterModel{
   num radius;
   String keyword;
   int minPrice;
   int maxPrice;
   String pageToken;
   bool rankBy;
  SearchFilterModel({this.radius=3000,this.keyword='',this.minPrice, this.maxPrice, this.pageToken,this.rankBy=false});
}