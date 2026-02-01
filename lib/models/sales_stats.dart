class SalesStats {
  final double totalSales;
  final int totalTransactions;
  final double averageOrderValue;
  final double todaysSales;
  final int todaysTransactions;
  final DateTime? lastUpdated;
  final Map<String, int> productSales;

  const SalesStats({
    this.totalSales = 0.0,
    this.totalTransactions = 0,
    this.averageOrderValue = 0.0,
    this.todaysSales = 0.0,
    this.todaysTransactions = 0,
    this.lastUpdated,
    this.productSales = const {},
  });

  factory SalesStats.fromJson(Map<String, dynamic> json) {
    return SalesStats(
      totalSales: json['totalSales'] as double? ?? 0.0,
      totalTransactions: json['totalTransactions'] as int? ?? 0,
      averageOrderValue: json['averageOrderValue'] as double? ?? 0.0,
      todaysSales: json['todaysSales'] as double? ?? 0.0,
      todaysTransactions: json['todaysTransactions'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
      productSales: Map<String, int>.from(json['productSales'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSales': totalSales,
      'totalTransactions': totalTransactions,
      'averageOrderValue': averageOrderValue,
      'todaysSales': todaysSales,
      'todaysTransactions': todaysTransactions,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'productSales': productSales,
    };
  }

  SalesStats copyWith({
    double? totalSales,
    int? totalTransactions,
    double? averageOrderValue,
    double? todaysSales,
    int? todaysTransactions,
    DateTime? lastUpdated,
    Map<String, int>? productSales,
  }) {
    return SalesStats(
      totalSales: totalSales ?? this.totalSales,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      todaysSales: todaysSales ?? this.todaysSales,
      todaysTransactions: todaysTransactions ?? this.todaysTransactions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      productSales: productSales ?? this.productSales,
    );
  }
}