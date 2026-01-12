import 'package:equatable/equatable.dart';

class Stock extends Equatable {
  final String ticker;
  final String name;
  final String market;
  final String exchange;
  final String type;
  final bool active;

  const Stock({
    required this.ticker,
    required this.name,
    required this.market,
    required this.exchange,
    required this.type,
    required this.active,
  });

  @override
  List<Object?> get props => [ticker, name, market, exchange, type, active];
}

class StockDetail extends Stock {
  final String? description;
  final String? homepageUrl;
  final int? totalEmployees;
  final String? listDate;
  final double? marketCap;
  final String? sicDescription;

  const StockDetail({
    required super.ticker,
    required super.name,
    required super.market,
    required super.exchange,
    required super.type,
    required super.active,
    this.description,
    this.homepageUrl,
    this.totalEmployees,
    this.listDate,
    this.marketCap,
    this.sicDescription,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        description,
        homepageUrl,
        totalEmployees,
        listDate,
        marketCap,
        sicDescription,
      ];
}
