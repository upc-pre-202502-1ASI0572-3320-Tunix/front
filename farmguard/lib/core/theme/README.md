# 🎨 Sistema de Diseño - FarmGuard

Sistema de diseño centralizado para mantener consistencia visual en toda la aplicación.

## 📁 Estructura

```
core/theme/
├── app_colors.dart        # Paleta de colores
├── app_text_styles.dart   # Estilos de texto
├── app_dimensions.dart    # Espaciados y tamaños
├── app_theme.dart         # Tema de Material Design
└── theme.dart             # Barrel export
```

## 🎨 Paleta de Colores

### Colores Primarios
```dart
AppColors.primary          // #4CAF50 - Verde principal
AppColors.primaryDark      // #388E3C - Verde oscuro
AppColors.primaryLight     // #81C784 - Verde claro
```

### Colores Secundarios
```dart
AppColors.secondary        // #8BC34A - Verde lima
AppColors.secondaryDark    // #689F38
AppColors.secondaryLight   // #AED581
```

### Colores de Estado
```dart
AppColors.success          // #4CAF50 - Éxito
AppColors.error            // #E53935 - Error
AppColors.warning          // #FFA726 - Advertencia
AppColors.info             // #42A5F5 - Información
```

### Colores de Superficie
```dart
AppColors.background       // #F5F5F5 - Fondo
AppColors.surface          // #FFFFFF - Superficie
AppColors.surfaceVariant   // #FAFAFA - Variante
```

### Colores de Texto
```dart
AppColors.textPrimary      // #212121 - Texto principal
AppColors.textSecondary    // #757575 - Texto secundario
AppColors.textDisabled     // #BDBDBD - Texto deshabilitado
AppColors.textHint         // #9E9E9E - Texto hint
```

### Colores Específicos
```dart
AppColors.farmGreen        // #66BB6A - Verde granja
AppColors.soilBrown        // #8D6E63 - Marrón tierra
AppColors.skyBlue          // #64B5F6 - Azul cielo
AppColors.sunYellow        // #FFD54F - Amarillo sol
```

### Gradientes
```dart
AppColors.primaryGradient     // Verde degradado
AppColors.backgroundGradient  // Fondo degradado
```

## 📝 Estilos de Texto

### Títulos
```dart
AppTextStyles.h1    // 32px, Bold
AppTextStyles.h2    // 24px, Bold
AppTextStyles.h3    // 20px, SemiBold
AppTextStyles.h4    // 18px, SemiBold
```

### Cuerpo
```dart
AppTextStyles.bodyLarge    // 16px, Normal
AppTextStyles.bodyMedium   // 14px, Normal
AppTextStyles.bodySmall    // 12px, Normal
```

### Otros
```dart
AppTextStyles.button       // 16px, SemiBold, White
AppTextStyles.label        // 14px, Medium
AppTextStyles.caption      // 12px, Normal
```

### Inputs
```dart
AppTextStyles.input        // 16px, Normal
AppTextStyles.inputHint    // 16px, Normal, Hint
AppTextStyles.inputError   // 12px, Normal, Error
```

## 📐 Dimensiones

### Padding / Margin
```dart
AppDimensions.paddingXSmall    // 4.0
AppDimensions.paddingSmall     // 8.0
AppDimensions.paddingMedium    // 16.0
AppDimensions.paddingLarge     // 24.0
AppDimensions.paddingXLarge    // 32.0
```

### Border Radius
```dart
AppDimensions.radiusSmall      // 8.0
AppDimensions.radiusMedium     // 12.0
AppDimensions.radiusLarge      // 16.0
AppDimensions.radiusXLarge     // 24.0
AppDimensions.radiusCircle     // 999.0
```

### Alturas
```dart
AppDimensions.buttonHeight         // 56.0
AppDimensions.buttonHeightSmall    // 40.0
AppDimensions.buttonHeightLarge    // 64.0
AppDimensions.inputHeight          // 56.0
```

### Iconos
```dart
AppDimensions.iconSizeSmall    // 16.0
AppDimensions.iconSizeMedium   // 24.0
AppDimensions.iconSizeLarge    // 32.0
AppDimensions.iconSizeXLarge   // 48.0
```

## 🚀 Uso

### Importar el tema
```dart
import 'package:farmguard/core/theme/theme.dart';
```

### Usar colores
```dart
Container(
  color: AppColors.primary,
  child: Text(
    'Hola',
    style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
  ),
)
```

### Usar dimensiones
```dart
Padding(
  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
  child: Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    ),
  ),
)
```

### Aplicar tema en la app
```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system,
)
```

## 🎯 Ejemplos

### Botón Personalizado
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    minimumSize: Size(double.infinity, AppDimensions.buttonHeight),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    ),
  ),
  child: Text('Botón', style: AppTextStyles.button),
)
```

### Card
```dart
Card(
  color: AppColors.surface,
  elevation: AppDimensions.cardElevation,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
  ),
  child: Padding(
    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
    child: Column(
      children: [
        Text('Título', style: AppTextStyles.h3),
        SizedBox(height: AppDimensions.marginSmall),
        Text('Descripción', style: AppTextStyles.bodyMedium),
      ],
    ),
  ),
)
```

### Input
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Ingresa tu email',
    prefixIcon: Icon(Icons.email, color: AppColors.primary),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    ),
    fillColor: AppColors.surface,
    filled: true,
  ),
)
```

## 🎨 Personalización

Para cambiar la paleta de colores, edita `app_colors.dart`:

```dart
static const Color primary = Color(0xFF2196F3);  // Cambiar a azul
```

Para cambiar tamaños de texto, edita `app_text_styles.dart`:

```dart
static const TextStyle h1 = TextStyle(
  fontSize: 36,  // Cambiar tamaño
  fontWeight: FontWeight.bold,
);
```

## 📱 Modo Oscuro

El tema oscuro está configurado pero actualmente no se usa. Para activarlo:

```dart
MaterialApp(
  themeMode: ThemeMode.dark,  // Fuerza modo oscuro
  // O
  themeMode: ThemeMode.system,  // Sigue el sistema
)
```

## ✅ Buenas Prácticas

1. **Siempre usa colores del sistema:**
   ```dart
   // ✅ Correcto
   color: AppColors.primary
   
   // ❌ Incorrecto
   color: Colors.green
   ```

2. **Usa dimensiones consistentes:**
   ```dart
   // ✅ Correcto
   padding: EdgeInsets.all(AppDimensions.paddingMedium)
   
   // ❌ Incorrecto
   padding: EdgeInsets.all(16)
   ```

3. **Usa estilos de texto predefinidos:**
   ```dart
   // ✅ Correcto
   Text('Título', style: AppTextStyles.h2)
   
   // ❌ Incorrecto
   Text('Título', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
   ```

4. **Personaliza copiando estilos:**
   ```dart
   Text(
     'Texto',
     style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
   )
   ```

## 🔄 Widgets que usan el tema

- `CustomTextField` - Campos de texto
- `AuthButton` - Botones de autenticación
- Todos los screens usan los colores del tema

## 📦 Extensiones Futuras

- [ ] Agregar tema oscuro completo
- [ ] Soporte para múltiples idiomas
- [ ] Animaciones y transiciones
- [ ] Iconos personalizados
- [ ] Ilustraciones SVG
