/// App configuration constants
class AppConfig {
  // Supabase configuration
  static const String supabaseUrl = 'https://mpbszymyubxavjoxhzfm.supabase.co';
  static const String supabaseAnonKey = 
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1wYnN6eW15dWJ4YXZqb3hoemZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQyOTc5OTQsImV4cCI6MjA2OTg3Mzk5NH0.NnHFwGCkNpTWorV8O6vgn6uuqYPRek1QK4Sk_rcqLOg';
  
  // App constants
  static const String appName = 'Near & Now';
  static const String appVersion = '1.0.0';
  
  // Delivery settings
  static const double deliveryFee = 40.0;
  static const double freeDeliveryThreshold = 500.0;
  
  // Order settings
  static const String orderPrefix = 'NN';
  
  // Pagination
  static const int productsPerPage = 20;
  static const int ordersPerPage = 10;
}

