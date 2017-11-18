var assert = require("assert"),
    wcUtils = require("../utils/utils");

describe('Utils', function() {
  describe('EncryptDecrypt', function() {
    it('Should correctly parse strings for encryption and decryption.', function() {
      var input = "test_encryption_string";
      var enc = wcUtils.encrypt(input);
      var dec = wcUtils.decrypt(enc);
      assert.equal(input, dec);
    });
  });

  describe('EncryptDecryptObject', function() {
    it('Should also correctly deal with objects in JSON format.', function() {
      var input = {
        key: "value",
        anotherKey: {
          deepKey: "deepValue"
        }
      };
      var enc = wcUtils.encryptObject(input);
      var dec = wcUtils.decryptObject(enc);
      assert.deepEqual(input, dec);
    });

    it('Should get our config right with object decryption.', function() {
      var config = require("../config_enc");
      var dec = wcUtils.decryptObject(config);
      // Check some basic keys
      assert.equal(dec.page.applicationName, "WildcatConnect");
      assert.equal(dec.logglySubdomain, "wildcatconnect");
    });
  });

  describe('StringUtils', function() {
    it('Should properly remove all instances of a string from another.', function() {
      var input = "removedogalldogfromdogthisdogstringdog";
      var output = wcUtils.replaceAll(input, "dog", "");
      var expected = "removeallfromthisstring";
      assert.equal(output, expected);
    });

    it('Should properly remove all line breaks from a random string.', function() {
      var input = `Here
we
are.`;
      var output = wcUtils.removeLineBreaks(input);
      var expected = "Hereweare.";
      assert.equal(output, expected);
    });
  });

  describe('PasswordCreation', function() {
    it('Should allow a completely valid password.', function() {
      var input = "testPass123!";
      var output = wcUtils.validatePassword(input);
      assert(output.result);
      assert.equal(output.message, "Validated.");
    });

    it('Should prevent a user from making an empty password.', function() {
      var input = "";
      var output = wcUtils.validatePassword(input);
      assert(! output.result);
      assert.equal(output.message, "Password must be at least 8 characters long.");
    });

    it('Should prevent random spaces from occuring in password.', function() {
      var input = "password with space";
      var output = wcUtils.validatePassword(input);
      assert(! output.result);
      assert.equal(output.message, "Password cannot contain any spaces.");
    });
  });
});
