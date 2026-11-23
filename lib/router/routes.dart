/// Every route path in one place, so screens never type paths by hand.
///
/// Use `context.go(Routes.home)` to switch tabs and `context.push(...)` for
/// screens that should have a back button.
abstract final class Routes {
  // Auth (Track B) - reachable only when signed out.
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const authRoutes = {login, register, forgotPassword};

  // Bottom-nav tabs.
  static const home = '/home';
  static const history = '/history';
  static const insights = '/insights';
  static const profile = '/profile';

  // Scan flow (Track A).
  static const scan = '/scan';
  static const review = '/scan/review';

  // Split steps (Track C).
  static const categories = '/split/categories';
  static const people = '/split/people';
  static const assign = '/split/assign';
  static const summary = '/split/summary';

  // Saved receipts and profile pages (Track D).
  static const receiptPattern = '/receipt/:id';
  static String receipt(String id) => '/receipt/$id';
  static const myPeople = '/profile/people';
  static const myCategories = '/profile/categories';
}
