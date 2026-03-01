# Fashion Store Flutter — Auditoría & Plan de Arquitectura

> Generado tras auditar los 38 archivos fuente del proyecto.
> `flutter analyze → 0 issues` · `build_runner → OK`

---

## 1️⃣ AUDITORÍA DE ARQUITECTURA

### ✅ Decisiones acertadas

| Decisión | Por qué es correcta |
|---|---|
| Feature-first folder structure | Escala bien, cada feature es autónoma |
| Freezed + JsonSerializable para modelos | Inmutabilidad + codegen elimina boilerplate |
| `ProductModel` → `Product` entity con mapper | Separa capa data de domain correctamente |
| `Either<Failure, T>` en `ProductRepository` | Error handling funcional, predecible |
| `sealed class Failure` | Exhaustive pattern matching en Dart 3 |
| `CartNotifier` con `SharedPreferences` | Persistencia local correcta para guest checkout |
| `uniqueKey = '$productId\|${size ?? ""}'` | Evita duplicados por talla |
| `_RouterNotifier` con `ref.listen` | GoRouter se refresca sin `.stream` deprecated ni protected access |
| `authSessionProvider` con `ref.invalidateSelf()` | Reactivo sin StreamProvider intermedio |
| `offersSwitchProvider` con Supabase Realtime `.stream()` | Push real, no polling |
| `AppRoutes` constants | Rutas centralizadas, refactorizable |
| `flutter_dotenv` para config | Secrets fuera del código |

### ⚠️ Riesgos técnicos

| Riesgo | Severidad | Archivo(s) | Detalle |
|---|---|---|---|
| **Domain depende de Data** | 🔴 ALTO | `categories_repository.dart` L1 | `import '../../data/models/category_model.dart'` — domain no debe conocer modelos de data |
| **Presentation importada en Data** | 🔴 ALTO | `cart_repository.dart` L1, `cart_local_datasource.dart` L1 | Importan `CartState` de `presentation/providers/` — inversión de dependencias rota |
| **Admin monolítico** | 🟡 MEDIO | `admin_remote_datasource.dart` | Un solo datasource con 6 métodos `Future<void>` sin tipos — será inmanejable al crecer |
| **Features duplicadas** | 🟡 MEDIO | `offers/` + `flash_offers/` | Dos features para el mismo concepto (flash offers). `offers/` tiene el StreamProvider real, `flash_offers/` tiene skeleton vacío |
| **Repositories devuelven `void`** | 🟡 MEDIO | admin, auth, checkout, orders, returns, flash_offers | Sin tipos de retorno → no se puede componer UI ni manejar errores |
| **Solo products tiene Entity** | 🟡 MEDIO | categories, profiles, orders, etc. | Falta capa domain en la mayoría de features |
| **Sin use cases** | 🟢 BAJO | Todas | Aceptable en CRUD simple, pero checkout y orders necesitarán lógica de negocio |
| **Providers en `app_router.dart`** | 🟢 BAJO | `app_router.dart` | `authSessionProvider`, `currentProfileProvider`, `isAdminProvider` viven en router — deberían estar en `auth/` o `shared/` |
| **`productsProvider` sin parámetros** | 🟢 BAJO | `products_providers.dart` L15 | `FutureProvider` sin family → no se puede filtrar por categoría ni paginar |
| **`fpdart` solo en products** | 🟢 BAJO | `product_repository_impl.dart` | Si se va a usar Either, debe ser consistente en todas las features |

### 🔧 Mejoras recomendadas

1. **Extraer auth providers a `auth/presentation/providers/`**
   - Mover `authSessionProvider`, `currentProfileProvider`, `isAdminProvider` desde `app_router.dart` a `auth/presentation/providers/auth_providers.dart` (que hoy solo tiene datasource/repo providers)
   - Router solo importa los providers, no los define

2. **Crear entities para categories, orders, profiles**
   - `CategoryEntity`, `OrderEntity`, `OrderItemEntity`, `ProfileEntity`
   - Los repositories devuelven entities, no models
   - Elimina la dependencia domain → data

3. **Refactorizar cart: mover persistence a data layer**
   - `CartLocalDatasource` implementa load/save con SharedPreferences
   - `CartNotifier` solo maneja state, delega persistence al datasource via repo
   - Elimina import de presentation en data

4. **Unificar offers + flash_offers**
   - Borrar `flash_offers/` (skeleton vacío)
   - `offers/` pasa a llamarse `flash_offers/` y contiene el StreamProvider real + datasource + repo

