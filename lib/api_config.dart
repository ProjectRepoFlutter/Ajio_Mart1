class APIConfig {
  static const String baseUrl =
      "https://ajiomartserver.onrender.com"; // Base URL for all API calls

  // Auth-related APIs
  static const String sendOTP = "$baseUrl/users/sendOtp/";
  static const String verifyOTP = "$baseUrl/users/verify/";
  static const String userLogin = "$baseUrl/users/login/";
  static const String register = "$baseUrl/users/";
  static const String getUserInfo = "$baseUrl/users/"; // add Suffix contactValue


  // Product-related APIs
  static const String getProduct = "$baseUrl/products/"; 
  static const String getAllProductsInCategory = "$baseUrl/products/category/";
  static const String getAllCategories = "$baseUrl/Categories";
  static const String addToCart = "$baseUrl/cart/";
  static const String updateQuantityInCart = "$baseUrl/cart/"; //put
  static const String deleteProductFromCart = "$baseUrl/cart/";
  static const String getAllItemInCart = "$baseUrl/cart/"; // added user in code

  // Add more APIs as needed
  static const String logoUrl = "https://firebasestorage.googleapis.com/v0/b/ajiomart-71d01.appspot.com/o/Logo%2Flogo.png?alt=media&token=63e84872-0e42-433c-8737-c950201db7cb";
}
