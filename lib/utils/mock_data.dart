import 'dart:math';
import '../models/stock.dart';

List<Stock> generateMockStocks([int count = 100, int startIndex = 0]) {
  final random = Random();

  final List<Map<String, String>> stockNames = [
    {'symbol': 'RELIANCE', 'name': 'Reliance Industries'},
    {'symbol': 'TCS', 'name': 'Tata Consultancy Services'},
    {'symbol': 'INFY', 'name': 'Infosys'},
    {'symbol': 'HDFCBANK', 'name': 'HDFC Bank'},
    {'symbol': 'ICICIBANK', 'name': 'ICICI Bank'},
    {'symbol': 'SBIN', 'name': 'State Bank of India'},
    {'symbol': 'BHARTIARTL', 'name': 'Bharti Airtel'},
    {'symbol': 'ITC', 'name': 'ITC Limited'},
    {'symbol': 'WIPRO', 'name': 'Wipro'},
    {'symbol': 'HCLTECH', 'name': 'HCL Technologies'},
    {'symbol': 'AXISBANK', 'name': 'Axis Bank'},
    {'symbol': 'LT', 'name': 'Larsen & Toubro'},
    {'symbol': 'ADANIENT', 'name': 'Adani Enterprises'},
    {'symbol': 'MARUTI', 'name': 'Maruti Suzuki'},
    {'symbol': 'TITAN', 'name': 'Titan Company'},
    {'symbol': 'BAJFINANCE', 'name': 'Bajaj Finance'},
    {'symbol': 'ONGC', 'name': 'Oil & Natural Gas Corp'},
    {'symbol': 'COALINDIA', 'name': 'Coal India'},
    {'symbol': 'HINDUNILVR', 'name': 'Hindustan Unilever'},
    {'symbol': 'ASIANPAINT', 'name': 'Asian Paints'},
    {'symbol': 'DMART', 'name': 'Avenue Supermarts'},
    {'symbol': 'ULTRACEMCO', 'name': 'UltraTech Cement'},
    {'symbol': 'ADANIPORTS', 'name': 'Adani Ports & SEZ'},
    {'symbol': 'POWERGRID', 'name': 'Power Grid Corp'},
    {'symbol': 'NESTLEIND', 'name': 'Nestle India'},
    {'symbol': 'JSWSTEEL', 'name': 'JSW Steel'},
    {'symbol': 'TATAMOTORS', 'name': 'Tata Motors'},
    {'symbol': 'SUNPHARMA', 'name': 'Sun Pharma'},
    {'symbol': 'TECHM', 'name': 'Tech Mahindra'},
    {'symbol': 'DIVISLAB', 'name': 'Divis Laboratories'},
    {'symbol': 'HAVELLS', 'name': 'Havells India'},
    {'symbol': 'CIPLA', 'name': 'Cipla Limited'},
    {'symbol': 'EICHERMOT', 'name': 'Eicher Motors'},
    {'symbol': 'BRITANNIA', 'name': 'Britannia Industries'},
    {'symbol': 'GRASIM', 'name': 'Grasim Industries'},
    {'symbol': 'INDUSINDBK', 'name': 'IndusInd Bank'},
    {'symbol': 'BAJAJFINSV', 'name': 'Bajaj Finserv'},
    {'symbol': 'BPCL', 'name': 'Bharat Petroleum'},
    {'symbol': 'HEROMOTOCO', 'name': 'Hero MotoCorp'},
    {'symbol': 'SBILIFE', 'name': 'SBI Life Insurance'},
    {'symbol': 'TATAPOWER', 'name': 'Tata Power'},
    {'symbol': 'PIDILITIND', 'name': 'Pidilite Industries'},
    {'symbol': 'HDFCLIFE', 'name': 'HDFC Life Insurance'},
    {'symbol': 'ADANIGREEN', 'name': 'Adani Green Energy'},
    {'symbol': 'TATACHEM', 'name': 'Tata Chemicals'},
    {'symbol': 'APOLLOHOSP', 'name': 'Apollo Hospitals'},
    {'symbol': 'SHREECEM', 'name': 'Shree Cement'},
    {'symbol': 'COLPAL', 'name': 'Colgate Palmolive'},
    {'symbol': 'DRREDDY', 'name': 'Dr. Reddy’s Labs'},
    {'symbol': 'ICICIPRULI', 'name': 'ICICI Prudential Life'},
    {'symbol': 'HINDZINC', 'name': 'Hindustan Zinc'},
    {'symbol': 'ADANITRANS', 'name': 'Adani Transmission'},
    {'symbol': 'BERGEPAINT', 'name': 'Berger Paints'},
    {'symbol': 'DLF', 'name': 'DLF Limited'},
    {'symbol': 'GODREJCP', 'name': 'Godrej Consumer Products'},
    {'symbol': 'BANKBARODA', 'name': 'Bank of Baroda'},
    {'symbol': 'YESBANK', 'name': 'Yes Bank'},
    {'symbol': 'IDFCFIRSTB', 'name': 'IDFC First Bank'},
    {'symbol': 'FEDERALBNK', 'name': 'Federal Bank'},
    {'symbol': 'M&M', 'name': 'Mahindra & Mahindra'},
    {'symbol': 'MANAPPURAM', 'name': 'Manappuram Finance'},
    {'symbol': 'NAMINDIA', 'name': 'Nippon India AMC'},
    {'symbol': 'LICHSGFIN', 'name': 'LIC Housing Finance'},
    {'symbol': 'MUTHOOTFIN', 'name': 'Muthoot Finance'},
    {'symbol': 'IRCTC', 'name': 'IRCTC Limited'},
    {'symbol': 'GAIL', 'name': 'GAIL India'},
    {'symbol': 'VOLTAS', 'name': 'Voltas Limited'},
    {'symbol': 'IOC', 'name': 'Indian Oil Corporation'},
    {'symbol': 'TATACOMM', 'name': 'Tata Communications'},
    {'symbol': 'BEL', 'name': 'Bharat Electronics'},
    {'symbol': 'ABB', 'name': 'ABB India'},
    {'symbol': 'CONCOR', 'name': 'Container Corp of India'},
    {'symbol': 'MINDTREE', 'name': 'MindTree Limited'},
    {'symbol': 'PVRINOX', 'name': 'PVR INOX'},
    {'symbol': 'SAIL', 'name': 'Steel Authority of India'},
    {'symbol': 'GUJGASLTD', 'name': 'Gujarat Gas Limited'},
    {'symbol': 'TATAELXSI', 'name': 'Tata Elxsi'},
    {'symbol': 'INDIGO', 'name': 'InterGlobe Aviation'},
    {'symbol': 'HINDPETRO', 'name': 'Hindustan Petroleum'},
    {'symbol': 'BOSCHLTD', 'name': 'Bosch Limited'},
    {'symbol': 'PAGEIND', 'name': 'Page Industries'},
    {'symbol': 'MRF', 'name': 'MRF Tyres'},
    {'symbol': 'CHOLAFIN', 'name': 'Cholamandalam Finance'},
    {'symbol': 'ADANIPOWER', 'name': 'Adani Power'},
    {'symbol': 'TORNTPHARM', 'name': 'Torrent Pharma'},
    {'symbol': 'UBL', 'name': 'United Breweries'},
    {'symbol': 'TATACONSUM', 'name': 'Tata Consumer Products'},
    {'symbol': 'GLAND', 'name': 'Gland Pharma'},
    {'symbol': 'LUPIN', 'name': 'Lupin Limited'},
    {'symbol': 'BIOCON', 'name': 'Biocon Limited'},
    {'symbol': 'TVSMOTOR', 'name': 'TVS Motor Company'},
    {'symbol': 'ZOMATO', 'name': 'Zomato Limited'},
    {'symbol': 'NYKAA', 'name': 'FSN E-Commerce (Nykaa)'},
    {'symbol': 'PAYTM', 'name': 'One 97 Communications (Paytm)'},
    {'symbol': 'POLYCAB', 'name': 'Polycab India'},
    {'symbol': 'ABBOTINDIA', 'name': 'Abbott India'},
    {'symbol': 'BANDHANBNK', 'name': 'Bandhan Bank'},
    {'symbol': 'TRENT', 'name': 'Trent Limited'},
    {'symbol': 'IRFC', 'name': 'Indian Railway Finance Corp'},
    {'symbol': 'JSWINFRA', 'name': 'JSW Infrastructure'},
    {'symbol': 'DELHIVERY', 'name': 'Delhivery Limited'},
    {'symbol': 'AIRTELBL', 'name': 'Airtel Broadband'},
    {'symbol': 'CROMPTON', 'name': 'Crompton Greaves Consumer'},
  ];

  final List<Stock> stocks = [];

  for (int i = startIndex; i < startIndex + count; i++) {
    final data = stockNames[i % stockNames.length];
    final base = 100 + random.nextDouble() * 2500;
    final previous = base - random.nextDouble() * 50;
    final intraday = List<double>.generate(30, (i) {
      final change = (random.nextDouble() - 0.5) * 50;
      return (base + change).clamp(1, double.infinity);
    });

    final high = intraday.reduce(max);
    final low = intraday.reduce(min);
    final volume = 1000 + random.nextInt(900000);
    final marketCap = 50 + random.nextDouble() * 2000;

    stocks.add(
      Stock(
        symbol: "${data['symbol']!}${i + 1}",
        name: data['name']!,
        price: intraday.last,
        previousClose: previous,
        high: high,
        low: low,
        volume: volume,
        marketCap: marketCap,
        intraday: intraday,
      ),
    );
  }

  return stocks;
}