5. **Partir admin en sub-features internas**
   - `admin/products/`, `admin/orders/`, `admin/returns/`, `admin/settings/`
   - Cada una con su datasource + provider
   - Comparten `AdminRepository` solo si hay lógica transversal (no la hay)

6. **Tipar todos los repositories**
   - Cambiar `Future<void>` por `Future<Either<Failure, T>>` o al menos `Future<T>` con tipo real

---

## 2️⃣ ROADMAP DE DESARROLLO REAL

### Hito 1 — Esqueleto compilable ✅ (COMPLETADO)

- Folder structure, modelos Freezed, router, cart, dotenv, 0 analyze errors.

### Hito 2 — Prototipo funcional (objetivo: app navegable con datos reales)

| # | Tarea | Prioridad | Archivos a crear/modificar | Providers |
|---|---|---|---|---|
| 2.1 | **Extraer auth providers del router** | Alta | Mover 3 providers a `auth/presentation/providers/auth_providers.dart`, router los importa | `authSessionProvider`, `currentProfileProvider`, `isAdminProvider` |
| 2.2 | **Login screen real** | Alta | `auth/data/datasources/auth_remote_datasource.dart` (implementar signIn/signOut con Supabase), `auth/presentation/screens/login_screen.dart` (form email+password), `auth/presentation/providers/auth_providers.dart` (añadir `signInProvider`) | `signInProvider` (AsyncNotifier) |
| 2.3 | **Home screen con productos destacados** | Alta | `home/presentation/screens/home_screen.dart`, `home/presentation/providers/home_providers.dart` | `featuredProductsProvider` (FutureProvider.family por categoría), reutiliza `productsProvider` |
| 2.4 | **Products list con filtro por categoría** | Alta | `products/presentation/providers/products_providers.dart` (cambiar a `.family`), `products/presentation/screens/products_screen.dart`, crear `products/presentation/widgets/product_card.dart` | `productsProvider` → `FutureProvider.family<Either<Failure,List<Product>>, ProductsFilter>` |
| 2.5 | **Product detail screen** | Alta | `products/presentation/screens/product_detail_screen.dart`, `products/presentation/providers/products_providers.dart` (añadir `productBySlugProvider`) | `productBySlugProvider` (FutureProvider.family<Product?, String>) |
| 2.6 | **Cart screen real** | Alta | `cart/presentation/screens/cart_screen.dart` (ListView de CartItems + total + botón checkout) | Usa `cartProvider` existente |
| 2.7 | **Categories list en sidebar/filtro** | Media | `categories/presentation/screens/categories_screen.dart` | Usa `categoriesProvider` existente |
| 2.8 | **Shared: AppScaffold con BottomNav o Drawer** | Media | `shared/widgets/app_scaffold.dart` (Home, Catálogo, Carrito, Cuenta) | Ninguno |
| 2.9 | **Shared: ProductImage widget** | Media | `shared/widgets/product_image.dart` (cached_network_image) | Ninguno, dep: `cached_network_image` |
| 2.10 | **Theme refinement** | Baja | `config/theme/app_theme.dart` (colores marca, tipografía, dark mode) | Ninguno |

### Hito 3 — App viva (checkout funcional, pedidos, admin básico)

