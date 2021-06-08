import 'package:flutter/material.dart';
class PlacesDetail{
  final String icon;
  final String name;
  final bool openNow;
  final List weekDay;
  final List<ImageProvider> photos;
  final String placeId;
  final String priceLevel;
  final num rating;
  final List<String> types;
  final String vicinity;
  final String formattedAddress;
  final String reference;
  final String openingHours;
  final String website;
  final num utcOffset;
  final String formattedPhoneNumber;
  final String internationalPhoneNumber;


  PlacesDetail({
    this.openingHours,
    this.icon,
    this.name,
    this.openNow,
    this.photos,
    this.placeId,
    this.priceLevel,
    this.rating,
    this.types,
    this.vicinity,
    this.formattedAddress,
    this.weekDay,
    this.reference,
    this.website,
    this.utcOffset,
    this.formattedPhoneNumber,
    this.internationalPhoneNumber,
  });
}