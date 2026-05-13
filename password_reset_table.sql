-- ============================================================
-- PASSWORD RESET TOKENS TABLE
-- Add this to your MySQL database to enable forgot password feature
-- ============================================================

CREATE TABLE IF NOT EXISTS `password_reset_tokens` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `email`      VARCHAR(191)    NOT NULL,
  `token`      VARCHAR(100)    NOT NULL UNIQUE,
  `otp_code`   VARCHAR(10)     NOT NULL,
  `expires_at` TIMESTAMP       NOT NULL,
  `used`       BOOLEAN         DEFAULT FALSE,
  `created_at` TIMESTAMP       NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP       NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `password_reset_tokens_email_index` (`email`),
  KEY `password_reset_tokens_token_index` (`token`),
  KEY `password_reset_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
