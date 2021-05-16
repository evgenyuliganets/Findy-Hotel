import 'package:flutter/material.dart';
class PlacesSearch {
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
  final String id;
  final String reference;

  PlacesSearch({
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
    this.id,
    this.reference,
  });
}