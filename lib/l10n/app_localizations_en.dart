// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'HOME';

  @override
  String get navCatalog => 'CATALOG';

  @override
  String get navCart => 'CART';

  @override
  String get navAccount => 'ACCOUNT';

  @override
  String get navLogin => 'LOGIN';

  @override
  String get navAdmin => 'ADMIN';

  @override
  String get homeHeroLabel => 'New collection';

  @override
  String get homeHeroTitle => 'DISCOVER\nYOUR STYLE';

  @override
  String get homeHeroSubtitle => 'Timeless pieces with quality and elegance';

  @override
  String get homeViewProducts => 'VIEW PRODUCTS';

  @override
  String get homeViewCart => 'VIEW CART';

  @override
  String get homeFeatured => 'Featured';

  @override
  String get homeViewAll => 'View all';

  @override
  String get homeViewCatalog => 'VIEW FULL CATALOG';

  @override
  String get homeNoProducts => 'No products yet';

  @override
  String get homeCategoryLabel => 'CATEGORY';

  @override
  String get homeErrorConnection => 'CONNECTION ERROR';

  @override
  String get homeErrorPermission => 'PERMISSION DENIED';

  @override
  String get homeErrorLoad => 'ERROR LOADING';

  @override
  String get homeDiagnostics => 'DIAGNOSTICS';

  @override
  String get homeTooltipDiagnostics => 'Diagnostics';

  @override
  String get cartTitle => 'CART';

  @override
  String get cartEmptyTitle => 'YOUR CART IS EMPTY';

  @override
  String get cartEmptySubtitle => 'Explore our catalog and add products';

  @override
  String get cartViewCatalog => 'VIEW CATALOG';

  @override
  String get cartTotal => 'TOTAL';

  @override
  String get cartCheckout => 'PLACE ORDER';

  @override
  String get cartSize => 'Size';

  @override
  String get cartErrorNoOrder => 'Error: could not get order ID';

  @override
  String get loginTitle => 'Log in';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginEmailRequired => 'Enter your email';

  @override
  String get loginPasswordRequired => 'Enter your password';

  @override
  String get loginButton => 'Log in';

  @override
  String productStock(int count) {
    return 'Stock: $count';
  }

  @override
  String productStockFrom(int count) {
    return 'Stock from: $count';
  }

  @override
  String get productAvailable => 'Available';

  @override
  String get productSoldOut => 'Sold out';

  @override
  String get productSoldOutUpper => 'SOLD OUT';

  @override
  String get productCategory => 'Category';

  @override
  String get productAddToCart => 'ADD';

  @override
  String get productSelectSize => 'SELECT SIZE';

  @override
  String get productSizeSoldOut => 'SIZE SOLD OUT';

  @override
  String get productMaxInCart =>
      'You already have the maximum available in your cart';

  @override
  String get productViewProduct => 'View product';

  @override
  String get productSize => 'SIZE';

  @override
  String get productStockPerSize => 'STOCK PER SIZE';

  @override
  String productStockTotal(int count) {
    return 'Total stock: $count';
  }

  @override
  String productStockAvailable(int count) {
    return 'Available stock: $count';
  }

  @override
  String get productSearch => 'Search';

  @override
  String get productAll => 'ALL';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get productNoResults => 'No products found';

  @override
  String get checkoutOrderConfirmed => 'ORDER CONFIRMED';

  @override
  String get checkoutVerifying => 'Verifying payment...';

  @override
  String get checkoutConfirmed => 'PAYMENT CONFIRMED';

  @override
  String get checkoutThanks => 'THANK YOU FOR YOUR PURCHASE';

  @override
  String get checkoutVerifyingMsg => 'We are verifying your payment...';

  @override
  String get checkoutConfirmedMsg =>
      'Your order has been processed successfully. You will receive a confirmation email.';

  @override
  String get checkoutPending => 'Pending';

  @override
  String get checkoutPaid => 'Paid';

  @override
  String get checkoutCancelled => 'Cancelled';

  @override
  String get checkoutRefunded => 'Refunded';

  @override
  String get checkoutShipped => 'Shipped';

  @override
  String get checkoutTest => 'Test';

  @override
  String get checkoutViewInvoice => 'VIEW INVOICE';

  @override
  String get checkoutMyOrders => 'MY ORDERS';

  @override
  String get checkoutBackHome => 'BACK TO HOME';

  @override
  String get checkoutRetryVerification => 'RETRY VERIFICATION';

  @override
  String get checkoutContactSupport => 'CONTACT SUPPORT';

  @override
  String get checkoutTimeoutMsg => 'Payment may take a few seconds to confirm.';

  @override
  String get checkoutOrder => 'Order';

  @override
  String get checkoutTotal => 'Total';

  @override
  String get checkoutConfirmedAt => 'Confirmed';

  @override
  String get checkoutCreatedAt => 'Created';

  @override
  String get checkoutArticle => 'ITEM';

  @override
  String get ordersTitle => 'My orders';

  @override
  String get ordersEmpty => 'You have no orders yet';

  @override
  String get ordersViewProducts => 'View products';

  @override
  String get ordersDetail => 'Order detail';

  @override
  String get ordersSubtotal => 'Subtotal';

  @override
  String get ordersDiscount => 'Discount';

  @override
  String get ordersRefunded => 'Refunded';

  @override
  String get ordersItems => 'Items';

  @override
  String get ordersViewInvoice => 'View invoice';

  @override
  String get ordersDownloadInvoice => 'Download invoice (PDF)';

  @override
  String get ordersEmailSent => 'Email sent';

  @override
  String get ordersEmailError => 'Email error';

  @override
  String get ordersDate => 'Date';

  @override
  String get ordersStatus => 'Status';

  @override
  String get ordersPaidAt => 'Paid';

  @override
  String get ordersRetry => 'RETRY';

  @override
  String get ordersNotFound => 'Order not found';

  @override
  String get ordersSize => 'Size';

  @override
  String get ordersPaidLabel => 'paid';

  @override
  String get ordersInvoiceError =>
      'Could not download invoice. Please try again later.';

  @override
  String get ordersInvoiceLoginRequired =>
      'Please sign in to download your invoice.';

  @override
  String get ordersInvoiceSessionExpired =>
      'Your session expired. Please sign in again.';

  @override
  String get ordersInvoiceNotFound => 'Invoice not available yet.';

  @override
  String get ordersLoadItemsError => 'Error loading items';

  @override
  String get ordersCouponDiscount => 'Coupon discount';

  @override
  String get ordersShippingStatus => 'Shipping status';

  @override
  String get ordersCarrier => 'Carrier';

  @override
  String get ordersTracking => 'Tracking';

  @override
  String get ordersShipmentPending => 'Preparing shipment';

  @override
  String get ordersShipmentPreparing => 'In preparation';

  @override
  String get ordersShipmentShipped => 'Shipped';

  @override
  String get ordersShipmentDelivered => 'Delivered';

  @override
  String get ordersShipmentCancelled => 'Cancelled';

  @override
  String get shipmentStatusPending => 'Pending';

  @override
  String get shipmentStatusPreparing => 'Preparing';

  @override
  String get shipmentStatusShipped => 'Shipped';

  @override
  String get shipmentStatusDelivered => 'Delivered';

  @override
  String get shipmentStatusCancelled => 'Cancelled';

  @override
  String get ordersReturnRequest => 'Request return';

  @override
  String get ordersCancelRequest => 'Request cancellation';

  @override
  String get ordersCancelRequestTitle => 'Request order cancellation';

  @override
  String get ordersCancelRequestReason => 'Reason (optional)';

  @override
  String get ordersCancelRequestSend => 'SEND REQUEST';

  @override
  String get ordersCancelRequestSent =>
      'Request sent. We will notify you by email.';

  @override
  String get ordersCancelRequestError =>
      'Could not send request. Please retry.';

  @override
  String get ordersCancelRequestExists =>
      'A cancellation request already exists for this order.';

  @override
  String get ordersCancelNotAllowed =>
      'This order cannot be cancelled in its current status.';

  @override
  String get ordersCancelRequested => 'Cancellation requested';

  @override
  String get ordersStatusPreparing => 'In preparation';

  @override
  String get ordersStatusShipped => 'Shipped';

  @override
  String get ordersStatusDelivered => 'Delivered';

  @override
  String get ordersStatusCancelled => 'Cancelled';

  @override
  String get ordersStatusRefunded => 'Refunded';

  @override
  String get newsletterTitle => 'Newsletter';

  @override
  String get newsletterSubtitle => 'Receive news and exclusive offers';

  @override
  String get newsletterEmail => 'Your email';

  @override
  String get newsletterSubscribe => 'SUBSCRIBE';

  @override
  String get newsletterUnsubscribe => 'UNSUBSCRIBE';

  @override
  String get newsletterSubscribed =>
      'Subscribed — Check your email for your welcome coupon.';

  @override
  String get newsletterAlreadySubscribed =>
      'You are already subscribed to our newsletter.';

  @override
  String get newsletterUnsubscribed => 'You have successfully unsubscribed.';

  @override
  String get newsletterError => 'Error processing request. Please retry.';

  @override
  String get newsletterLoading => 'Processing...';

  @override
  String get couponCode => 'Discount code';

  @override
  String get couponApply => 'APPLY';

  @override
  String couponApplied(int percent) {
    return '$percent% discount applied';
  }

  @override
  String get couponInvalid => 'Invalid or expired code';

  @override
  String get couponRemove => 'REMOVE';

  @override
  String couponDiscount(int percent) {
    return 'Coupon discount ($percent%)';
  }

  @override
  String get accountTitle => 'My account';

  @override
  String get accountTitleUpper => 'MY ACCOUNT';

  @override
  String get accountLogin => 'Log in to view your account';

  @override
  String get accountLoginBtn => 'LOG IN';

  @override
  String get accountRegisterBtn => 'REGISTER';

  @override
  String get accountOrders => 'My orders';

  @override
  String get accountOrdersSubtitle => 'Order history and status';

  @override
  String get accountAddress => 'Shipping address';

  @override
  String get accountAddressPlaceholder => 'Coming soon';

  @override
  String get accountSettings => 'Settings';

  @override
  String get accountSupport => 'Support';

  @override
  String get accountSupportSubtitle => 'Send a query or view your tickets';

  @override
  String get accountLogout => 'LOG OUT';

  @override
  String get accountLanguage => 'Language';

  @override
  String get accountLanguageEs => 'Espanol';

  @override
  String get accountLanguageEn => 'English';

  @override
  String get supportTitle => 'Support';

  @override
  String get supportNewTicket => 'New query';

  @override
  String get supportMyTickets => 'My queries';

  @override
  String get supportNoTickets => 'You have no queries yet';

  @override
  String get supportName => 'Name';

  @override
  String get supportEmail => 'Email';

  @override
  String get supportSubject => 'Subject';

  @override
  String get supportMessage => 'Message';

  @override
  String get supportSend => 'SEND';

  @override
  String get supportSending => 'Sending...';

  @override
  String get supportOpen => 'Open';

  @override
  String get supportAnswered => 'Answered';

  @override
  String get supportClosed => 'Closed';

  @override
  String get supportTicketCreated =>
      'Query sent successfully. You will receive an acknowledgement email.';

  @override
  String get supportTicketDetail => 'Query detail';

  @override
  String get supportReply => 'Reply';

  @override
  String get supportRequiredField => 'Required field';

  @override
  String get supportInvalidEmail => 'Invalid email';

  @override
  String get supportYou => 'You';

  @override
  String get supportAdmin => 'Support';

  @override
  String get supportLoginToSeeTickets => 'Log in to see your previous queries';

  @override
  String get supportErrorSending => 'Error sending query. Please try again.';

  @override
  String get adminTitle => 'ADMIN';

  @override
  String get adminPanelTitle => 'ADMIN PANEL';

  @override
  String get adminMetricOrders => 'ORDERS';

  @override
  String get adminMetricRevenue => 'REVENUE';

  @override
  String get adminMetricReturns => 'RETURNS';

  @override
  String get adminMetricProducts => 'PRODUCTS';

  @override
  String get adminActions => 'ACTIONS';

  @override
  String get adminRecentOrders => 'RECENT ORDERS';

  @override
  String get adminNoOrdersYet => 'No orders yet';

  @override
  String get adminNoOrders => 'No orders';

  @override
  String get adminNavProducts => 'Products';

  @override
  String get adminNavOrders => 'Orders';

  @override
  String get adminNavReturns => 'Returns';

  @override
  String get adminNavFlash => 'Flash Offers';

  @override
  String get adminNavSettings => 'Settings';

  @override
  String get adminOrdersTitle => 'ORDERS';

  @override
  String get adminProductsTitle => 'PRODUCTS';

  @override
  String get adminReturnsTitle => 'RETURNS';

  @override
  String get adminFlashTitle => 'FLASH OFFERS';

  @override
  String get adminSettingsTitle => 'SETTINGS';

  @override
  String get adminSearchProduct => 'Search product...';

  @override
  String get adminNoResults => 'No results';

  @override
  String adminProductStockLabel(int count) {
    return 'Stock: $count';
  }

  @override
  String get adminOrderDetailTitle => 'ORDER DETAIL';

  @override
  String get adminFieldEmail => 'Email';

  @override
  String get adminOrderStatusLabel => 'Status';

  @override
  String get adminOrderPaidLabel => 'Paid';

  @override
  String get adminChangeStatus => 'CHANGE STATUS';

  @override
  String get adminViewInvoice => 'VIEW INVOICE';

  @override
  String get adminOrderItems => 'ITEMS';

  @override
  String get adminNoItemsLoaded => 'No items loaded';

  @override
  String get adminFlashNoOffers => 'No flash offers';

  @override
  String get adminFlashNewOffer => 'New flash offer';

  @override
  String get adminFlashDiscount => 'Discount %';

  @override
  String get adminFlashPopupTitle => 'Popup title (optional)';

  @override
  String get adminFlashPopupText => 'Popup text (optional)';

  @override
  String get adminFlashPopupActive => 'Popup active';

  @override
  String get adminCancel => 'CANCEL';

  @override
  String get adminCreate => 'CREATE';

  @override
  String get adminProductNewTitle => 'NEW PRODUCT';

  @override
  String get adminProductEditTitle => 'EDIT PRODUCT';

  @override
  String get adminProductCreated => 'PRODUCT CREATED';

  @override
  String get adminProductSaved => 'PRODUCT SAVED';

  @override
  String get adminProductCreateBtn => 'CREATE PRODUCT';

  @override
  String get adminProductSaveBtn => 'SAVE';

  @override
  String get adminProductDeleteTitle => 'Delete product';

  @override
  String get adminProductDeleteMsg => 'This action cannot be undone.';

  @override
  String get adminProductDeleteBtn => 'DELETE';

  @override
  String get adminFieldRequired => 'Required';

  @override
  String get adminFieldName => 'Name *';

  @override
  String get adminFieldNameEs => 'Name (ES)';

  @override
  String get adminFieldNameEn => 'Name (EN)';

  @override
  String get adminFieldSlug => 'Slug *';

  @override
  String get adminFieldDesc => 'Description';

  @override
  String get adminFieldDescEs => 'Description (ES)';

  @override
  String get adminFieldDescEn => 'Description (EN)';

  @override
  String get adminFieldPrice => 'Price (cents) *';

  @override
  String get adminFieldStock => 'Stock *';

  @override
  String get adminFieldCategoryId => 'Category ID';

  @override
  String get adminFieldActive => 'Active';

  @override
  String get adminFieldFlash => 'Flash';

  @override
  String get adminFieldImages => 'IMAGES (one URL per line)';

  @override
  String get adminFieldSizes => 'Sizes (comma separated)';

  @override
  String get adminFieldSizeStock => 'Size stock (JSON)';

  @override
  String get adminReturnsEmpty => 'No returns';

  @override
  String get adminReturnOrder => 'Order';

  @override
  String get adminReturnReason => 'Reason';

  @override
  String get adminReturnApprove => 'APPROVE';

  @override
  String get adminReturnReject => 'REJECT';

  @override
  String get adminSettingsGeneral => 'GENERAL';

  @override
  String get adminSettingsInfo => 'INFO';

  @override
  String get adminFlashEnabled => 'Flash Offers enabled';

  @override
  String get adminFlashEnabledSubtitle =>
      'Enable or disable flash offers globally';

  @override
  String get adminRetry => 'RETRY';

  @override
  String get adminNavCoupons => 'Coupons';

  @override
  String get adminNavShipments => 'Shipments';

  @override
  String get adminNavCancellations => 'Cancellations';

  @override
  String get adminNavUsers => 'Users';

  @override
  String get adminCouponsTitle => 'COUPONS';

  @override
  String get adminCouponNew => 'New coupon';

  @override
  String get adminCouponCode => 'Code';

  @override
  String get adminCouponPercent => '% Discount';

  @override
  String get adminCouponActive => 'Active';

  @override
  String get adminCouponMaxRedemptions => 'Max global uses';

  @override
  String get adminCouponMaxPerUser => 'Max per user';

  @override
  String get adminCouponMinOrder => 'Min order (cents)';

  @override
  String get adminCouponNotes => 'Notes';

  @override
  String get adminCouponCreate => 'CREATE COUPON';

  @override
  String get adminCouponCreated => 'Coupon created';

  @override
  String get adminCouponNoData => 'No coupons yet';

  @override
  String get adminCouponRedemptions => 'Uses';

  @override
  String get adminCouponDeactivated => 'Coupon deactivated';

  @override
  String get adminCouponActivated => 'Coupon activated';

  @override
  String get adminCouponDeleteError =>
      'Cannot delete a coupon with existing redemptions. Deactivate instead.';

  @override
  String get adminShipmentsTitle => 'SHIPMENTS';

  @override
  String get adminShipmentNoData => 'No shipments yet';

  @override
  String get adminShipmentOrder => 'Order';

  @override
  String get adminShipmentStatus => 'Status';

  @override
  String get adminShipmentCarrier => 'Carrier';

  @override
  String get adminShipmentTracking => 'Tracking No.';

  @override
  String get adminShipmentNotes => 'Notes';

  @override
  String get adminShipmentSave => 'SAVE SHIPMENT';

  @override
  String get adminShipmentSaved => 'Shipment updated';

  @override
  String get adminShipmentCreate => 'CREATE SHIPMENT';

  @override
  String get adminShipmentCreated => 'Shipment created';

  @override
  String get adminCancellationsTitle => 'CANCELLATIONS';

  @override
  String get adminCancellationNoData => 'No cancellation requests';

  @override
  String get adminCancellationReason => 'Reason';

  @override
  String get adminCancellationRequestedAt => 'Requested';

  @override
  String get adminCancellationStatus => 'Status';

  @override
  String get adminCancellationApprove => 'APPROVE & REFUND';

  @override
  String get adminCancellationReject => 'REJECT';

  @override
  String get adminCancellationApproved =>
      'Cancellation approved and refund processed';

  @override
  String get adminCancellationRejected => 'Request rejected';

  @override
  String get adminCancellationAdminNotes => 'Note for customer (optional)';

  @override
  String get adminCancellationError => 'Error processing cancellation';

  @override
  String get adminUsersTitle => 'USERS';

  @override
  String get adminUserNoData => 'No users';

  @override
  String get adminUserEmail => 'Email';

  @override
  String get adminUserRole => 'Role';

  @override
  String get adminUserActive => 'Active';

  @override
  String get adminUserDisabled => 'Disabled';

  @override
  String get adminUserLastLogin => 'Last login';

  @override
  String get adminUserSaved => 'User updated';

  @override
  String get adminUserMakeAdmin => 'Make admin';

  @override
  String get adminUserMakeUser => 'Remove admin';

  @override
  String get adminUserDisableBtn => 'Disable';

  @override
  String get adminUserEnableBtn => 'Enable';

  @override
  String get adminProductDeleteHasOrders =>
      'This product has orders and cannot be deleted.';

  @override
  String get adminProductDeactivateInstead => 'DEACTIVATE INSTEAD';

  @override
  String get adminProductDeleted => 'Product deleted';

  @override
  String get generalError => 'Error';

  @override
  String get generalLoading => 'Loading...';

  @override
  String get generalRetry => 'RETRY';
}
