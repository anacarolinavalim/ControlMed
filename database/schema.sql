CREATE DATABASE IF NOT EXISTS medcontrol CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medcontrol;

CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('user','admin') NOT NULL DEFAULT 'user',
  timezone VARCHAR(64) NOT NULL DEFAULT 'America/Sao_Paulo',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE medications (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(160) NOT NULL,
  active_ingredient VARCHAR(160) NULL,
  dosage VARCHAR(80) NULL,
  presentation ENUM('comprimido','capsula','gotas','liquido','injecao','pomada','outro') NOT NULL DEFAULT 'comprimido',
  unit VARCHAR(30) NOT NULL DEFAULT 'unidade',
  quantity DECIMAL(10,2) NOT NULL DEFAULT 0,
  minimum_quantity DECIMAL(10,2) NOT NULL DEFAULT 5,
  expiry_date DATE NULL,
  start_date DATE NULL,
  end_date DATE NULL,
  frequency VARCHAR(80) NULL,
  dose_quantity DECIMAL(10,2) NOT NULL DEFAULT 1,
  notes TEXT NULL,
  photo_url VARCHAR(500) NULL,
  active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_med_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_med_user_active (user_id, active), INDEX idx_med_expiry (user_id, expiry_date)
) ENGINE=InnoDB;

CREATE TABLE medication_schedules (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  medication_id BIGINT UNSIGNED NOT NULL,
  time_of_day TIME NOT NULL,
  dose_quantity DECIMAL(10,2) NOT NULL DEFAULT 1,
  days_of_week JSON NULL,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  CONSTRAINT fk_schedule_med FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE,
  INDEX idx_schedule_time (time_of_day, enabled)
) ENGINE=InnoDB;

CREATE TABLE medication_administrations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  medication_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  scheduled_for DATETIME NOT NULL,
  administered_at DATETIME NULL,
  status ENUM('administered','missed','skipped') NOT NULL,
  dose_quantity DECIMAL(10,2) NOT NULL,
  notes VARCHAR(500) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_admin_med FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE,
  CONSTRAINT fk_admin_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY uq_admin_schedule (medication_id, scheduled_for), INDEX idx_admin_user_date (user_id, scheduled_for)
) ENGINE=InnoDB;

CREATE TABLE stock_movements (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  medication_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  type ENUM('initial','consumption','purchase','adjustment','discard') NOT NULL,
  quantity DECIMAL(10,2) NOT NULL,
  reason VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_stock_med FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE,
  CONSTRAINT fk_stock_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_stock_user_date (user_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE medication_stock (
  medication_id BIGINT UNSIGNED PRIMARY KEY,
  quantity DECIMAL(10,2) NOT NULL DEFAULT 0,
  minimum_quantity DECIMAL(10,2) NOT NULL DEFAULT 5,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_stock_snapshot_med FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE medication_purchases (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  medication_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  purchased_at DATE NOT NULL,
  quantity DECIMAL(10,2) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  pharmacy VARCHAR(180) NULL,
  notes VARCHAR(500) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_purchase_med FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE,
  CONSTRAINT fk_purchase_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_purchase_user_date (user_id, purchased_at)
) ENGINE=InnoDB;

CREATE TABLE medication_expenses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  purchase_id BIGINT UNSIGNED NOT NULL,
  medication_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  spent_at DATE NOT NULL,
  CONSTRAINT fk_exp_purchase FOREIGN KEY (purchase_id) REFERENCES medication_purchases(id) ON DELETE CASCADE,
  CONSTRAINT fk_exp_med FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE,
  CONSTRAINT fk_exp_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_exp_user_date (user_id, spent_at)
) ENGINE=InnoDB;

CREATE TABLE medication_alerts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  medication_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  type ENUM('low_stock','expiry','treatment_end') NOT NULL,
  status ENUM('open','resolved','dismissed') NOT NULL DEFAULT 'open',
  message VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  resolved_at DATETIME NULL,
  CONSTRAINT fk_alert_med FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE,
  CONSTRAINT fk_alert_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_alert_user_status (user_id, status)
) ENGINE=InnoDB;

CREATE TABLE push_subscriptions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  device_label VARCHAR(120) NULL,
  endpoint TEXT NOT NULL,
  p256dh VARCHAR(255) NOT NULL,
  auth VARCHAR(255) NOT NULL,
  content_encoding VARCHAR(40) NOT NULL DEFAULT 'aes128gcm',
  last_seen_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_push_endpoint (endpoint(190)), INDEX idx_push_user (user_id),
  CONSTRAINT fk_push_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE notifications (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  created_by BIGINT UNSIGNED NULL,
  title VARCHAR(160) NOT NULL,
  body VARCHAR(500) NOT NULL,
  category ENUM('important','update','maintenance','announcement','reminder') NOT NULL DEFAULT 'announcement',
  url VARCHAR(500) NULL,
  scheduled_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notif_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_notif_schedule (scheduled_at)
) ENGINE=InnoDB;

CREATE TABLE notification_recipients (
  notification_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (notification_id, user_id),
  CONSTRAINT fk_rec_notif FOREIGN KEY (notification_id) REFERENCES notifications(id) ON DELETE CASCADE,
  CONSTRAINT fk_rec_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE notification_preferences (
  user_id BIGINT UNSIGNED PRIMARY KEY,
  push_enabled TINYINT(1) NOT NULL DEFAULT 0,
  medicine_times TINYINT(1) NOT NULL DEFAULT 1,
  low_stock TINYINT(1) NOT NULL DEFAULT 1,
  expiry TINYINT(1) NOT NULL DEFAULT 1,
  announcements TINYINT(1) NOT NULL DEFAULT 1,
  CONSTRAINT fk_pref_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE notification_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  notification_id BIGINT UNSIGNED NULL,
  subscription_id BIGINT UNSIGNED NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  status ENUM('queued','sent','failed','invalid') NOT NULL,
  response_code SMALLINT NULL,
  error_message TEXT NULL,
  sent_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_log_notif FOREIGN KEY (notification_id) REFERENCES notifications(id) ON DELETE SET NULL,
  CONSTRAINT fk_log_sub FOREIGN KEY (subscription_id) REFERENCES push_subscriptions(id) ON DELETE SET NULL,
  CONSTRAINT fk_log_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_log_status_date (status, created_at)
) ENGINE=InnoDB;

CREATE TABLE notification_queue (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  notification_id BIGINT UNSIGNED NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  kind VARCHAR(40) NOT NULL,
  payload JSON NOT NULL,
  available_at DATETIME NOT NULL,
  processed_at DATETIME NULL,
  attempts TINYINT UNSIGNED NOT NULL DEFAULT 0,
  last_error TEXT NULL,
  CONSTRAINT fk_queue_notif FOREIGN KEY (notification_id) REFERENCES notifications(id) ON DELETE CASCADE,
  CONSTRAINT fk_queue_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_queue_ready (processed_at, available_at)
) ENGINE=InnoDB;

CREATE TABLE system_settings (
  setting_key VARCHAR(100) PRIMARY KEY,
  setting_value TEXT NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
