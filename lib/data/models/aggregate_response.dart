import 'package:json_annotation/json_annotation.dart';
import 'candle_model.dart';

part 'aggregate_response.g.dart';

@JsonSerializable()
class AggregateResponse {
  final String? ticker;
  final int? queryCount;
  final int? resultsCount;
  final bool? adjusted;
  final List<CandleModel>? results;
  final String status;
  @JsonKey(name: 'request_id')
  final String? requestId;
  final int? count;

  AggregateResponse({
    this.ticker,
    this.queryCount,
    this.resultsCount,
    this.adjusted,
    this.results,
    required this.status,
    this.requestId,
    this.count,
  });

  factory AggregateResponse.fromJson(Map<String, dynamic> json) =>
      _$AggregateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AggregateResponseToJson(this);
}
