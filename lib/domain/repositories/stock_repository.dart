import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../entities/candle.dart';
import '../entities/stock.dart';
import '../entities/time_frame.dart';

abstract class StockRepository {
  Future<Either<Failure, List<Candle>>> getCandles({
    required String ticker,
    required TimeFrame timeFrame,
    required DateTime from,
    required DateTime to,
  });

  Future<Either<Failure, List<Stock>>> searchStocks(String query);

  Future<Either<Failure, StockDetail>> getStockDetail(String ticker);
}