| # | Tarea | Prioridad | Archivos | Providers |
|---|---|---|---|---|
| 3.1 | **Checkout flow completo** | Alta | Crear `OrderModel`, `OrderItemModel` (Freezed). `checkout/data/datasources/checkout_remote_datasource.dart` (insert fs_orders + fs_order_items). `checkout/presentation/screens/checkout_screen.dart` (form dirección/datos). `checkout/presentation/providers/checkout_providers.dart` | `checkoutNotifier` (AsyncNotifier — maneja submit) |
| 3.2 | **Mis pedidos** | Alta | `orders/data/datasources/orders_remote_datasource.dart` (query fs_orders). `orders/presentation/screens/orders_screen.dart`, `order_detail_screen.dart` | `ordersProvider` (FutureProvider), `orderDetailProvider` (FutureProvider.family) |
| 3.3 | **Flash offers realtime en Home** | Alta | Unificar `offers/` + `flash_offers/` en `flash_offers/`. `flash_offers/presentation/widgets/flash_banner.dart`. Home consume `offersSwitchProvider` | `offersSwitchProvider` (ya existe), `flashProductsProvider` (FutureProvider — products donde is_flash=true) |
| 3.4 | **Admin login** | Media | `admin/presentation/screens/admin_login_screen.dart` (reutiliza auth datasource, guard ya existe) | Usa `authSessionProvider` + `isAdminProvider` |
| 3.5 | **Admin products CRUD** | Media | `admin/products/datasource/` (upsert, delete, toggle is_active). `admin/presentation/screens/admin_products_screen.dart`, `admin_product_create_screen.dart`, `admin_product_edit_screen.dart` | `adminProductsProvider` (AsyncNotifierProvider), `adminProductFormProvider` |
| 3.6 | **Admin orders list** | Media | `admin/presentation/screens/admin_orders_screen.dart`, `admin_order_detail_screen.dart` | `adminOrdersProvider` (FutureProvider) |
| 3.7 | **Admin flash toggle** | Media | `admin/presentation/screens/admin_flash_screen.dart` (switch + select products) | `adminFlashSettingsProvider` (AsyncNotifier — update fs_settings) |
| 3.8 | **Devoluciones (admin)** | Baja | `admin/presentation/screens/admin_returns_screen.dart` | `adminReturnsProvider` |
| 3.9 | **Invoice PDF download** | Baja | `orders/data/datasources/orders_remote_datasource.dart` (downloadInvoicePdf) | Acción directa, no provider |
| 3.10 | **Image upload (admin)** | Baja | `admin/products/data/services/image_upload_service.dart` (Supabase Storage o Cloudinary) | `imageUploadProvider` |

---

## 3️⃣ FLUJO COMPLETO DE COMPRA

```
HOME ──→ CATÁLOGO ──→ DETALLE ──→ CARRITO ──→ CHECKOUT ──→ CONFIRMACIÓN
  │         │            │           │            │              │
  │         │            │           │            │              │
  ▼         ▼            ▼           ▼            ▼              ▼
featured  products    product     cart        checkout       order
Products  Provider    BySlug     Provider     Notifier     confirmation
Provider  (family)   Provider   (Notifier)  (AsyncNotif)   (one-shot)
```

### Detalle por pantalla

#### HOME
- **Provider**: `featuredProductsProvider` → `FutureProvider<List<Product>>`
- **Datos**: Supabase query `fs_products` where `is_active=true` order by `created_at desc` limit 8
- **Local**: nada
- **Flash banner**: consume `offersSwitchProvider` (StreamProvider<bool>) → si true, muestra banner con `flashProductsProvider`

#### CATÁLOGO (ProductsScreen)
- **Provider**: `productsProvider` → `FutureProvider.family<Either<Failure, List<Product>>, ProductsFilter>`
- **`ProductsFilter`**: Freezed class con `{String? categoryId, int page, String? search}`
- **Datos**: Supabase `fs_products` con paginación `.range(offset, offset+limit-1)`
- **Sidebar/chip**: `categoriesProvider` → `FutureProvider<List<CategoryModel>>` (ya implementado)
- **NO es provider**: scroll pagination se maneja con `ScrollController` en el widget, incrementa `page` en el filter

#### DETALLE (ProductDetailScreen)
- **Provider**: `productBySlugProvider` → `FutureProvider.family<Product?, String>`
- **Datos**: Supabase `fs_products` where `slug=:slug` and `is_active=true` `.maybeSingle()`
- **Local**: nada
- **Acción**: `AddToCartBtn` → `cartProvider.addItem(...)` (ya implementado)
- **Selector de talla**: estado local del widget (StatefulWidget o `useState` con hooks) — **NO necesita provider**

#### CARRITO (CartScreen)
- **Provider**: `cartProvider` → `NotifierProvider<CartNotifier, CartState>` (ya implementado)
- **Datos**: 100% local (SharedPreferences key `fashionstore_cart_v1`)
- **Acciones**: `removeItem(uniqueKey)`, `updateQuantity(uniqueKey, quantity:)`, `clear()`
- **NO necesita Supabase** hasta que el usuario haga checkout

#### CHECKOUT (CheckoutScreen)
- **Provider**: `checkoutNotifier` → `AsyncNotifierProvider<CheckoutNotifier, CheckoutState>`
- **`CheckoutState`**: Freezed `{initial, loading, success(orderId), error(Failure)}`
- **Datos**:
  - Lee `cartProvider` para los items
  - Lee `authSessionProvider` para saber si guest o logged
  - Si logged: pre-rellena datos del usuario desde `currentProfileProvider`
  - **Escribe**: insert en `fs_orders` + `fs_order_items` (transacción via RPC o secuencial)
  - **Descuenta stock**: update `fs_products.stock` y `fs_products.size_stock` (via RPC recomendado)
