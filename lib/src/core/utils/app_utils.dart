import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AppUtils {
  // Formatação de datas
  static String formatDate(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Formatação de valores monetários
  static String formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  // Validações
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    // Remove caracteres especiais
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length >= 10 && cleanPhone.length <= 11;
  }

  // Validação específica para telefones brasileiros
  static bool isValidBrazilianPhone(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Deve ter 10 ou 11 dígitos (com DDD)
    if (cleanPhone.length < 10 || cleanPhone.length > 11) return false;
    
    // Verificar se o DDD é válido (11 a 99)
    if (cleanPhone.length >= 2) {
      int ddd = int.tryParse(cleanPhone.substring(0, 2)) ?? 0;
      if (ddd < 11 || ddd > 99) return false;
    }
    
    return true;
  }

  static bool isValidCPF(String cpf) {
    // Remove caracteres especiais
    String cleanCPF = cpf.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanCPF.length != 11) return false;
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cleanCPF)) return false;
    
    // Validação do CPF
    List<int> digits = cleanCPF.split('').map(int.parse).toList();
    
    // Primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += digits[i] * (10 - i);
    }
    int firstCheck = (sum * 10) % 11;
    if (firstCheck == 10) firstCheck = 0;
    
    if (digits[9] != firstCheck) return false;
    
    // Segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += digits[i] * (11 - i);
    }
    int secondCheck = (sum * 10) % 11;
    if (secondCheck == 10) secondCheck = 0;
    
    return digits[10] == secondCheck;
  }

  // Formatação de texto
  static String formatPhone(String phone) {
    String clean = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (clean.length <= 2) {
      return clean;
    } else if (clean.length <= 6) {
      return '(${clean.substring(0, 2)}) ${clean.substring(2)}';
    } else if (clean.length <= 10) {
      return '(${clean.substring(0, 2)}) ${clean.substring(2, 6)}-${clean.substring(6)}';
    } else if (clean.length == 11) {
      return '(${clean.substring(0, 2)}) ${clean.substring(2, 7)}-${clean.substring(7)}';
    }
    
    return phone; // Se for muito longo, retorna original
  }

  // Remover formatação do telefone
  static String cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  static String formatCPF(String cpf) {
    String clean = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (clean.length == 11) {
      return '${clean.substring(0, 3)}.${clean.substring(3, 6)}.${clean.substring(6, 9)}-${clean.substring(9)}';
    }
    return cpf;
  }

  // Utilitários de UI
  static void hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  static void showKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  // Debounce para evitar múltiplos cliques
  static bool _isDebouncing = false;
  
  static void debounce(Function() action, {Duration delay = const Duration(milliseconds: 500)}) {
    if (_isDebouncing) return;
    _isDebouncing = true;
    action();
    Future.delayed(delay, () => _isDebouncing = false);
  }
}