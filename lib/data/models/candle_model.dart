import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/candle.dart';

part 'candle_model.g.dart';

@JsonSerializable()
class CandleModel {
  @JsonKey(name: 'o')
  final double open;

  @JsonKey(name: 'h')
  final double high;

  @JsonKey(name: 'l')
  final double low;

  @JsonKey(name: 'c')
  final double close;

  @JsonKey(name: 'v')
  final double volume;

  @JsonKey(name: 'vw')
  final double? vwap;

  @JsonKey(name: 't')
  final int timestamp;

  @JsonKey(name: 'n')
  final int? transactions;

  CandleModel({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.vwap,
    required this.timestamp,
    this.transactions,
  });

  factory CandleModel.fromJson(Map<String, dynamic> json) =>
      _$CandleModelFromJson(json);

  Map<String, dynamic> toJson() => _$CandleModelToJson(this);

  Candle toEntity() {
    return Candle(
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
      vwap: vwap,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
      transactions: transactions,
    );
  }
}
