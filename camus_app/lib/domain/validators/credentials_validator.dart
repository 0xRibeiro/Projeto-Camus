//

import 'package:camus_app/domain/dtos/credentials.dart';
import 'package:lucid_validation/lucid_validation.dart';

class CredentialsValidator extends LucidValidator<Credentials> {
  CredentialsValidator() {
    ruleFor((c) => c.email, key: 'email').notEmpty().validEmail();

    ruleFor((c) => c.password, key: 'password')
        .notEmpty()
        .minLength(6)
        .mustHaveUppercase()
        .mustHaveLowercase()
        .mustHaveNumber()
        .mustHaveSpecialCharacter();
  }
}
