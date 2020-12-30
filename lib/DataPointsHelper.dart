class DataPointsHelper {
  DataPointsHelper(this.selectedGraphType);

  String selectedGraphType;
  String _periodValue;
  int _numberOfDataPoints;

  int get numberOfDataPoints => _numberOfDataPoints;

  String get periodValue => _periodValue;

  decideNumberOfDataPoints() {
    switch (selectedGraphType) {
      case '1D': // 1 day in 5-minute intervals
        {
          _periodValue = '300';
          _numberOfDataPoints = 289; //
        }
        break;
      case '5D': // 5 days in 30-minute intervals
        {
          _periodValue = '1800';
          _numberOfDataPoints = 241;
        }
        break;
      case '1M': // 1 month in 1-day intervals
        {
          _periodValue = '86400';
          _numberOfDataPoints = 31;
        }
        break;
      case '1Y': // 1 year in 3-day intervals
        {
          _periodValue = '259200';
          _numberOfDataPoints = 123;
        }
        break;
      case '5Y': // 5 years in 1-week intervals
        {
          _periodValue = '604800';
          _numberOfDataPoints = 261;
        }
        break;
    }
  }
}
