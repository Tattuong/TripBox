import '../constants/iap_constants.dart';

class CategoryAccess {
  CategoryAccess._();

  static const freeCategoryIds = ['flight', 'hotel', 'itinerary'];

  static bool isUnlocked(String categoryId, {required bool hasPremiumCategories}) {
    if (hasPremiumCategories) return true;
    final index = freeCategoryIds.indexOf(categoryId);
    return index >= 0 && index < IapConstants.freeCategoryLimit;
  }
}
