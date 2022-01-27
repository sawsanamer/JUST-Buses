import 'package:just_busses/helpers/database_methods.dart';
import 'package:validators/validators.dart' as validators;

class FormValidators {
  static String presenceValidator(var val,
      [String message = "This field can't be blank"]) {
    if (val.isEmpty) return message;
    return null;
  }

  static String emailValidator(var val,
      [String message = "This field should be a valid email"]) {
    if (!validators.isEmail(val)) return message;
    return null;
  }

  static String wordsCountValidator(String val, int count, [String message]) {
    String displayMessage =
        message ?? "This field should consist of $count words";
    if (val.isEmpty) return displayMessage;
    if (val.split(" ").length <= 1) return displayMessage;
    return null;
  }

  static String confirmationValidator(var val1, var val2,
      [String message = "The two values don't match"]) {
    if (val1 != val2) return message;
    return null;
  }

  static String lengthValidator(String val, int minLength, int maxLength,
      [String message]) {
    String displayMessage = message ??
        "This field's length should be between $minLength and $maxLength";
    if (!validators.isLength(val, minLength, maxLength)) return displayMessage;
    return null;
  }
}
