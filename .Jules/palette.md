## 2024-05-23 - Login Screen UX Enhancements
**Learning:** Adding `textInputAction` and `onSubmitted` to Flutter forms significantly improves the mobile keyboard experience by allowing users to flow through fields and submit without leaving the keyboard. This is a low-effort, high-impact change.
**Action:** Always check form fields for `textInputAction` and `onSubmitted` handlers during UX review.

## 2024-05-23 - Icon Button Accessibility
**Learning:** Icon-only buttons (like the password visibility toggle) need semantic labels (tooltips or semantic wrappers) for screen readers.
**Action:** Add `tooltip` property to all `IconButton` widgets in future updates.
