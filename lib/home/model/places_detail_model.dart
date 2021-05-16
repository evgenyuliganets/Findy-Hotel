import 'package:flutter/material.dart';
class PlacesDetail{
  final String icon;
  final String name;
  final bool openingHours;
  final List<ImageProvider> photos;
  final String placeId;
  final String priceLevel;
  final num rating;
  final List<String> types;
  final String vicinity;
  final String formattedAddress;
  final bool permanentlyClosed;
  final String reference;
  final String website;
  final num utcOffset;
  final String formattedPhoneNumber;
  final String internationalPhoneNumber;


  PlacesDetail({
    this.icon,
    this.name,
    this.openingHours,
    this.photos,
    this.placeId,
    this.priceLevel,
    this.rating,
    this.types,
    this.vicinity,
    this.formattedAddress,
    this.permanentlyClosed,
    this.reference,
    this.website,
    this.utcOffset,
    this.formattedPhoneNumber,
    this.internationalPhoneNumber,
  });
}