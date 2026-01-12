import 'package:json_annotation/json_annotation.dart';
import 'ticker_model.dart';

part 'ticker_response.g.dart';

@JsonSerializable()
class TickerResponse {
  final List<TickerModel>? results;
  final String status;
  @JsonKey(name: 'request_id')
  final String? requestId;
  final int? count;
  @JsonKey(name: 'next_url')
  final String? nextUrl;

  TickerResponse({
    this.results,
    required this.status,
    this.requestId,
    this.count,
    this.nextUrl,
  });

  factory TickerResponse.fromJson(Map<String, dynamic> json) =>
      _$TickerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TickerResponseToJson(this);
}
