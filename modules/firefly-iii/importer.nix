{...}: {
  # Firefly Data Importer (FIDI) configuration file

  # Where is Firefly III?
  #
  # 1) Make sure you ADD http:// or https://
  # 2) Make sure you REMOVE any trailing slash from the end of the URL.
  # 3) In case of Docker, refer to the internal IP of your Firefly III installation.
  #
  # Setting this value is not mandatory. But it is very useful.
  #
  # This variable can be set from a file if you append it with _FILE
  #
  FIREFLY_III_URL = "";

  #
  # Imagine Firefly III can be reached at "http://172.16.0.2:8082" (internal Docker network or something).
  # But you have a fancy URL: "https://personal-finances.bill.microsoft.com/"
  #
  # In those cases, you can overrule the URL so when the data importer links back to Firefly III, it uses the correct URL.
  #
  # 1) Make sure you ADD http:// or https://
  # 2) Make sure you REMOVE any trailing slash from the end of the URL.
  #
  # IF YOU SET THIS VALUE, YOU MUST ALSO SET THE FIREFLY_III_URL
  #
  # This variable can be set from a file if you append it with _FILE
  #
  VANITY_URL = "";

  #
  # Set your Firefly III Personal Access Token (OAuth)
  # You can create a Personal Access Token on the /profile page:
  # go to the OAuth tab, then Personal Access Token and "Create token".
  #
  # - Do not use the "command line token". That's the WRONG one.
  # - Do not use "APP_KEY" value from your Firefly III installation. That's the WRONG one.
  #
  # Setting this value is not mandatory. Instructions will follow if you omit this field.
  #
  # This variable can be set from a file if you append it with _FILE
  #
  FIREFLY_III_ACCESS_TOKEN = "";

  #
  # You can also use a public client ID. This is available in Firefly III 5.4.0-alpha.3 and higher.
  # This is a number (1, 2, 3). If you use the client ID, you can leave the access token empty and vice versa.
  #
  # This value is not mandatory to set. Instructions will follow if you omit this field.
  #
  # This variable can be set from a file if you append it with _FILE
  #
  FIREFLY_III_CLIENT_ID = "";

  #
  # Nordigen information.
  # The key and ID can be set from a file if you append it with _FILE
  #
  NORDIGEN_ID = "";
  NORDIGEN_KEY = "";
  NORDIGEN_SANDBOX = "false";

  #
  # Spectre information
  #
  # The ID and secret can be set from a file if you append it with _FILE
  SPECTRE_APP_ID = "";
  SPECTRE_SECRET = "";

  #
  # Use cache. No need to do this.
  #
  USE_CACHE = "false";

  #
  # If set to true, the data import will not complain about running into duplicates.
  # This will give you cleaner import mails if you run regular imports.
  #
  # This means that the data importer will not import duplicates, but it will not complain about them either.
  #
  # This setting has no influence on the settings in your configuration(.json).
  #
  # Of course, if something goes wrong *because* the transaction is a duplicate you will
  # NEVER know unless you start digging in your log files. So be careful with this.
  #
  IGNORE_DUPLICATE_ERRORS = "false";

  #
  # Auto import settings. Due to security constraints, you MUST enable each feature individually.
  # You must also set a secret. The secret is used for the web routes.
  #
  # The auto-import secret must be a string of at least 16 characters.
  # Visit this page for inspiration: https://www.random.org/passwords/?num = "1&len=16&format=html&rnd=new";
  #
  # Submit it using ?secret = "X";
  #
  # This variable can be set from a file if you append it with _FILE
  #
  AUTO_IMPORT_SECRET = "";

  #
  # Is the /autoimport even endpoint enabled?
  # By default it's disabled, and the secret alone will not enable it.
  #
  CAN_POST_AUTOIMPORT = "false";

  #
  # Is the /autoupload endpoint enabled?
  # By default it's disabled, and the secret alone will not enable it.
  #
  CAN_POST_FILES = "false";

  #
  # Import directory white list. You need to set this before the auto importer will accept a directory to import from.
  #
  # This variable can be set from a file if you append it with _FILE
  #
  IMPORT_DIR_ALLOWLIST = "";

  #
  # When you're running Firefly III under a (self-signed) certificate,
  # the data importer may have trouble verifying the TLS connection.
  #
  # You have a few options to make sure the data importer can connect
  # to Firefly III:
  # - 'true': will verify all certificates. The most secure option and the default.
  # - 'file.pem': refer to a file (you must provide it) to your custom root or intermediate certificates.
  # - 'false': will verify NO certificates. Not very secure.
  VERIFY_TLS_SECURITY = "true";

  #
  # If you want, you can set a directory here where the data importer will look for import configurations.
  # This is a separate setting from the /import directory that the auto-import uses.
  # Setting this variable isn't necessary. The default value is "storage/configurations".
  #
  # This variable can be set from a file if you append it with _FILE
  #
  JSON_CONFIGURATION_DIR = "";

  #
  # Time out when connecting with Firefly III.
  # π*10 seconds is usually fine.
  #
  CONNECTION_TIMEOUT = "31.41";

  # The following variables can be useful when debugging the application
  APP_ENV = "local";
  APP_DEBUG = "false";
  LOG_CHANNEL = "stack";

  #
  # If you turn this on, expect massive logs with lots of privacy sensitive data
  #
  LOG_RETURN_JSON = "false";

  # Log level. You can set this from least severe to most severe:
  # debug, info, notice, warning, error, critical, alert, emergency
  # If you set it to debug your logs will grow large, and fast. If you set it to emergency probably
  # nothing will get logged, ever.
  LOG_LEVEL = "debug";

  # TRUSTED_PROXIES is a useful variable when using Docker and/or a reverse proxy.
  # Set it to ** and reverse proxies work just fine.
  TRUSTED_PROXIES = "";

  #
  # Time zone
  #
  TZ = "Europe/Amsterdam";

  #
  # Use ASSET_URL when you're running the data importer in a sub-directory.
  #
  ASSET_URL = "";

  #
  # Email settings.
  # The data importer can send you a message with all errors, warnings and messages
  # after a successful import. This is disabled by default
  #
  ENABLE_MAIL_REPORT = "false";

  #
  # Force Firefly III URL to be secure?
  #
  #
  EXPECT_SECURE_URL = "false";

  # If enabled, define which mailer you want to use.
  # Options include: smtp, mailgun, postmark, sendmail, log, array
  # Amazon SES is not supported.
  # log  = " drop mails in the logs instead of sending them";
  # array  = " debug mailer that does nothing.";
  MAIL_MAILER = "";

  # where to send the report?
  MAIL_DESTINATION = "noreply@example.com";

  # other mail settings
  # These variables can be set from a file if you append it with _FILE
  MAIL_FROM_ADDRESS = "noreply@example.com";
  MAIL_HOST = "smtp.mailtrap.io";
  MAIL_PORT = "2525";
  MAIL_USERNAME = "username";
  MAIL_PASSWORD = "password";
  MAIL_ENCRYPTION = "null";

  # Extra settings depending on your mail configuration above.
  # These variables can be set from a file if you append it with _FILE
  MAILGUN_DOMAIN = "";
  MAILGUN_SECRET = "";
  MAILGUN_ENDPOINT = "";
  POSTMARK_TOKEN = "";

  #
  # You probably won't need to change these settings.
  #
  BROADCAST_DRIVER = "log";
  CACHE_DRIVER = "file";
  QUEUE_CONNECTION = "sync";
  SESSION_DRIVER = "file";
  SESSION_LIFETIME = "120";
  IS_EXTERNAL = "false";

  REDIS_HOST = "127.0.0.1";
  REDIS_PASSWORD = "null";
  REDIS_PORT = "6379";

  # always use quotes
  REDIS_DB = "\"0\"";
  REDIS_CACHE_DB = "\"1\"";

  # The only tracker supported is Matomo.
  # This is used on the public instance over at https://data-importer.firefly-iii.org
  TRACKER_SITE_ID = "";
  TRACKER_URL = "";

  APP_NAME = "DataImporter";

  #
  # The APP_URL environment variable is NOT used anywhere.
  # Don't bother setting it to fix your reverse proxy problems. It won't help.
  # Don't open issues telling me it doesn't help because it's not supposed to.
  # Laravel uses this to generate links on the command line, which is a feature the data importer does not use.
  #
  APP_URL = "http://localhost";
}
