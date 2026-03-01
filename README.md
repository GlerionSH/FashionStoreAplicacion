# fashion_store

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Dev en Web: configurar CORS en Supabase

Si al ejecutar `flutter run -d chrome` ves el error
`ClientException: Failed to fetch` en las peticiones a Supabase REST,
es muy probable que el navegador esté bloqueando la solicitud por CORS.

### Pasos para solucionarlo

1. **Desactiva extensiones del navegador** (ad-blockers, privacy badger, etc.)
   que puedan interceptar cabeceras `Access-Control-*`.

2. **Configura CORS origins en Supabase**:
   - Abre tu proyecto en [Supabase Dashboard](https://supabase.com/dashboard).
   - Ve a **Settings → API → CORS Allowed Origins**.
   - Añade la URL de desarrollo, por ejemplo:
     ```
     http://localhost:8080
     http://localhost:5000
     ```
   - Guarda los cambios.

3. **Prueba en ventana de incógnito** para descartar caché o extensiones.

4. **Usa la pantalla de Diagnósticos** dentro de la app
   (icono ❤️‍🩹 en la Home) para verificar la conectividad paso a paso.

### Verificación rápida (curl)

```bash
curl -I "https://<tu-proyecto>.supabase.co/rest/v1/fs_products?select=id&limit=1" \
  -H "apikey: <tu-anon-key>" \
  -H "Authorization: Bearer <tu-anon-key>"
```

Si devuelve `200 OK` con cabeceras `access-control-allow-origin`,
el problema es del lado del navegador, no del servidor.