- **Local**: form state (dirección, nombre, email) es estado del widget, no provider
- **Post-checkout**: `cartProvider.clear()`, navegar a `/checkout/success`
- **Por qué AsyncNotifier y no FutureProvider**: porque el submit es una acción del usuario (mutación), no una lectura. FutureProvider es para data fetching, AsyncNotifier para acciones con estado.

#### CONFIRMACIÓN (CheckoutSuccessScreen)
- **Provider**: ninguno dedicado
- **Datos**: recibe `orderId` como parámetro de ruta, opcionalmente muestra resumen con `orderDetailProvider`
- **Acción**: botón "Ver mis pedidos" → navega a `/cuenta/pedidos`

### Cuándo usar qué tipo de Provider

| Tipo | Cuándo | Ejemplos en este proyecto |
|---|---|---|
| `Provider` | Valor síncrono derivado, singleton, repo/datasource wiring | `authSessionProvider`, `isAdminProvider`, todos los `*RepositoryProvider` |
| `FutureProvider` | Data fetch de lectura, sin mutación del usuario | `productsProvider`, `categoriesProvider`, `productBySlugProvider`, `ordersProvider` |
| `FutureProvider.family` | Igual pero parametrizado | `productBySlugProvider(slug)`, `productsProvider(filter)`, `orderDetailProvider(orderId)` |
| `StreamProvider` | Datos push en tiempo real | `offersSwitchProvider` |
| `NotifierProvider` | Estado mutable síncrono con acciones | `cartProvider` |
| `AsyncNotifierProvider` | Estado mutable con acciones async (submit, mutations) | `checkoutNotifier`, `signInNotifier`, `adminProductFormProvider` |
| **NO usar Provider para** | Estado efímero de UI (selected tab, text field, talla seleccionada) | Eso es `StatefulWidget` o hooks local |

---

## 4️⃣ SISTEMA DE OFERTAS FLASH (REAL-TIME)

### Arquitectura

```
Supabase fs_settings (row singleton)
    │
    │ Realtime via .stream(primaryKey: ['id'])
    │
    ▼
offersSwitchProvider (StreamProvider<bool>)  ← YA EXISTE en offers_switch_provider.dart
    │
    │ ref.watch
    │
    ▼
HomeScreen / FlashBanner widget
    │
    │ if true → show banner, fetch flash products
    │
    ▼
flashProductsProvider (FutureProvider<List<Product>>)  ← A CREAR
    query: fs_products where is_flash=true AND is_active=true
```

### Decisiones

1. **`offersSwitchProvider` ya es correcto** — `StreamProvider<bool>` que lee `fs_settings.flash_offers_enabled` via Realtime. No necesita cambios.

2. **`flashProductsProvider` debe ser `FutureProvider` que depende de `offersSwitchProvider`**:
   ```dart
   final flashProductsProvider = FutureProvider<List<Product>>((ref) async {
     final enabled = ref.watch(offersSwitchProvider).valueOrNull ?? false;
     if (!enabled) return const [];
     // query fs_products where is_flash=true, is_active=true
   });
   ```
   Cuando el admin apaga flash, `offersSwitchProvider` emite `false` → `flashProductsProvider` se invalida → devuelve `[]` → banner desaparece. **Cero rebuilds innecesarios** porque Riverpod solo rebuilda los widgets que escuchan estos providers.

3. **Evitar rebuilds innecesarios**:
   - El `FlashBanner` widget solo hace `ref.watch(offersSwitchProvider)`. Si el switch no cambia, no rebuild.
   - Productos flash se cargan **solo si el switch es true**. Si es false, ni se hace la query.
   - Widgets que no consumen estos providers no se enteran.

4. **Edge case: admin apaga mientras usuario está en Home**:
   - Realtime emite nuevo valor → `offersSwitchProvider` emite `false` → `flashProductsProvider` devuelve `[]` → banner desaparece inmediatamente.
   - Si el usuario tiene un producto flash en el carrito y procede a checkout, el checkout debe re-validar `is_flash` y `stock` server-side (RPC o check antes de insert).

