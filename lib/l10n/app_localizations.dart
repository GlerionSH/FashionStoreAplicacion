import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'INICIO'**
  String get navHome;

  /// No description provided for @navCatalog.
  ///
  /// In es, this message translates to:
  /// **'CATALOGO'**
  String get navCatalog;

  /// No description provided for @navCart.
  ///
  /// In es, this message translates to:
  /// **'CARRITO'**
  String get navCart;

  /// No description provided for @navAccount.
  ///
  /// In es, this message translates to:
  /// **'CUENTA'**
  String get navAccount;

  /// No description provided for @navLogin.
  ///
  /// In es, this message translates to:
  /// **'ENTRAR'**
  String get navLogin;

  /// No description provided for @navAdmin.
  ///
  /// In es, this message translates to:
  /// **'ADMIN'**
  String get navAdmin;

  /// No description provided for @homeHeroLabel.
  ///
  /// In es, this message translates to:
  /// **'Nueva coleccion'**
  String get homeHeroLabel;

  /// No description provided for @homeHeroTitle.
  ///
  /// In es, this message translates to:
  /// **'DESCUBRE\nTU ESTILO'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Piezas atemporales con calidad y elegancia'**
  String get homeHeroSubtitle;

  /// No description provided for @homeViewProducts.
  ///
  /// In es, this message translates to:
  /// **'VER PRODUCTOS'**
  String get homeViewProducts;

  /// No description provided for @homeViewCart.
  ///
  /// In es, this message translates to:
  /// **'VER CARRITO'**
  String get homeViewCart;

  /// No description provided for @homeFeatured.
  ///
  /// In es, this message translates to:
  /// **'Destacados'**
  String get homeFeatured;

  /// No description provided for @homeViewAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todo'**
  String get homeViewAll;

  /// No description provided for @homeViewCatalog.
  ///
  /// In es, this message translates to:
  /// **'VER TODO EL CATALOGO'**
  String get homeViewCatalog;

  /// No description provided for @homeNoProducts.
  ///
  /// In es, this message translates to:
  /// **'No hay productos todavia'**
  String get homeNoProducts;

  /// No description provided for @homeCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'CATEGORIA'**
  String get homeCategoryLabel;

  /// No description provided for @homeErrorConnection.
  ///
  /// In es, this message translates to:
  /// **'ERROR DE CONEXION'**
  String get homeErrorConnection;

  /// No description provided for @homeErrorPermission.
  ///
  /// In es, this message translates to:
  /// **'PERMISO DENEGADO'**
  String get homeErrorPermission;

  /// No description provided for @homeErrorLoad.
  ///
  /// In es, this message translates to:
  /// **'ERROR AL CARGAR'**
  String get homeErrorLoad;

  /// No description provided for @homeDiagnostics.
  ///
  /// In es, this message translates to:
  /// **'DIAGNOSTICOS'**
  String get homeDiagnostics;

  /// No description provided for @homeTooltipDiagnostics.
  ///
  /// In es, this message translates to:
  /// **'Diagnosticos'**
  String get homeTooltipDiagnostics;

  /// No description provided for @cartTitle.
  ///
  /// In es, this message translates to:
  /// **'CARRITO'**
  String get cartTitle;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'TU CARRITO ESTA VACIO'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Explora nuestro catalogo y anade productos'**
  String get cartEmptySubtitle;

  /// No description provided for @cartViewCatalog.
  ///
  /// In es, this message translates to:
  /// **'VER CATALOGO'**
  String get cartViewCatalog;

  /// No description provided for @cartTotal.
  ///
  /// In es, this message translates to:
  /// **'TOTAL'**
  String get cartTotal;

  /// No description provided for @cartCheckout.
  ///
  /// In es, this message translates to:
  /// **'TRAMITAR PEDIDO'**
  String get cartCheckout;

  /// No description provided for @cartSize.
  ///
  /// In es, this message translates to:
  /// **'Talla'**
  String get cartSize;

  /// No description provided for @cartErrorNoOrder.
  ///
  /// In es, this message translates to:
  /// **'Error: no se pudo obtener el ID del pedido'**
  String get cartErrorNoOrder;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesion'**
  String get loginTitle;

  /// No description provided for @loginEmail.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In es, this message translates to:
  /// **'Contrasena'**
  String get loginPassword;

  /// No description provided for @loginEmailRequired.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu email'**
  String get loginEmailRequired;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu contrasena'**
  String get loginPasswordRequired;

  /// No description provided for @loginButton.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get loginButton;

  /// No description provided for @productStock.
  ///
  /// In es, this message translates to:
  /// **'Stock: {count}'**
  String productStock(int count);

  /// No description provided for @productStockFrom.
  ///
  /// In es, this message translates to:
  /// **'Stock desde: {count}'**
  String productStockFrom(int count);

  /// No description provided for @productAvailable.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get productAvailable;

  /// No description provided for @productSoldOut.
  ///
  /// In es, this message translates to:
  /// **'Agotado'**
  String get productSoldOut;

  /// No description provided for @productSoldOutUpper.
  ///
  /// In es, this message translates to:
  /// **'AGOTADO'**
  String get productSoldOutUpper;

  /// No description provided for @productCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoria'**
  String get productCategory;

  /// No description provided for @productAddToCart.
  ///
  /// In es, this message translates to:
  /// **'ANADIR'**
  String get productAddToCart;

  /// No description provided for @productSelectSize.
  ///
  /// In es, this message translates to:
  /// **'SELECCIONA TALLA'**
  String get productSelectSize;

  /// No description provided for @productSizeSoldOut.
  ///
  /// In es, this message translates to:
  /// **'TALLA AGOTADA'**
  String get productSizeSoldOut;

  /// No description provided for @productMaxInCart.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes el maximo disponible en tu carrito'**
  String get productMaxInCart;

  /// No description provided for @productViewProduct.
  ///
  /// In es, this message translates to:
  /// **'Ver producto'**
  String get productViewProduct;

  /// No description provided for @productSize.
  ///
  /// In es, this message translates to:
  /// **'TALLA'**
  String get productSize;

  /// No description provided for @productStockPerSize.
  ///
  /// In es, this message translates to:
  /// **'STOCK POR TALLA'**
  String get productStockPerSize;

  /// No description provided for @productStockTotal.
  ///
  /// In es, this message translates to:
  /// **'Stock total: {count}'**
  String productStockTotal(int count);

  /// No description provided for @productStockAvailable.
  ///
  /// In es, this message translates to:
  /// **'Stock disponible: {count}'**
  String productStockAvailable(int count);

  /// No description provided for @productSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get productSearch;

  /// No description provided for @productAll.
  ///
  /// In es, this message translates to:
  /// **'TODOS'**
  String get productAll;

  /// No description provided for @productNotFound.
  ///
  /// In es, this message translates to:
  /// **'Producto no encontrado'**
  String get productNotFound;

  /// No description provided for @productNoResults.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron productos'**
  String get productNoResults;

  /// No description provided for @checkoutOrderConfirmed.
  ///
  /// In es, this message translates to:
  /// **'PEDIDO CONFIRMADO'**
  String get checkoutOrderConfirmed;

  /// No description provided for @checkoutVerifying.
  ///
  /// In es, this message translates to:
  /// **'Verificando pago...'**
  String get checkoutVerifying;

  /// No description provided for @checkoutConfirmed.
  ///
  /// In es, this message translates to:
  /// **'PAGO CONFIRMADO'**
  String get checkoutConfirmed;

  /// No description provided for @checkoutThanks.
  ///
  /// In es, this message translates to:
  /// **'GRACIAS POR TU COMPRA'**
  String get checkoutThanks;

  /// No description provided for @checkoutVerifyingMsg.
  ///
  /// In es, this message translates to:
  /// **'Estamos verificando tu pago...'**
  String get checkoutVerifyingMsg;

  /// No description provided for @checkoutConfirmedMsg.
  ///
  /// In es, this message translates to:
  /// **'Tu pedido ha sido procesado correctamente. Recibiras un email de confirmacion.'**
  String get checkoutConfirmedMsg;

  /// No description provided for @checkoutPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get checkoutPending;

  /// No description provided for @checkoutPaid.
  ///
  /// In es, this message translates to:
  /// **'Pagado'**
  String get checkoutPaid;

  /// No description provided for @checkoutCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get checkoutCancelled;

  /// No description provided for @checkoutRefunded.
  ///
  /// In es, this message translates to:
  /// **'Reembolsado'**
  String get checkoutRefunded;

  /// No description provided for @checkoutShipped.
  ///
  /// In es, this message translates to:
  /// **'Enviado'**
  String get checkoutShipped;

  /// No description provided for @checkoutTest.
  ///
  /// In es, this message translates to:
  /// **'Test'**
  String get checkoutTest;

  /// No description provided for @checkoutViewInvoice.
  ///
  /// In es, this message translates to:
  /// **'VER FACTURA'**
  String get checkoutViewInvoice;

  /// No description provided for @checkoutMyOrders.
  ///
  /// In es, this message translates to:
  /// **'MIS PEDIDOS'**
  String get checkoutMyOrders;

  /// No description provided for @checkoutBackHome.
  ///
  /// In es, this message translates to:
  /// **'VOLVER AL INICIO'**
  String get checkoutBackHome;

  /// No description provided for @checkoutRetryVerification.
  ///
  /// In es, this message translates to:
  /// **'REINTENTAR VERIFICACION'**
  String get checkoutRetryVerification;

  /// No description provided for @checkoutContactSupport.
  ///
  /// In es, this message translates to:
  /// **'CONTACTAR SOPORTE'**
  String get checkoutContactSupport;

  /// No description provided for @checkoutTimeoutMsg.
  ///
  /// In es, this message translates to:
  /// **'El pago puede tardar unos segundos en confirmarse.'**
  String get checkoutTimeoutMsg;

  /// No description provided for @checkoutOrder.
  ///
  /// In es, this message translates to:
  /// **'Pedido'**
  String get checkoutOrder;

  /// No description provided for @checkoutTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get checkoutTotal;

  /// No description provided for @checkoutConfirmedAt.
  ///
  /// In es, this message translates to:
  /// **'Confirmado'**
  String get checkoutConfirmedAt;

  /// No description provided for @checkoutCreatedAt.
  ///
  /// In es, this message translates to:
  /// **'Creado'**
  String get checkoutCreatedAt;

  /// No description provided for @checkoutArticle.
  ///
  /// In es, this message translates to:
  /// **'ARTICULO'**
  String get checkoutArticle;

  /// No description provided for @ordersTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis pedidos'**
  String get ordersTitle;

  /// No description provided for @ordersEmpty.
  ///
  /// In es, this message translates to:
  /// **'No tienes pedidos todavia'**
  String get ordersEmpty;

  /// No description provided for @ordersViewProducts.
  ///
  /// In es, this message translates to:
  /// **'Ver productos'**
  String get ordersViewProducts;

  /// No description provided for @ordersDetail.
  ///
  /// In es, this message translates to:
  /// **'Detalle del pedido'**
  String get ordersDetail;

  /// No description provided for @ordersSubtotal.
  ///
  /// In es, this message translates to:
  /// **'Subtotal'**
  String get ordersSubtotal;

  /// No description provided for @ordersDiscount.
  ///
  /// In es, this message translates to:
  /// **'Descuento'**
  String get ordersDiscount;

  /// No description provided for @ordersRefunded.
  ///
  /// In es, this message translates to:
  /// **'Reembolsado'**
  String get ordersRefunded;

  /// No description provided for @ordersItems.
  ///
  /// In es, this message translates to:
  /// **'Articulos'**
  String get ordersItems;

  /// No description provided for @ordersViewInvoice.
  ///
  /// In es, this message translates to:
  /// **'Ver factura'**
  String get ordersViewInvoice;

  /// No description provided for @ordersDownloadInvoice.
  ///
  /// In es, this message translates to:
  /// **'Descargar factura (PDF)'**
  String get ordersDownloadInvoice;

  /// No description provided for @ordersEmailSent.
  ///
  /// In es, this message translates to:
  /// **'Email enviado'**
  String get ordersEmailSent;

  /// No description provided for @ordersEmailError.
  ///
  /// In es, this message translates to:
  /// **'Error email'**
  String get ordersEmailError;

  /// No description provided for @ordersDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get ordersDate;

  /// No description provided for @ordersStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get ordersStatus;

  /// No description provided for @ordersPaidAt.
  ///
  /// In es, this message translates to:
  /// **'Pagado'**
  String get ordersPaidAt;

  /// No description provided for @ordersRetry.
  ///
  /// In es, this message translates to:
  /// **'REINTENTAR'**
  String get ordersRetry;

  /// No description provided for @ordersNotFound.
  ///
  /// In es, this message translates to:
  /// **'Pedido no encontrado'**
  String get ordersNotFound;

  /// No description provided for @ordersSize.
  ///
  /// In es, this message translates to:
  /// **'Talla'**
  String get ordersSize;

  /// No description provided for @ordersPaidLabel.
  ///
  /// In es, this message translates to:
  /// **'pagado'**
  String get ordersPaidLabel;

  /// No description provided for @ordersInvoiceError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo descargar la factura. Reintenta mas tarde.'**
  String get ordersInvoiceError;

  /// No description provided for @ordersInvoiceLoginRequired.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesion para descargar tu factura.'**
  String get ordersInvoiceLoginRequired;

  /// No description provided for @ordersInvoiceSessionExpired.
  ///
  /// In es, this message translates to:
  /// **'Tu sesion caduco. Vuelve a iniciar sesion.'**
  String get ordersInvoiceSessionExpired;

  /// No description provided for @ordersInvoiceNotFound.
  ///
  /// In es, this message translates to:
  /// **'Factura no disponible todavia.'**
  String get ordersInvoiceNotFound;

  /// No description provided for @ordersLoadItemsError.
  ///
  /// In es, this message translates to:
  /// **'Error cargando articulos'**
  String get ordersLoadItemsError;

  /// No description provided for @ordersCouponDiscount.
  ///
  /// In es, this message translates to:
  /// **'Descuento cupón'**
  String get ordersCouponDiscount;

  /// No description provided for @ordersShippingStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado del envío'**
  String get ordersShippingStatus;

  /// No description provided for @ordersCarrier.
  ///
  /// In es, this message translates to:
  /// **'Transportista'**
  String get ordersCarrier;

  /// No description provided for @ordersTracking.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento'**
  String get ordersTracking;

  /// No description provided for @ordersShipmentPending.
  ///
  /// In es, this message translates to:
  /// **'Preparando envío'**
  String get ordersShipmentPending;

  /// No description provided for @ordersShipmentPreparing.
  ///
  /// In es, this message translates to:
  /// **'En preparación'**
  String get ordersShipmentPreparing;

  /// No description provided for @ordersShipmentShipped.
  ///
  /// In es, this message translates to:
  /// **'Enviado'**
  String get ordersShipmentShipped;

  /// No description provided for @ordersShipmentDelivered.
  ///
  /// In es, this message translates to:
  /// **'Entregado'**
  String get ordersShipmentDelivered;

  /// No description provided for @ordersShipmentCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get ordersShipmentCancelled;

  /// No description provided for @ordersCancelRequest.
  ///
  /// In es, this message translates to:
  /// **'Solicitar cancelación'**
  String get ordersCancelRequest;

  /// No description provided for @ordersCancelRequestTitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitar cancelación del pedido'**
  String get ordersCancelRequestTitle;

  /// No description provided for @ordersCancelRequestReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo (opcional)'**
  String get ordersCancelRequestReason;

  /// No description provided for @ordersCancelRequestSend.
  ///
  /// In es, this message translates to:
  /// **'ENVIAR SOLICITUD'**
  String get ordersCancelRequestSend;

  /// No description provided for @ordersCancelRequestSent.
  ///
  /// In es, this message translates to:
  /// **'Solicitud enviada. Te notificaremos por email.'**
  String get ordersCancelRequestSent;

  /// No description provided for @ordersCancelRequestError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar la solicitud. Reintenta.'**
  String get ordersCancelRequestError;

  /// No description provided for @ordersCancelRequestExists.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una solicitud de cancelación para este pedido.'**
  String get ordersCancelRequestExists;

  /// No description provided for @ordersCancelNotAllowed.
  ///
  /// In es, this message translates to:
  /// **'No se puede cancelar un pedido en este estado.'**
  String get ordersCancelNotAllowed;

  /// No description provided for @ordersCancelRequested.
  ///
  /// In es, this message translates to:
  /// **'Cancelación solicitada'**
  String get ordersCancelRequested;

  /// No description provided for @ordersStatusPreparing.
  ///
  /// In es, this message translates to:
  /// **'En preparación'**
  String get ordersStatusPreparing;

  /// No description provided for @ordersStatusShipped.
  ///
  /// In es, this message translates to:
  /// **'Enviado'**
  String get ordersStatusShipped;

  /// No description provided for @ordersStatusDelivered.
  ///
  /// In es, this message translates to:
  /// **'Entregado'**
  String get ordersStatusDelivered;

  /// No description provided for @ordersStatusCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get ordersStatusCancelled;

  /// No description provided for @ordersStatusRefunded.
  ///
  /// In es, this message translates to:
  /// **'Reembolsado'**
  String get ordersStatusRefunded;

  /// No description provided for @newsletterTitle.
  ///
  /// In es, this message translates to:
  /// **'Newsletter'**
  String get newsletterTitle;

  /// No description provided for @newsletterSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Recibe novedades y ofertas exclusivas'**
  String get newsletterSubtitle;

  /// No description provided for @newsletterEmail.
  ///
  /// In es, this message translates to:
  /// **'Tu email'**
  String get newsletterEmail;

  /// No description provided for @newsletterSubscribe.
  ///
  /// In es, this message translates to:
  /// **'SUSCRIBIRME'**
  String get newsletterSubscribe;

  /// No description provided for @newsletterUnsubscribe.
  ///
  /// In es, this message translates to:
  /// **'CANCELAR SUSCRIPCIÓN'**
  String get newsletterUnsubscribe;

  /// No description provided for @newsletterSubscribed.
  ///
  /// In es, this message translates to:
  /// **'Suscrito — Revisa tu email para ver tu cupón de bienvenida.'**
  String get newsletterSubscribed;

  /// No description provided for @newsletterAlreadySubscribed.
  ///
  /// In es, this message translates to:
  /// **'Ya estás suscrito al newsletter.'**
  String get newsletterAlreadySubscribed;

  /// No description provided for @newsletterUnsubscribed.
  ///
  /// In es, this message translates to:
  /// **'Te has dado de baja correctamente.'**
  String get newsletterUnsubscribed;

  /// No description provided for @newsletterError.
  ///
  /// In es, this message translates to:
  /// **'Error al procesar la solicitud. Reintenta.'**
  String get newsletterError;

  /// No description provided for @newsletterLoading.
  ///
  /// In es, this message translates to:
  /// **'Procesando...'**
  String get newsletterLoading;

  /// No description provided for @couponCode.
  ///
  /// In es, this message translates to:
  /// **'Código de descuento'**
  String get couponCode;

  /// No description provided for @couponApply.
  ///
  /// In es, this message translates to:
  /// **'APLICAR'**
  String get couponApply;

  /// No description provided for @couponApplied.
  ///
  /// In es, this message translates to:
  /// **'{percent}% de descuento aplicado'**
  String couponApplied(int percent);

  /// No description provided for @couponInvalid.
  ///
  /// In es, this message translates to:
  /// **'Código no válido o caducado'**
  String get couponInvalid;

  /// No description provided for @couponRemove.
  ///
  /// In es, this message translates to:
  /// **'QUITAR'**
  String get couponRemove;

  /// No description provided for @couponDiscount.
  ///
  /// In es, this message translates to:
  /// **'Descuento cupón ({percent}%)'**
  String couponDiscount(int percent);

  /// No description provided for @accountTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi cuenta'**
  String get accountTitle;

  /// No description provided for @accountTitleUpper.
  ///
  /// In es, this message translates to:
  /// **'MI CUENTA'**
  String get accountTitleUpper;

  /// No description provided for @accountLogin.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesion para ver tu cuenta'**
  String get accountLogin;

  /// No description provided for @accountLoginBtn.
  ///
  /// In es, this message translates to:
  /// **'INICIAR SESION'**
  String get accountLoginBtn;

  /// No description provided for @accountOrders.
  ///
  /// In es, this message translates to:
  /// **'Mis pedidos'**
  String get accountOrders;

  /// No description provided for @accountOrdersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Historial y estado de tus compras'**
  String get accountOrdersSubtitle;

  /// No description provided for @accountAddress.
  ///
  /// In es, this message translates to:
  /// **'Direccion de envio'**
  String get accountAddress;

  /// No description provided for @accountAddressPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Proximamente'**
  String get accountAddressPlaceholder;

  /// No description provided for @accountSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get accountSettings;

  /// No description provided for @accountSupport.
  ///
  /// In es, this message translates to:
  /// **'Soporte'**
  String get accountSupport;

  /// No description provided for @accountSupportSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Enviar consulta o ver tus tickets'**
  String get accountSupportSubtitle;

  /// No description provided for @accountLogout.
  ///
  /// In es, this message translates to:
  /// **'CERRAR SESION'**
  String get accountLogout;

  /// No description provided for @accountLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get accountLanguage;

  /// No description provided for @accountLanguageEs.
  ///
  /// In es, this message translates to:
  /// **'Espanol'**
  String get accountLanguageEs;

  /// No description provided for @accountLanguageEn.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get accountLanguageEn;

  /// No description provided for @supportTitle.
  ///
  /// In es, this message translates to:
  /// **'Soporte'**
  String get supportTitle;

  /// No description provided for @supportNewTicket.
  ///
  /// In es, this message translates to:
  /// **'Nueva consulta'**
  String get supportNewTicket;

  /// No description provided for @supportMyTickets.
  ///
  /// In es, this message translates to:
  /// **'Mis consultas'**
  String get supportMyTickets;

  /// No description provided for @supportNoTickets.
  ///
  /// In es, this message translates to:
  /// **'No tienes consultas todavia'**
  String get supportNoTickets;

  /// No description provided for @supportName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get supportName;

  /// No description provided for @supportEmail.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get supportEmail;

  /// No description provided for @supportSubject.
  ///
  /// In es, this message translates to:
  /// **'Asunto'**
  String get supportSubject;

  /// No description provided for @supportMessage.
  ///
  /// In es, this message translates to:
  /// **'Mensaje'**
  String get supportMessage;

  /// No description provided for @supportSend.
  ///
  /// In es, this message translates to:
  /// **'ENVIAR'**
  String get supportSend;

  /// No description provided for @supportSending.
  ///
  /// In es, this message translates to:
  /// **'Enviando...'**
  String get supportSending;

  /// No description provided for @supportOpen.
  ///
  /// In es, this message translates to:
  /// **'Abierto'**
  String get supportOpen;

  /// No description provided for @supportAnswered.
  ///
  /// In es, this message translates to:
  /// **'Respondido'**
  String get supportAnswered;

  /// No description provided for @supportClosed.
  ///
  /// In es, this message translates to:
  /// **'Cerrado'**
  String get supportClosed;

  /// No description provided for @supportTicketCreated.
  ///
  /// In es, this message translates to:
  /// **'Consulta enviada correctamente. Recibiras un email de acuse.'**
  String get supportTicketCreated;

  /// No description provided for @supportTicketDetail.
  ///
  /// In es, this message translates to:
  /// **'Detalle de consulta'**
  String get supportTicketDetail;

  /// No description provided for @supportReply.
  ///
  /// In es, this message translates to:
  /// **'Respuesta'**
  String get supportReply;

  /// No description provided for @supportRequiredField.
  ///
  /// In es, this message translates to:
  /// **'Campo obligatorio'**
  String get supportRequiredField;

  /// No description provided for @supportInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Email no valido'**
  String get supportInvalidEmail;

  /// No description provided for @supportYou.
  ///
  /// In es, this message translates to:
  /// **'Tu'**
  String get supportYou;

  /// No description provided for @supportAdmin.
  ///
  /// In es, this message translates to:
  /// **'Soporte'**
  String get supportAdmin;

  /// No description provided for @supportLoginToSeeTickets.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesion para ver tus consultas anteriores'**
  String get supportLoginToSeeTickets;

  /// No description provided for @supportErrorSending.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar la consulta. Reintenta.'**
  String get supportErrorSending;

  /// No description provided for @adminTitle.
  ///
  /// In es, this message translates to:
  /// **'ADMIN'**
  String get adminTitle;

  /// No description provided for @adminPanelTitle.
  ///
  /// In es, this message translates to:
  /// **'PANEL ADMIN'**
  String get adminPanelTitle;

  /// No description provided for @adminMetricOrders.
  ///
  /// In es, this message translates to:
  /// **'PEDIDOS'**
  String get adminMetricOrders;

  /// No description provided for @adminMetricRevenue.
  ///
  /// In es, this message translates to:
  /// **'INGRESOS'**
  String get adminMetricRevenue;

  /// No description provided for @adminMetricReturns.
  ///
  /// In es, this message translates to:
  /// **'DEVOLUCIONES'**
  String get adminMetricReturns;

  /// No description provided for @adminMetricProducts.
  ///
  /// In es, this message translates to:
  /// **'PRODUCTOS'**
  String get adminMetricProducts;

  /// No description provided for @adminActions.
  ///
  /// In es, this message translates to:
  /// **'ACCIONES'**
  String get adminActions;

  /// No description provided for @adminRecentOrders.
  ///
  /// In es, this message translates to:
  /// **'PEDIDOS RECIENTES'**
  String get adminRecentOrders;

  /// No description provided for @adminNoOrdersYet.
  ///
  /// In es, this message translates to:
  /// **'Sin pedidos todavia'**
  String get adminNoOrdersYet;

  /// No description provided for @adminNoOrders.
  ///
  /// In es, this message translates to:
  /// **'Sin pedidos'**
  String get adminNoOrders;

  /// No description provided for @adminNavProducts.
  ///
  /// In es, this message translates to:
  /// **'Productos'**
  String get adminNavProducts;

  /// No description provided for @adminNavOrders.
  ///
  /// In es, this message translates to:
  /// **'Pedidos'**
  String get adminNavOrders;

  /// No description provided for @adminNavReturns.
  ///
  /// In es, this message translates to:
  /// **'Devoluciones'**
  String get adminNavReturns;

  /// No description provided for @adminNavFlash.
  ///
  /// In es, this message translates to:
  /// **'Flash Offers'**
  String get adminNavFlash;

  /// No description provided for @adminNavSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get adminNavSettings;

  /// No description provided for @adminOrdersTitle.
  ///
  /// In es, this message translates to:
  /// **'PEDIDOS'**
  String get adminOrdersTitle;

  /// No description provided for @adminProductsTitle.
  ///
  /// In es, this message translates to:
  /// **'PRODUCTOS'**
  String get adminProductsTitle;

  /// No description provided for @adminReturnsTitle.
  ///
  /// In es, this message translates to:
  /// **'DEVOLUCIONES'**
  String get adminReturnsTitle;

  /// No description provided for @adminFlashTitle.
  ///
  /// In es, this message translates to:
  /// **'FLASH OFFERS'**
  String get adminFlashTitle;

  /// No description provided for @adminSettingsTitle.
  ///
  /// In es, this message translates to:
  /// **'AJUSTES'**
  String get adminSettingsTitle;

  /// No description provided for @adminSearchProduct.
  ///
  /// In es, this message translates to:
  /// **'Buscar producto...'**
  String get adminSearchProduct;

  /// No description provided for @adminNoResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get adminNoResults;

  /// No description provided for @adminProductStockLabel.
  ///
  /// In es, this message translates to:
  /// **'Stock: {count}'**
  String adminProductStockLabel(int count);

  /// No description provided for @adminOrderDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'DETALLE PEDIDO'**
  String get adminOrderDetailTitle;

  /// No description provided for @adminFieldEmail.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get adminFieldEmail;

  /// No description provided for @adminOrderStatusLabel.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get adminOrderStatusLabel;

  /// No description provided for @adminOrderPaidLabel.
  ///
  /// In es, this message translates to:
  /// **'Pagado'**
  String get adminOrderPaidLabel;

  /// No description provided for @adminChangeStatus.
  ///
  /// In es, this message translates to:
  /// **'CAMBIAR ESTADO'**
  String get adminChangeStatus;

  /// No description provided for @adminViewInvoice.
  ///
  /// In es, this message translates to:
  /// **'VER FACTURA'**
  String get adminViewInvoice;

  /// No description provided for @adminOrderItems.
  ///
  /// In es, this message translates to:
  /// **'ARTICULOS'**
  String get adminOrderItems;

  /// No description provided for @adminNoItemsLoaded.
  ///
  /// In es, this message translates to:
  /// **'Sin articulos cargados'**
  String get adminNoItemsLoaded;

  /// No description provided for @adminFlashNoOffers.
  ///
  /// In es, this message translates to:
  /// **'Sin ofertas flash'**
  String get adminFlashNoOffers;

  /// No description provided for @adminFlashNewOffer.
  ///
  /// In es, this message translates to:
  /// **'Nueva oferta flash'**
  String get adminFlashNewOffer;

  /// No description provided for @adminFlashDiscount.
  ///
  /// In es, this message translates to:
  /// **'Descuento %'**
  String get adminFlashDiscount;

  /// No description provided for @adminFlashPopupTitle.
  ///
  /// In es, this message translates to:
  /// **'Popup titulo (opcional)'**
  String get adminFlashPopupTitle;

  /// No description provided for @adminFlashPopupText.
  ///
  /// In es, this message translates to:
  /// **'Popup texto (opcional)'**
  String get adminFlashPopupText;

  /// No description provided for @adminFlashPopupActive.
  ///
  /// In es, this message translates to:
  /// **'Popup activo'**
  String get adminFlashPopupActive;

  /// No description provided for @adminCancel.
  ///
  /// In es, this message translates to:
  /// **'CANCELAR'**
  String get adminCancel;

  /// No description provided for @adminCreate.
  ///
  /// In es, this message translates to:
  /// **'CREAR'**
  String get adminCreate;

  /// No description provided for @adminProductNewTitle.
  ///
  /// In es, this message translates to:
  /// **'NUEVO PRODUCTO'**
  String get adminProductNewTitle;

  /// No description provided for @adminProductEditTitle.
  ///
  /// In es, this message translates to:
  /// **'EDITAR PRODUCTO'**
  String get adminProductEditTitle;

  /// No description provided for @adminProductCreated.
  ///
  /// In es, this message translates to:
  /// **'PRODUCTO CREADO'**
  String get adminProductCreated;

  /// No description provided for @adminProductSaved.
  ///
  /// In es, this message translates to:
  /// **'PRODUCTO GUARDADO'**
  String get adminProductSaved;

  /// No description provided for @adminProductCreateBtn.
  ///
  /// In es, this message translates to:
  /// **'CREAR PRODUCTO'**
  String get adminProductCreateBtn;

  /// No description provided for @adminProductSaveBtn.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR'**
  String get adminProductSaveBtn;

  /// No description provided for @adminProductDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar producto'**
  String get adminProductDeleteTitle;

  /// No description provided for @adminProductDeleteMsg.
  ///
  /// In es, this message translates to:
  /// **'Esta accion no se puede deshacer.'**
  String get adminProductDeleteMsg;

  /// No description provided for @adminProductDeleteBtn.
  ///
  /// In es, this message translates to:
  /// **'ELIMINAR'**
  String get adminProductDeleteBtn;

  /// No description provided for @adminFieldRequired.
  ///
  /// In es, this message translates to:
  /// **'Obligatorio'**
  String get adminFieldRequired;

  /// No description provided for @adminFieldName.
  ///
  /// In es, this message translates to:
  /// **'Nombre *'**
  String get adminFieldName;

  /// No description provided for @adminFieldNameEs.
  ///
  /// In es, this message translates to:
  /// **'Nombre (ES)'**
  String get adminFieldNameEs;

  /// No description provided for @adminFieldNameEn.
  ///
  /// In es, this message translates to:
  /// **'Nombre (EN)'**
  String get adminFieldNameEn;

  /// No description provided for @adminFieldSlug.
  ///
  /// In es, this message translates to:
  /// **'Slug *'**
  String get adminFieldSlug;

  /// No description provided for @adminFieldDesc.
  ///
  /// In es, this message translates to:
  /// **'Descripcion'**
  String get adminFieldDesc;

  /// No description provided for @adminFieldDescEs.
  ///
  /// In es, this message translates to:
  /// **'Descripcion (ES)'**
  String get adminFieldDescEs;

  /// No description provided for @adminFieldDescEn.
  ///
  /// In es, this message translates to:
  /// **'Descripcion (EN)'**
  String get adminFieldDescEn;

  /// No description provided for @adminFieldPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio (cents) *'**
  String get adminFieldPrice;

  /// No description provided for @adminFieldStock.
  ///
  /// In es, this message translates to:
  /// **'Stock *'**
  String get adminFieldStock;

  /// No description provided for @adminFieldCategoryId.
  ///
  /// In es, this message translates to:
  /// **'Category ID'**
  String get adminFieldCategoryId;

  /// No description provided for @adminFieldActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get adminFieldActive;

  /// No description provided for @adminFieldFlash.
  ///
  /// In es, this message translates to:
  /// **'Flash'**
  String get adminFieldFlash;

  /// No description provided for @adminFieldImages.
  ///
  /// In es, this message translates to:
  /// **'IMAGENES (una URL por linea)'**
  String get adminFieldImages;

  /// No description provided for @adminFieldSizes.
  ///
  /// In es, this message translates to:
  /// **'Tallas (separadas por coma)'**
  String get adminFieldSizes;

  /// No description provided for @adminFieldSizeStock.
  ///
  /// In es, this message translates to:
  /// **'Size stock (JSON)'**
  String get adminFieldSizeStock;

  /// No description provided for @adminReturnsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin devoluciones'**
  String get adminReturnsEmpty;

  /// No description provided for @adminReturnOrder.
  ///
  /// In es, this message translates to:
  /// **'Pedido'**
  String get adminReturnOrder;

  /// No description provided for @adminReturnReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo'**
  String get adminReturnReason;

  /// No description provided for @adminReturnApprove.
  ///
  /// In es, this message translates to:
  /// **'APROBAR'**
  String get adminReturnApprove;

  /// No description provided for @adminReturnReject.
  ///
  /// In es, this message translates to:
  /// **'RECHAZAR'**
  String get adminReturnReject;

  /// No description provided for @adminSettingsGeneral.
  ///
  /// In es, this message translates to:
  /// **'GENERAL'**
  String get adminSettingsGeneral;

  /// No description provided for @adminSettingsInfo.
  ///
  /// In es, this message translates to:
  /// **'INFO'**
  String get adminSettingsInfo;

  /// No description provided for @adminFlashEnabled.
  ///
  /// In es, this message translates to:
  /// **'Flash Offers habilitadas'**
  String get adminFlashEnabled;

  /// No description provided for @adminFlashEnabledSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Activa o desactiva las ofertas flash globalmente'**
  String get adminFlashEnabledSubtitle;

  /// No description provided for @adminRetry.
  ///
  /// In es, this message translates to:
  /// **'REINTENTAR'**
  String get adminRetry;

  /// No description provided for @adminNavCoupons.
  ///
  /// In es, this message translates to:
  /// **'Cupones'**
  String get adminNavCoupons;

  /// No description provided for @adminNavShipments.
  ///
  /// In es, this message translates to:
  /// **'Envíos'**
  String get adminNavShipments;

  /// No description provided for @adminNavCancellations.
  ///
  /// In es, this message translates to:
  /// **'Cancelaciones'**
  String get adminNavCancellations;

  /// No description provided for @adminNavUsers.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get adminNavUsers;

  /// No description provided for @adminCouponsTitle.
  ///
  /// In es, this message translates to:
  /// **'CUPONES'**
  String get adminCouponsTitle;

  /// No description provided for @adminCouponNew.
  ///
  /// In es, this message translates to:
  /// **'Nuevo cupón'**
  String get adminCouponNew;

  /// No description provided for @adminCouponCode.
  ///
  /// In es, this message translates to:
  /// **'Código'**
  String get adminCouponCode;

  /// No description provided for @adminCouponPercent.
  ///
  /// In es, this message translates to:
  /// **'% Descuento'**
  String get adminCouponPercent;

  /// No description provided for @adminCouponActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get adminCouponActive;

  /// No description provided for @adminCouponMaxRedemptions.
  ///
  /// In es, this message translates to:
  /// **'Máx. usos globales'**
  String get adminCouponMaxRedemptions;

  /// No description provided for @adminCouponMaxPerUser.
  ///
  /// In es, this message translates to:
  /// **'Máx. por usuario'**
  String get adminCouponMaxPerUser;

  /// No description provided for @adminCouponMinOrder.
  ///
  /// In es, this message translates to:
  /// **'Pedido mínimo (cents)'**
  String get adminCouponMinOrder;

  /// No description provided for @adminCouponNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get adminCouponNotes;

  /// No description provided for @adminCouponCreate.
  ///
  /// In es, this message translates to:
  /// **'CREAR CUPÓN'**
  String get adminCouponCreate;

  /// No description provided for @adminCouponCreated.
  ///
  /// In es, this message translates to:
  /// **'Cupón creado'**
  String get adminCouponCreated;

  /// No description provided for @adminCouponNoData.
  ///
  /// In es, this message translates to:
  /// **'Sin cupones todavía'**
  String get adminCouponNoData;

  /// No description provided for @adminCouponRedemptions.
  ///
  /// In es, this message translates to:
  /// **'Usos'**
  String get adminCouponRedemptions;

  /// No description provided for @adminCouponDeactivated.
  ///
  /// In es, this message translates to:
  /// **'Cupón desactivado'**
  String get adminCouponDeactivated;

  /// No description provided for @adminCouponActivated.
  ///
  /// In es, this message translates to:
  /// **'Cupón activado'**
  String get adminCouponActivated;

  /// No description provided for @adminCouponDeleteError.
  ///
  /// In es, this message translates to:
  /// **'No se puede eliminar un cupón con usos. Desuáctivalo.'**
  String get adminCouponDeleteError;

  /// No description provided for @adminShipmentsTitle.
  ///
  /// In es, this message translates to:
  /// **'ENVÍOS'**
  String get adminShipmentsTitle;

  /// No description provided for @adminShipmentNoData.
  ///
  /// In es, this message translates to:
  /// **'Sin envíos todavía'**
  String get adminShipmentNoData;

  /// No description provided for @adminShipmentOrder.
  ///
  /// In es, this message translates to:
  /// **'Pedido'**
  String get adminShipmentOrder;

  /// No description provided for @adminShipmentStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get adminShipmentStatus;

  /// No description provided for @adminShipmentCarrier.
  ///
  /// In es, this message translates to:
  /// **'Transportista'**
  String get adminShipmentCarrier;

  /// No description provided for @adminShipmentTracking.
  ///
  /// In es, this message translates to:
  /// **'Nº Seguimiento'**
  String get adminShipmentTracking;

  /// No description provided for @adminShipmentNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get adminShipmentNotes;

  /// No description provided for @adminShipmentSave.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR ENVÍO'**
  String get adminShipmentSave;

  /// No description provided for @adminShipmentSaved.
  ///
  /// In es, this message translates to:
  /// **'Envío actualizado'**
  String get adminShipmentSaved;

  /// No description provided for @adminShipmentCreate.
  ///
  /// In es, this message translates to:
  /// **'CREAR ENVÍO'**
  String get adminShipmentCreate;

  /// No description provided for @adminShipmentCreated.
  ///
  /// In es, this message translates to:
  /// **'Envío creado'**
  String get adminShipmentCreated;

  /// No description provided for @adminCancellationsTitle.
  ///
  /// In es, this message translates to:
  /// **'CANCELACIONES'**
  String get adminCancellationsTitle;

  /// No description provided for @adminCancellationNoData.
  ///
  /// In es, this message translates to:
  /// **'Sin solicitudes de cancelación'**
  String get adminCancellationNoData;

  /// No description provided for @adminCancellationReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo'**
  String get adminCancellationReason;

  /// No description provided for @adminCancellationRequestedAt.
  ///
  /// In es, this message translates to:
  /// **'Solicitado'**
  String get adminCancellationRequestedAt;

  /// No description provided for @adminCancellationStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get adminCancellationStatus;

  /// No description provided for @adminCancellationApprove.
  ///
  /// In es, this message translates to:
  /// **'APROBAR Y REEMBOLSAR'**
  String get adminCancellationApprove;

  /// No description provided for @adminCancellationReject.
  ///
  /// In es, this message translates to:
  /// **'RECHAZAR'**
  String get adminCancellationReject;

  /// No description provided for @adminCancellationApproved.
  ///
  /// In es, this message translates to:
  /// **'Cancelación aprobada y reembolso procesado'**
  String get adminCancellationApproved;

  /// No description provided for @adminCancellationRejected.
  ///
  /// In es, this message translates to:
  /// **'Solicitud rechazada'**
  String get adminCancellationRejected;

  /// No description provided for @adminCancellationAdminNotes.
  ///
  /// In es, this message translates to:
  /// **'Nota para el cliente (opcional)'**
  String get adminCancellationAdminNotes;

  /// No description provided for @adminCancellationError.
  ///
  /// In es, this message translates to:
  /// **'Error al procesar la cancelación'**
  String get adminCancellationError;

  /// No description provided for @adminUsersTitle.
  ///
  /// In es, this message translates to:
  /// **'USUARIOS'**
  String get adminUsersTitle;

  /// No description provided for @adminUserNoData.
  ///
  /// In es, this message translates to:
  /// **'Sin usuarios'**
  String get adminUserNoData;

  /// No description provided for @adminUserEmail.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get adminUserEmail;

  /// No description provided for @adminUserRole.
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get adminUserRole;

  /// No description provided for @adminUserActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get adminUserActive;

  /// No description provided for @adminUserDisabled.
  ///
  /// In es, this message translates to:
  /// **'Desactivado'**
  String get adminUserDisabled;

  /// No description provided for @adminUserLastLogin.
  ///
  /// In es, this message translates to:
  /// **'Úlfimo acceso'**
  String get adminUserLastLogin;

  /// No description provided for @adminUserSaved.
  ///
  /// In es, this message translates to:
  /// **'Usuario actualizado'**
  String get adminUserSaved;

  /// No description provided for @adminUserMakeAdmin.
  ///
  /// In es, this message translates to:
  /// **'Hacer admin'**
  String get adminUserMakeAdmin;

  /// No description provided for @adminUserMakeUser.
  ///
  /// In es, this message translates to:
  /// **'Quitar admin'**
  String get adminUserMakeUser;

  /// No description provided for @adminUserDisableBtn.
  ///
  /// In es, this message translates to:
  /// **'Desactivar'**
  String get adminUserDisableBtn;

  /// No description provided for @adminUserEnableBtn.
  ///
  /// In es, this message translates to:
  /// **'Activar'**
  String get adminUserEnableBtn;

  /// No description provided for @adminProductDeleteHasOrders.
  ///
  /// In es, this message translates to:
  /// **'Este producto tiene pedidos y no puede eliminarse.'**
  String get adminProductDeleteHasOrders;

  /// No description provided for @adminProductDeactivateInstead.
  ///
  /// In es, this message translates to:
  /// **'DESACTIVAR EN SU LUGAR'**
  String get adminProductDeactivateInstead;

  /// No description provided for @adminProductDeleted.
  ///
  /// In es, this message translates to:
  /// **'Producto eliminado'**
  String get adminProductDeleted;

  /// No description provided for @generalError.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get generalError;

  /// No description provided for @generalLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get generalLoading;

  /// No description provided for @generalRetry.
  ///
  /// In es, this message translates to:
  /// **'REINTENTAR'**
  String get generalRetry;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'es':
      return SEs();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
