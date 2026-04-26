// ignore_for_file: file_names

import 'package:in_app_review/in_app_review.dart';

class ReviewServices {
  ReviewServices._();
  static final _instance = ReviewServices._();
  static ReviewServices get instance => _instance;

  Future<void> showReviewPrompt() async {
      final InAppReview inAppReview = InAppReview.instance;

      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      }
  }
}