5. **Edge case: pérdida de conexión Realtime**:
   - Supabase Realtime reconecta automáticamente.
   - Mientras tanto, el último valor emitido por el StreamProvider sigue vigente.
   - NO hacer polling como fallback — Supabase maneja reconexión.

### Qué NO hacer
- No crear un timer/polling para verificar el estado de flash
- No guardar el estado flash en SharedPreferences (siempre viene del server)
- No hacer un provider separado por cada producto flash (un solo query con where)

---

## 5️⃣ BACKOFFICE MÓVIL (ADMIN)

### Estructura propuesta

```
lib/features/admin/
├── products/
│   ├── data/
│   │   └── datasources/
│   │       └── admin_products_datasource.dart    ← CRUD fs_products
│   ├── presentation/
│   │   ├── providers/
│   │   │   └── admin_products_providers.dart      ← list, form, upsert
│   │   ├── screens/
│   │   │   ├── admin_products_screen.dart          ← lista con search/filter
│   │   │   ├── admin_product_create_screen.dart    ← form nuevo
│   │   │   └── admin_product_edit_screen.dart      ← form edición
│   │   └── widgets/
│   │       ├── product_form.dart                   ← form compartido create/edit
│   │       └── image_picker_grid.dart              ← grid de imágenes con add/remove
│   └── domain/                                     ← NO necesario (mismo modelo)
├── orders/
│   ├── data/datasources/admin_orders_datasource.dart
│   └── presentation/
│       ├── providers/admin_orders_providers.dart
│       └── screens/
├── settings/
│   ├── data/datasources/admin_settings_datasource.dart   ← fs_settings upsert
│   └── presentation/
│       ├── providers/admin_settings_providers.dart
│       └── screens/admin_settings_screen.dart
└── shared/                                              ← widgets admin comunes
    └── widgets/admin_scaffold.dart                       ← drawer con menú admin
```

### CRUD de productos

| Operación | Datasource method | Supabase call | Provider |
|---|---|---|---|
| List | `fetchProducts({search, page})` | `from('fs_products').select().order('name').range(...)` | `adminProductsProvider` (FutureProvider.family) |
| Get by ID | `getProduct(id)` | `from('fs_products').select().eq('id', id).single()` | `adminProductDetailProvider` (FutureProvider.family) |
| Create | `insertProduct(ProductModel)` | `from('fs_products').insert(model.toJson())` | `adminProductFormNotifier` (AsyncNotifier) |
| Update | `updateProduct(id, ProductModel)` | `from('fs_products').update(model.toJson()).eq('id', id)` | mismo `adminProductFormNotifier` |
| Toggle active | `toggleActive(id, bool)` | `from('fs_products').update({'is_active': val}).eq('id', id)` | acción directa en `adminProductsProvider` |

### Subida de imágenes

```
Usuario selecciona foto (cámara/galería)
    │
    ▼
image_picker (paquete)
    │
    ▼
Compresión local (flutter_image_compress)
    - Max 1200px lado largo
    - Quality 80
    - Output WebP si posible, JPEG fallback
    │
    ▼
Upload a Supabase Storage bucket "product-images"
    - Path: products/{productId}/{uuid}.webp
    - Devuelve public URL
    │
    ▼
Se agrega URL al array `images` del ProductModel
```

**Provider**: `imageUploadNotifier` (AsyncNotifier) — maneja estado de upload (idle, uploading %, done, error). NO es un FutureProvider porque el usuario inicia la acción.

**Dependencias nuevas**: `image_picker`, `flutter_image_compress`

### Gestión de stock por talla

- El campo `size_stock` (Map<String, int>) ya existe en `ProductModel`
- En el form de admin, mostrar una tabla editable: talla → stock
- El widget `SizeStockEditor` recibe `Map<String, int>` y devuelve el mapa actualizado
- Esto es estado local del form, NO necesita provider propio

### Qué NO reutilizar del cliente

| Componente | ¿Compartir? | Motivo |
|---|---|---|
| `ProductModel`, `CategoryModel` | ✅ Sí | Mismo modelo Supabase |
| `Product` entity + mapper | ✅ Sí | Misma tabla |
| `ProductsRemoteDatasource` | ❌ No | Admin necesita CRUD completo, cliente solo lee activos |
| `CartProvider` | ❌ No | Admin no tiene carrito |
| `SupabaseService` | ✅ Sí | Mismo cliente |
| `Failure` hierarchy | ✅ Sí | Misma gestión de errores |
| `AppRouter` routes | ❌ Parcial | Las rutas admin son suyas, pero el guard sí se comparte |

