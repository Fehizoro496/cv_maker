// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_personal_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvLink _$CvLinkFromJson(Map<String, dynamic> json) => _CvLink(
  id: json['id'] as String,
  label: json['label'] as String? ?? '',
  url: json['url'] as String? ?? '',
);

Map<String, dynamic> _$CvLinkToJson(_CvLink instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'url': instance.url,
};

_CvPersonalInfo _$CvPersonalInfoFromJson(Map<String, dynamic> json) =>
    _CvPersonalInfo(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      location: json['location'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      website: json['website'] as String? ?? '',
      links:
          (json['links'] as List<dynamic>?)
              ?.map((e) => CvLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CvLink>[],
    );

Map<String, dynamic> _$CvPersonalInfoToJson(_CvPersonalInfo instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'headline': instance.headline,
      'location': instance.location,
      'phone': instance.phone,
      'email': instance.email,
      'website': instance.website,
      'links': instance.links.map((e) => e.toJson()).toList(),
    };
