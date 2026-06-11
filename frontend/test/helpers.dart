/// Shared mocks and model builders for the unit and widget tests.
///
/// All repositories and services are mocked — tests never touch the
/// network or the Supabase client.
library;

import 'package:belaraby/data/data.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class MockLibraryRepository extends Mock implements LibraryRepository {}

class MockLessonRepository extends Mock implements LessonRepository {}

class MockLessonContentRepository extends Mock
    implements LessonContentRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAppInfoService extends Mock implements AppInfoService {}

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockPurchasesService extends Mock implements PurchasesService {}

class MockCustomerInfo extends Mock implements CustomerInfo {}

class MockEntitlementInfos extends Mock implements EntitlementInfos {}

class MockEntitlementInfo extends Mock implements EntitlementInfo {}

class MockPackage extends Mock implements Package {}

class MockStoreProduct extends Mock implements StoreProduct {}

/// Builds a [Lesson] with sensible defaults for tests.
Lesson buildLesson({
  String id = 'lesson-1',
  bool isPaid = true,
  String body = 'نص القصة',
  String grade = '1',
}) {
  return Lesson(
    id: id,
    isPaid: isPaid,
    title: 'قصة $id',
    body: body,
    level: 'A1',
    grade: grade,
    heroImage: 'https://example.com/$id.png',
  );
}

/// Builds a [CustomerInfo] whose `premium` entitlement is active iff
/// [premium] is true.
CustomerInfo buildCustomerInfo({required bool premium}) {
  final info = MockCustomerInfo();
  final entitlements = MockEntitlementInfos();
  when(() => info.entitlements).thenReturn(entitlements);
  when(() => entitlements.active).thenReturn({
    if (premium) PurchasesService.premiumEntitlementId: MockEntitlementInfo(),
  });
  return info;
}

/// Builds a store [Package] of [type] with the given localized [price].
Package buildPackage({
  PackageType type = PackageType.monthly,
  String price = r'US$4.99',
  String title = 'Premium',
}) {
  final package = MockPackage();
  final product = MockStoreProduct();
  when(() => package.packageType).thenReturn(type);
  when(() => package.storeProduct).thenReturn(product);
  when(() => product.priceString).thenReturn(price);
  when(() => product.title).thenReturn(title);
  return package;
}