---

## 6️⃣ MAPEO ASTRO → FLUTTER

### Páginas públicas

| Astro (ruta) | Flutter (ruta GoRouter) | Feature | Screen | Provider(s) |
|---|---|---|---|---|
| `/` | `/` | home | `HomeScreen` | `featuredProductsProvider`, `offersSwitchProvider` |
| `/productos` | `/productos` | products | `ProductsScreen` | `productsProvider.family`, `categoriesProvider` |
| `/productos/[slug]` | `/productos/:slug` | products | `ProductDetailScreen` | `productBySlugProvider.family` |
| `/carrito` | `/carrito` | cart | `CartScreen` | `cartProvider` |
| `/checkout` | `/checkout` (a crear) | checkout | `CheckoutScreen` | `checkoutNotifier` |
| `/checkout/success` | `/checkout/success` | checkout | `CheckoutSuccessScreen` | — |
| `/login` | `/login` | auth | `LoginScreen` | `signInNotifier` |
| `/cuenta/pedidos` | `/cuenta/pedidos` | orders | `OrdersScreen` | `ordersProvider` |
| `/cuenta/pedidos/[id]` | `/cuenta/pedidos/:id` | orders | `OrderDetailScreen` | `orderDetailProvider.family` |

### Admin

| Astro (ruta) | Flutter (ruta GoRouter) | Feature | Screen | Provider(s) |
|---|---|---|---|---|
| `/admin/login` | `/admin/login` | admin | `AdminLoginScreen` | `signInNotifier` (reutilizado) |
| `/admin` | `/admin` | admin | `AdminHomeScreen` | — (dashboard) |
| `/admin/productos` | `/admin/productos` | admin/products | `AdminProductsScreen` | `adminProductsProvider` |
| `/admin/productos/nuevo` | `/admin/productos/nuevo` | admin/products | `AdminProductCreateScreen` | `adminProductFormNotifier` |
| `/admin/productos/[id]` | `/admin/productos/:id` | admin/products | `AdminProductEditScreen` | `adminProductFormNotifier` |
| `/admin/pedidos` | `/admin/pedidos` | admin/orders | `AdminOrdersScreen` | `adminOrdersProvider` |
| `/admin/pedidos/[id]` | `/admin/pedidos/:id` | admin/orders | `AdminOrderDetailScreen` | `adminOrderDetailProvider` |
| `/admin/devoluciones` | `/admin/devoluciones` | admin | `AdminReturnsScreen` | `adminReturnsProvider` |
| `/admin/flash` | `/admin/flash` | admin/settings | `AdminFlashScreen` | `adminFlashSettingsProvider` |
| `/admin/settings` | `/admin/settings` | admin/settings | `AdminSettingsScreen` | `adminSettingsProvider` |

### APIs / Endpoints Astro

| Astro endpoint | Flutter equivalente | ¿Replicar? |
|---|---|---|
| `GET /api/products` | Supabase directo `fs_products` | ✅ Ya hecho (datasource) |
| `GET /api/categories` | Supabase directo `fs_categories` | ✅ Ya hecho (datasource) |
| `POST /api/checkout` | Supabase directo insert `fs_orders` + `fs_order_items` | ✅ Replicar — pero en móvil es insert directo, no HTTP a Astro |
| `GET /api/flash-offer` | Supabase Realtime `fs_settings` + query `fs_products` | ✅ Ya hecho parcialmente (`offersSwitchProvider`) |
| `GET /api/orders/[id]/invoice.pdf` | HTTP GET al Astro backend (mantener) | ⚠️ Mantener como HTTP call — el PDF se genera server-side |
| `POST /api/admin/products` | Supabase directo | ✅ Replicar como insert/update directo |
| `POST /api/admin/upload` | Supabase Storage upload | ✅ Replicar — upload directo a Storage, no via Astro |
| `GET /api/admin/returns` | Supabase directo si la tabla existe | ⚠️ Depende de si hay tabla `fs_returns` — verificar DDL |

### Endpoints que NO conviene replicar en móvil

| Endpoint | Motivo |
|---|---|
| `GET /api/orders/[id]/invoice.pdf` | La generación de PDF debe seguir siendo server-side (Astro). Flutter hace HTTP GET y abre el PDF con `open_file` o `printing`. |
| Cualquier webhook (Stripe, etc.) | Los webhooks son server-to-server, no aplica a móvil |
| SSR de páginas | No existe en móvil |

