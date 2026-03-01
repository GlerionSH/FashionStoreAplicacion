// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get navHome => 'INICIO';

  @override
  String get navCatalog => 'CATALOGO';

  @override
  String get navCart => 'CARRITO';

  @override
  String get navAccount => 'CUENTA';

  @override
  String get navLogin => 'ENTRAR';

  @override
  String get navAdmin => 'ADMIN';

  @override
  String get homeHeroLabel => 'Nueva coleccion';

  @override
  String get homeHeroTitle => 'DESCUBRE\nTU ESTILO';

  @override
  String get homeHeroSubtitle => 'Piezas atemporales con calidad y elegancia';

  @override
  String get homeViewProducts => 'VER PRODUCTOS';

  @override
  String get homeViewCart => 'VER CARRITO';

  @override
  String get homeFeatured => 'Destacados';

  @override
  String get homeViewAll => 'Ver todo';

  @override
  String get homeViewCatalog => 'VER TODO EL CATALOGO';

  @override
  String get homeNoProducts => 'No hay productos todavia';

  @override
  String get homeCategoryLabel => 'CATEGORIA';

  @override
  String get homeErrorConnection => 'ERROR DE CONEXION';

  @override
  String get homeErrorPermission => 'PERMISO DENEGADO';

  @override
  String get homeErrorLoad => 'ERROR AL CARGAR';

  @override
  String get homeDiagnostics => 'DIAGNOSTICOS';

  @override
  String get homeTooltipDiagnostics => 'Diagnosticos';

  @override
  String get cartTitle => 'CARRITO';

  @override
  String get cartEmptyTitle => 'TU CARRITO ESTA VACIO';

  @override
  String get cartEmptySubtitle => 'Explora nuestro catalogo y anade productos';

  @override
  String get cartViewCatalog => 'VER CATALOGO';

  @override
  String get cartTotal => 'TOTAL';

  @override
  String get cartCheckout => 'TRAMITAR PEDIDO';

  @override
  String get cartSize => 'Talla';

  @override
  String get cartErrorNoOrder => 'Error: no se pudo obtener el ID del pedido';

  @override
  String get loginTitle => 'Iniciar sesion';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Contrasena';

  @override
  String get loginEmailRequired => 'Introduce tu email';

  @override
  String get loginPasswordRequired => 'Introduce tu contrasena';

  @override
  String get loginButton => 'Entrar';

  @override
  String productStock(int count) {
    return 'Stock: $count';
  }

  @override
  String productStockFrom(int count) {
    return 'Stock desde: $count';
  }

  @override
  String get productAvailable => 'Disponible';

  @override
  String get productSoldOut => 'Agotado';

  @override
  String get productSoldOutUpper => 'AGOTADO';

  @override
  String get productCategory => 'Categoria';

  @override
  String get productAddToCart => 'ANADIR';

  @override
  String get productSelectSize => 'SELECCIONA TALLA';

  @override
  String get productSizeSoldOut => 'TALLA AGOTADA';

  @override
  String get productMaxInCart => 'Ya tienes el maximo disponible en tu carrito';

  @override
  String get productViewProduct => 'Ver producto';

  @override
  String get productSize => 'TALLA';

  @override
  String get productStockPerSize => 'STOCK POR TALLA';

  @override
  String productStockTotal(int count) {
    return 'Stock total: $count';
  }

  @override
  String productStockAvailable(int count) {
    return 'Stock disponible: $count';
  }

  @override
  String get productSearch => 'Buscar';

  @override
  String get productAll => 'TODOS';

  @override
  String get productNotFound => 'Producto no encontrado';

  @override
  String get productNoResults => 'No se encontraron productos';

  @override
  String get checkoutOrderConfirmed => 'PEDIDO CONFIRMADO';

  @override
  String get checkoutVerifying => 'Verificando pago...';

  @override
  String get checkoutConfirmed => 'PAGO CONFIRMADO';

  @override
  String get checkoutThanks => 'GRACIAS POR TU COMPRA';

  @override
  String get checkoutVerifyingMsg => 'Estamos verificando tu pago...';

  @override
  String get checkoutConfirmedMsg =>
      'Tu pedido ha sido procesado correctamente. Recibiras un email de confirmacion.';

  @override
  String get checkoutPending => 'Pendiente';

  @override
  String get checkoutPaid => 'Pagado';

  @override
  String get checkoutCancelled => 'Cancelado';

  @override
  String get checkoutRefunded => 'Reembolsado';

  @override
  String get checkoutShipped => 'Enviado';

  @override
  String get checkoutTest => 'Test';

  @override
  String get checkoutViewInvoice => 'VER FACTURA';

  @override
  String get checkoutMyOrders => 'MIS PEDIDOS';

  @override
  String get checkoutBackHome => 'VOLVER AL INICIO';

  @override
  String get checkoutRetryVerification => 'REINTENTAR VERIFICACION';

  @override
  String get checkoutContactSupport => 'CONTACTAR SOPORTE';

  @override
  String get checkoutTimeoutMsg =>
      'El pago puede tardar unos segundos en confirmarse.';

  @override
  String get checkoutOrder => 'Pedido';

  @override
  String get checkoutTotal => 'Total';

  @override
  String get checkoutConfirmedAt => 'Confirmado';

  @override
  String get checkoutCreatedAt => 'Creado';

  @override
  String get checkoutArticle => 'ARTICULO';

  @override
  String get ordersTitle => 'Mis pedidos';

  @override
  String get ordersEmpty => 'No tienes pedidos todavia';

  @override
  String get ordersViewProducts => 'Ver productos';

  @override
  String get ordersDetail => 'Detalle del pedido';

  @override
  String get ordersSubtotal => 'Subtotal';

  @override
  String get ordersDiscount => 'Descuento';

  @override
  String get ordersRefunded => 'Reembolsado';

  @override
  String get ordersItems => 'Articulos';

  @override
  String get ordersViewInvoice => 'Ver factura';

  @override
  String get ordersDownloadInvoice => 'Descargar factura (PDF)';

  @override
  String get ordersEmailSent => 'Email enviado';

  @override
  String get ordersEmailError => 'Error email';

  @override
  String get ordersDate => 'Fecha';

  @override
  String get ordersStatus => 'Estado';

  @override
  String get ordersPaidAt => 'Pagado';

  @override
  String get ordersRetry => 'REINTENTAR';

  @override
  String get ordersNotFound => 'Pedido no encontrado';

  @override
  String get ordersSize => 'Talla';

  @override
  String get ordersPaidLabel => 'pagado';

  @override
  String get ordersInvoiceError =>
      'No se pudo descargar la factura. Reintenta mas tarde.';

  @override
  String get ordersInvoiceLoginRequired =>
      'Inicia sesion para descargar tu factura.';

  @override
  String get ordersInvoiceSessionExpired =>
      'Tu sesion caduco. Vuelve a iniciar sesion.';

  @override
  String get ordersInvoiceNotFound => 'Factura no disponible todavia.';

  @override
  String get ordersLoadItemsError => 'Error cargando articulos';

  @override
  String get ordersCouponDiscount => 'Descuento cupón';

  @override
  String get ordersShippingStatus => 'Estado del envío';

  @override
  String get ordersCarrier => 'Transportista';

  @override
  String get ordersTracking => 'Seguimiento';

  @override
  String get ordersShipmentPending => 'Preparando envío';

  @override
  String get ordersShipmentPreparing => 'En preparación';

  @override
  String get ordersShipmentShipped => 'Enviado';

  @override
  String get ordersShipmentDelivered => 'Entregado';

  @override
  String get ordersShipmentCancelled => 'Cancelado';

  @override
  String get ordersCancelRequest => 'Solicitar cancelación';

  @override
  String get ordersCancelRequestTitle => 'Solicitar cancelación del pedido';

  @override
  String get ordersCancelRequestReason => 'Motivo (opcional)';

  @override
  String get ordersCancelRequestSend => 'ENVIAR SOLICITUD';

  @override
  String get ordersCancelRequestSent =>
      'Solicitud enviada. Te notificaremos por email.';

  @override
  String get ordersCancelRequestError =>
      'No se pudo enviar la solicitud. Reintenta.';

  @override
  String get ordersCancelRequestExists =>
      'Ya existe una solicitud de cancelación para este pedido.';

  @override
  String get ordersCancelNotAllowed =>
      'No se puede cancelar un pedido en este estado.';

  @override
  String get ordersCancelRequested => 'Cancelación solicitada';

  @override
  String get ordersStatusPreparing => 'En preparación';

  @override
  String get ordersStatusShipped => 'Enviado';

  @override
  String get ordersStatusDelivered => 'Entregado';

  @override
  String get ordersStatusCancelled => 'Cancelado';

  @override
  String get ordersStatusRefunded => 'Reembolsado';

  @override
  String get newsletterTitle => 'Newsletter';

  @override
  String get newsletterSubtitle => 'Recibe novedades y ofertas exclusivas';

  @override
  String get newsletterEmail => 'Tu email';

  @override
  String get newsletterSubscribe => 'SUSCRIBIRME';

  @override
  String get newsletterUnsubscribe => 'CANCELAR SUSCRIPCIÓN';

  @override
  String get newsletterSubscribed =>
      'Suscrito — Revisa tu email para ver tu cupón de bienvenida.';

  @override
  String get newsletterAlreadySubscribed => 'Ya estás suscrito al newsletter.';

  @override
  String get newsletterUnsubscribed => 'Te has dado de baja correctamente.';

  @override
  String get newsletterError => 'Error al procesar la solicitud. Reintenta.';

  @override
  String get newsletterLoading => 'Procesando...';

  @override
  String get couponCode => 'Código de descuento';

  @override
  String get couponApply => 'APLICAR';

  @override
  String couponApplied(int percent) {
    return '$percent% de descuento aplicado';
  }

  @override
  String get couponInvalid => 'Código no válido o caducado';

  @override
  String get couponRemove => 'QUITAR';

  @override
  String couponDiscount(int percent) {
    return 'Descuento cupón ($percent%)';
  }

  @override
  String get accountTitle => 'Mi cuenta';

  @override
  String get accountTitleUpper => 'MI CUENTA';

  @override
  String get accountLogin => 'Inicia sesion para ver tu cuenta';

  @override
  String get accountLoginBtn => 'INICIAR SESION';

  @override
  String get accountOrders => 'Mis pedidos';

  @override
  String get accountOrdersSubtitle => 'Historial y estado de tus compras';

  @override
  String get accountAddress => 'Direccion de envio';

  @override
  String get accountAddressPlaceholder => 'Proximamente';

  @override
  String get accountSettings => 'Ajustes';

  @override
  String get accountSupport => 'Soporte';

  @override
  String get accountSupportSubtitle => 'Enviar consulta o ver tus tickets';

  @override
  String get accountLogout => 'CERRAR SESION';

  @override
  String get accountLanguage => 'Idioma';

  @override
  String get accountLanguageEs => 'Espanol';

  @override
  String get accountLanguageEn => 'English';

  @override
  String get supportTitle => 'Soporte';

  @override
  String get supportNewTicket => 'Nueva consulta';

  @override
  String get supportMyTickets => 'Mis consultas';

  @override
  String get supportNoTickets => 'No tienes consultas todavia';

  @override
  String get supportName => 'Nombre';

  @override
  String get supportEmail => 'Email';

  @override
  String get supportSubject => 'Asunto';

  @override
  String get supportMessage => 'Mensaje';

  @override
  String get supportSend => 'ENVIAR';

  @override
  String get supportSending => 'Enviando...';

  @override
  String get supportOpen => 'Abierto';

  @override
  String get supportAnswered => 'Respondido';

  @override
  String get supportClosed => 'Cerrado';

  @override
  String get supportTicketCreated =>
      'Consulta enviada correctamente. Recibiras un email de acuse.';

  @override
  String get supportTicketDetail => 'Detalle de consulta';

  @override
  String get supportReply => 'Respuesta';

  @override
  String get supportRequiredField => 'Campo obligatorio';

  @override
  String get supportInvalidEmail => 'Email no valido';

  @override
  String get supportYou => 'Tu';

  @override
  String get supportAdmin => 'Soporte';

  @override
  String get supportLoginToSeeTickets =>
      'Inicia sesion para ver tus consultas anteriores';

  @override
  String get supportErrorSending => 'Error al enviar la consulta. Reintenta.';

  @override
  String get adminTitle => 'ADMIN';

  @override
  String get adminPanelTitle => 'PANEL ADMIN';

  @override
  String get adminMetricOrders => 'PEDIDOS';

  @override
  String get adminMetricRevenue => 'INGRESOS';

  @override
  String get adminMetricReturns => 'DEVOLUCIONES';

  @override
  String get adminMetricProducts => 'PRODUCTOS';

  @override
  String get adminActions => 'ACCIONES';

  @override
  String get adminRecentOrders => 'PEDIDOS RECIENTES';

  @override
  String get adminNoOrdersYet => 'Sin pedidos todavia';

  @override
  String get adminNoOrders => 'Sin pedidos';

  @override
  String get adminNavProducts => 'Productos';

  @override
  String get adminNavOrders => 'Pedidos';

  @override
  String get adminNavReturns => 'Devoluciones';

  @override
  String get adminNavFlash => 'Flash Offers';

  @override
  String get adminNavSettings => 'Ajustes';

  @override
  String get adminOrdersTitle => 'PEDIDOS';

  @override
  String get adminProductsTitle => 'PRODUCTOS';

  @override
  String get adminReturnsTitle => 'DEVOLUCIONES';

  @override
  String get adminFlashTitle => 'FLASH OFFERS';

  @override
  String get adminSettingsTitle => 'AJUSTES';

  @override
  String get adminSearchProduct => 'Buscar producto...';

  @override
  String get adminNoResults => 'Sin resultados';

  @override
  String adminProductStockLabel(int count) {
    return 'Stock: $count';
  }

  @override
  String get adminOrderDetailTitle => 'DETALLE PEDIDO';

  @override
  String get adminFieldEmail => 'Email';

  @override
  String get adminOrderStatusLabel => 'Estado';

  @override
  String get adminOrderPaidLabel => 'Pagado';

  @override
  String get adminChangeStatus => 'CAMBIAR ESTADO';

  @override
  String get adminViewInvoice => 'VER FACTURA';

  @override
  String get adminOrderItems => 'ARTICULOS';

  @override
  String get adminNoItemsLoaded => 'Sin articulos cargados';

  @override
  String get adminFlashNoOffers => 'Sin ofertas flash';

  @override
  String get adminFlashNewOffer => 'Nueva oferta flash';

  @override
  String get adminFlashDiscount => 'Descuento %';

  @override
  String get adminFlashPopupTitle => 'Popup titulo (opcional)';

  @override
  String get adminFlashPopupText => 'Popup texto (opcional)';

  @override
  String get adminFlashPopupActive => 'Popup activo';

  @override
  String get adminCancel => 'CANCELAR';

  @override
  String get adminCreate => 'CREAR';

  @override
  String get adminProductNewTitle => 'NUEVO PRODUCTO';

  @override
  String get adminProductEditTitle => 'EDITAR PRODUCTO';

  @override
  String get adminProductCreated => 'PRODUCTO CREADO';

  @override
  String get adminProductSaved => 'PRODUCTO GUARDADO';

  @override
  String get adminProductCreateBtn => 'CREAR PRODUCTO';

  @override
  String get adminProductSaveBtn => 'GUARDAR';

  @override
  String get adminProductDeleteTitle => 'Eliminar producto';

  @override
  String get adminProductDeleteMsg => 'Esta accion no se puede deshacer.';

  @override
  String get adminProductDeleteBtn => 'ELIMINAR';

  @override
  String get adminFieldRequired => 'Obligatorio';

  @override
  String get adminFieldName => 'Nombre *';

  @override
  String get adminFieldNameEs => 'Nombre (ES)';

  @override
  String get adminFieldNameEn => 'Nombre (EN)';

  @override
  String get adminFieldSlug => 'Slug *';

  @override
  String get adminFieldDesc => 'Descripcion';

  @override
  String get adminFieldDescEs => 'Descripcion (ES)';

  @override
  String get adminFieldDescEn => 'Descripcion (EN)';

  @override
  String get adminFieldPrice => 'Precio (cents) *';

  @override
  String get adminFieldStock => 'Stock *';

  @override
  String get adminFieldCategoryId => 'Category ID';

  @override
  String get adminFieldActive => 'Activo';

  @override
  String get adminFieldFlash => 'Flash';

  @override
  String get adminFieldImages => 'IMAGENES (una URL por linea)';

  @override
  String get adminFieldSizes => 'Tallas (separadas por coma)';

  @override
  String get adminFieldSizeStock => 'Size stock (JSON)';

  @override
  String get adminReturnsEmpty => 'Sin devoluciones';

  @override
  String get adminReturnOrder => 'Pedido';

  @override
  String get adminReturnReason => 'Motivo';

  @override
  String get adminReturnApprove => 'APROBAR';

  @override
  String get adminReturnReject => 'RECHAZAR';

  @override
  String get adminSettingsGeneral => 'GENERAL';

  @override
  String get adminSettingsInfo => 'INFO';

  @override
  String get adminFlashEnabled => 'Flash Offers habilitadas';

  @override
  String get adminFlashEnabledSubtitle =>
      'Activa o desactiva las ofertas flash globalmente';

  @override
  String get adminRetry => 'REINTENTAR';

  @override
  String get adminNavCoupons => 'Cupones';

  @override
  String get adminNavShipments => 'Envíos';

  @override
  String get adminNavCancellations => 'Cancelaciones';

  @override
  String get adminNavUsers => 'Usuarios';

  @override
  String get adminCouponsTitle => 'CUPONES';

  @override
  String get adminCouponNew => 'Nuevo cupón';

  @override
  String get adminCouponCode => 'Código';

  @override
  String get adminCouponPercent => '% Descuento';

  @override
  String get adminCouponActive => 'Activo';

  @override
  String get adminCouponMaxRedemptions => 'Máx. usos globales';

  @override
  String get adminCouponMaxPerUser => 'Máx. por usuario';

  @override
  String get adminCouponMinOrder => 'Pedido mínimo (cents)';

  @override
  String get adminCouponNotes => 'Notas';

  @override
  String get adminCouponCreate => 'CREAR CUPÓN';

  @override
  String get adminCouponCreated => 'Cupón creado';

  @override
  String get adminCouponNoData => 'Sin cupones todavía';

  @override
  String get adminCouponRedemptions => 'Usos';

  @override
  String get adminCouponDeactivated => 'Cupón desactivado';

  @override
  String get adminCouponActivated => 'Cupón activado';

  @override
  String get adminCouponDeleteError =>
      'No se puede eliminar un cupón con usos. Desuáctivalo.';

  @override
  String get adminShipmentsTitle => 'ENVÍOS';

  @override
  String get adminShipmentNoData => 'Sin envíos todavía';

  @override
  String get adminShipmentOrder => 'Pedido';

  @override
  String get adminShipmentStatus => 'Estado';

  @override
  String get adminShipmentCarrier => 'Transportista';

  @override
  String get adminShipmentTracking => 'Nº Seguimiento';

  @override
  String get adminShipmentNotes => 'Notas';

  @override
  String get adminShipmentSave => 'GUARDAR ENVÍO';

  @override
  String get adminShipmentSaved => 'Envío actualizado';

  @override
  String get adminShipmentCreate => 'CREAR ENVÍO';

  @override
  String get adminShipmentCreated => 'Envío creado';

  @override
  String get adminCancellationsTitle => 'CANCELACIONES';

  @override
  String get adminCancellationNoData => 'Sin solicitudes de cancelación';

  @override
  String get adminCancellationReason => 'Motivo';

  @override
  String get adminCancellationRequestedAt => 'Solicitado';

  @override
  String get adminCancellationStatus => 'Estado';

  @override
  String get adminCancellationApprove => 'APROBAR Y REEMBOLSAR';

  @override
  String get adminCancellationReject => 'RECHAZAR';

  @override
  String get adminCancellationApproved =>
      'Cancelación aprobada y reembolso procesado';

  @override
  String get adminCancellationRejected => 'Solicitud rechazada';

  @override
  String get adminCancellationAdminNotes => 'Nota para el cliente (opcional)';

  @override
  String get adminCancellationError => 'Error al procesar la cancelación';

  @override
  String get adminUsersTitle => 'USUARIOS';

  @override
  String get adminUserNoData => 'Sin usuarios';

  @override
  String get adminUserEmail => 'Email';

  @override
  String get adminUserRole => 'Rol';

  @override
  String get adminUserActive => 'Activo';

  @override
  String get adminUserDisabled => 'Desactivado';

  @override
  String get adminUserLastLogin => 'Úlfimo acceso';

  @override
  String get adminUserSaved => 'Usuario actualizado';

  @override
  String get adminUserMakeAdmin => 'Hacer admin';

  @override
  String get adminUserMakeUser => 'Quitar admin';

  @override
  String get adminUserDisableBtn => 'Desactivar';

  @override
  String get adminUserEnableBtn => 'Activar';

  @override
  String get adminProductDeleteHasOrders =>
      'Este producto tiene pedidos y no puede eliminarse.';

  @override
  String get adminProductDeactivateInstead => 'DESACTIVAR EN SU LUGAR';

  @override
  String get adminProductDeleted => 'Producto eliminado';

  @override
  String get generalError => 'Error';

  @override
  String get generalLoading => 'Cargando...';

  @override
  String get generalRetry => 'REINTENTAR';
}
