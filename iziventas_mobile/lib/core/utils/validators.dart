class Validators {
  // Validador de correo electrónico
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es requerido';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Ingrese un correo electrónico válido';
    }
    return null;
  }

  // Validador de contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    // Validaciones adicionales de complejidad
    if (!_hasUppercase(value)) {
      return 'Debe contener al menos una letra mayúscula';
    }
    if (!_hasLowercase(value)) {
      return 'Debe contener al menos una letra minúscula';
    }
    if (!_hasNumber(value)) {
      return 'Debe contener al menos un número';
    }
    return null;
  }

  // Validador de nombre
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  // Validador de precio
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'El precio es requerido';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Ingrese un precio válido';
    }
    if (price <= 0) {
      return 'El precio debe ser mayor a cero';
    }
    return null;
  }

  // Validador de stock
  static String? validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'El stock es requerido';
    }
    final stock = int.tryParse(value);
    if (stock == null) {
      return 'Ingrese un número válido';
    }
    if (stock < 0) {
      return 'El stock no puede ser negativo';
    }
    return null;
  }

  // Método para validar SKU
  static String? validateSku(String? value) {
    if (value == null || value.isEmpty) {
      return 'El SKU es requerido';
    }
    if (value.length < 3) {
      return 'El SKU debe tener al menos 3 caracteres';
    }
    return null;
  }

  // Helpers internos
  static bool _hasUppercase(String value) {
    return value.contains(RegExp(r'[A-Z]'));
  }

  static bool _hasLowercase(String value) {
    return value.contains(RegExp(r'[a-z]'));
  }

  static bool _hasNumber(String value) {
    return value.contains(RegExp(r'[0-9]'));
  }
}