---

## 7️⃣ DECISIONES TÉCNICAS JUSTIFICADAS

### Por qué Riverpod y cómo evitar sobreuso

**Por qué**: Riverpod 2.x con code generation eliminado (usamos syntax clásica) da compile-time safety, auto-dispose, dependency tracking sin `BuildContext`, y testabilidad (override providers en tests). Es la elección correcta para este proyecto.

**Cómo evitar sobreuso**:
- **NO crear provider para estado efímero de UI**: talla seleccionada en detalle, texto del search, tab activo → `StatefulWidget` o hooks
- **NO crear provider para cada campo de un form**: el form state vive en el widget, solo el submit es provider (AsyncNotifier)
- **NO crear provider que solo wrappea otro**: si `providerA` solo hace `ref.watch(providerB).someField`, probablemente sobra
- **Regla**: si el estado NO necesita sobrevivir a la navegación y NO lo consume otro provider → NO es provider

### Cuándo AsyncNotifier vs FutureProvider

| | FutureProvider | AsyncNotifier |
|---|---|---|
| **Propósito** | Lectura de datos (fetch) | Acciones con estado (submit, mutation) |
| **Trigger** | Automático al watch | Manual (método del notifier) |
| **Re-ejecución** | Cuando cambian dependencias | Cuando el usuario invoca una acción |
| **Ejemplo** | `productsProvider`, `categoriesProvider` | `checkoutNotifier.submit()`, `signInNotifier.signIn()` |
| **Estado** | `AsyncValue<T>` auto | `AsyncValue<T>` con control manual |

**Regla simple**: ¿el usuario hace click para que pase? → AsyncNotifier. ¿Se carga solo al entrar a la pantalla? → FutureProvider.

### Cómo manejar errores con Failure

```
Datasource (throws exceptions)
    │
    ▼
Repository (catch → Either<Failure, T>)
    │
    ▼
Provider / Notifier (fold o match)
    │
    ▼
UI (when/switch en AsyncValue o Either)
```

- **Datasource**: lanza excepciones nativas (`SocketException`, `PostgrestException`, etc.)
- **Repository**: captura y convierte a `Failure` subtype. Devuelve `Either<Failure, T>`.
- **Provider**: puede exponer el `Either` directamente (UI hace `.fold()`) o convertir a `AsyncValue` con `.when()`
- **Recomendación**: para features donde el error es recuperable (retry), usar `Either`. Para features donde solo muestras mensaje, `AsyncValue.error` es suficiente.
- **Hacer consistente**: todas las features deberían usar `Either<Failure, T>` en el repository, no solo products.

### Preparar para modo offline parcial

**Fase 1 (Hito 2)**: no hace falta offline. La app requiere conexión.

**Fase 2 (post Hito 3)**: offline parcial para catálogo:
1. Añadir `drift` (SQLite) o `isar` como cache local
2. El repository implementa patrón cache-first:
   - Intenta Supabase → guarda en cache → devuelve
   - Si falla (sin red) → lee cache → devuelve con flag `isStale: true`
3. **El carrito YA es offline** (SharedPreferences)
4. **Checkout NUNCA es offline** (requiere write a Supabase)
5. **Realtime (flash offers)** se degrada gracefully: último valor conocido se mantiene

**NO implementar ahora**: el costo de añadir cache es alto y el beneficio bajo hasta que la app esté en producción con usuarios reales.

---

## RESUMEN EJECUTIVO

| Concepto | Estado |
|---|---|
| Esqueleto compilable | ✅ Hecho |
| Modelos Freezed alineados | ✅ Hecho (products, categories, profiles) |
| Cart persistente | ✅ Hecho |
| Router con guards | ✅ Hecho |
| Auth real | 🔲 Skeleton |
| Home con datos | 🔲 Skeleton |
| Catálogo navegable | 🔲 Skeleton |
| Detalle producto | 🔲 Skeleton |
| Checkout | 🔲 Skeleton |
| Pedidos | 🔲 Skeleton |
| Flash offers client | 🔲 Parcial (switch provider OK, UI no) |
| Admin CRUD | 🔲 Skeleton |
| Image upload | 🔲 No existe |

**Siguiente paso recomendado**: Hito 2.1 — extraer auth providers del router + 2.2 — login real.
