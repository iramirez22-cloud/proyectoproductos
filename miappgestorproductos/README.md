# Gestor de productos

Aplicación Flutter con inicio de sesión de demostración y catálogo conectado a
[FakeStore API](https://fakestoreapi.com/products/). Incluye búsqueda por título
y categoría, vista de detalle y formularios para crear, editar y eliminar.

## Ejecutar

Desde esta carpeta, ejecuta:

```sh
flutter pub get
flutter run
```

El catálogo necesita conexión a Internet. Android tiene declarado el permiso de
red para poder consultar la API.

## Acceso de demostración

- Usuario: `admin`
- Contraseña: `123456`

## Datos y operaciones

El catálogo se carga con una petición GET. Las operaciones crear, actualizar y
eliminar envían POST, PUT y DELETE, respectivamente, y actualizan la lista local
cuando la API responde correctamente. FakeStore API es una API de demostración:
los cambios no son persistentes al volver a cargar el catálogo.
