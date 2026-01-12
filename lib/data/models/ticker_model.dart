import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/stock.dart';

part 'ticker_model.g.dart';

@JsonSerializable()
class TickerModel {
  final String ticker;
  final String name;
  final String market;
  final String locale;
  @JsonKey(name: 'primary_exchange')
  final String? primaryExchange;
  final String? type;
  final bool active;
  @JsonKey(name: 'currency_name')
  final String? currencyName;

  TickerModel({
    required this.ticker,
    required this.name,
    required this.market,
    required this.locale,
    this.primaryExchange,
    this.type,
    required this.active,
    this.currencyName,
  });

  factory TickerModel.fromJson(Map<String, dynamic> json) =>
      _$TickerModelFromJson(json);

  Map<String, dynamic> toJson() => _$TickerModelToJson(this);

  Stock toEntity() {
    return Stock(
      ticker: ticker,
      name: name,
      market: market,
      exchange: primaryExchange ?? '',
      type: type ?? 'CS',
      active: active,
    );
  }
}
