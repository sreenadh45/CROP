-- Create database
CREATE DATABASE IF NOT EXISTS crop_marketplace_prod 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE crop_marketplace_prod;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    address TEXT,
    profile_image VARCHAR(255),
    user_type ENUM('FARMER', 'CUSTOMER', 'ADMIN') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(255),
    reset_password_token VARCHAR(255),
    reset_password_expiry TIMESTAMP,
    last_login TIMESTAMP,
    failed_login_attempts INT DEFAULT 0,
    account_locked_until TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_user_type (user_type),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Crops table
CREATE TABLE IF NOT EXISTS crops (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    description TEXT,
    image_url VARCHAR(255),
    unit VARCHAR(20) DEFAULT 'gram',
    min_order_quantity INT DEFAULT 100,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_name (name),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listings table
CREATE TABLE IF NOT EXISTS listings (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    farmer_id BIGINT NOT NULL,
    crop_id BIGINT NOT NULL,
    quantity_grams DECIMAL(10,2) NOT NULL,
    original_quantity_grams DECIMAL(10,2) NOT NULL,
    price_per_gram DECIMAL(10,4) NOT NULL,
    total_price DECIMAL(12,2) GENERATED ALWAYS AS (quantity_grams * price_per_gram) STORED,
    location VARCHAR(255),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    harvest_date DATE,
    expiry_date DATE,
    description TEXT,
    status ENUM('ACTIVE', 'SOLD', 'EXPIRED', 'CANCELLED', 'DRAFT') DEFAULT 'ACTIVE',
    view_count INT DEFAULT 0,
    order_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    version INT DEFAULT 0,
    
    FOREIGN KEY (farmer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (crop_id) REFERENCES crops(id),
    
    INDEX idx_farmer_id (farmer_id),
    INDEX idx_crop_id (crop_id),
    INDEX idx_status (status),
    INDEX idx_price (price_per_gram),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listing images table
CREATE TABLE IF NOT EXISTS listing_images (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    listing_id BIGINT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    INDEX idx_listing_id (listing_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id BIGINT NOT NULL,
    listing_id BIGINT NOT NULL,
    farmer_id BIGINT NOT NULL,
    crop_id BIGINT NOT NULL,
    quantity_grams DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(10,4) NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    delivery_charge DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    grand_total DECIMAL(12,2) GENERATED ALWAYS AS (total_amount + delivery_charge + tax_amount) STORED,
    order_status ENUM('PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED', 'REFUNDED') DEFAULT 'PENDING',
    payment_status ENUM('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED', 'PARTIALLY_REFUNDED') DEFAULT 'PENDING',
    payment_id VARCHAR(100),
    payment_method VARCHAR(50),
    delivery_address TEXT,
    delivery_latitude DECIMAL(10,8),
    delivery_longitude DECIMAL(11,8),
    tracking_id VARCHAR(100),
    notes TEXT,
    cancellation_reason TEXT,
    cancelled_at TIMESTAMP,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP,
    shipped_at TIMESTAMP,
    delivered_at TIMESTAMP,
    expected_delivery_date DATE,
    
    FOREIGN KEY (customer_id) REFERENCES users(id),
    FOREIGN KEY (listing_id) REFERENCES listings(id),
    FOREIGN KEY (farmer_id) REFERENCES users(id),
    FOREIGN KEY (crop_id) REFERENCES crops(id),
    
    INDEX idx_customer_id (customer_id),
    INDEX idx_listing_id (listing_id),
    INDEX idx_farmer_id (farmer_id),
    INDEX idx_order_status (order_status),
    INDEX idx_payment_status (payment_status),
    INDEX idx_order_date (order_date),
    INDEX idx_order_number (order_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    payment_id VARCHAR(100) UNIQUE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),
    razorpay_order_id VARCHAR(100),
    razorpay_payment_id VARCHAR(100),
    razorpay_signature VARCHAR(255),
    payment_details JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_payment_id (payment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Reviews table
CREATE TABLE IF NOT EXISTS reviews (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT UNIQUE NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    farmer_reply TEXT,
    replied_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_rating (rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50),
    is_read BOOLEAN DEFAULT FALSE,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Audit logs table
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id BIGINT,
    old_value JSON,
    new_value JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create stored procedure for cleanup
DELIMITER //

CREATE PROCEDURE cleanup_expired_listings()
BEGIN
    UPDATE listings 
    SET status = 'EXPIRED' 
    WHERE expiry_date < NOW() 
    AND status = 'ACTIVE';
END //

CREATE PROCEDURE cleanup_old_notifications()
BEGIN
    DELETE FROM notifications 
    WHERE created_at < DATE_SUB(NOW(), INTERVAL 30 DAY) 
    AND is_read = TRUE;
END //

DELIMITER ;

-- Create event for scheduled cleanup
CREATE EVENT IF NOT EXISTS daily_cleanup
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    CALL cleanup_expired_listings();
    CALL cleanup_old_notifications();
END;

-- Insert default crops
INSERT INTO crops (name, category, description, is_available) VALUES
('Basmati Rice', 'Grains', 'Premium long-grain basmati rice with authentic aroma', TRUE),
('Wheat', 'Grains', 'High-quality wheat grains for flour', TRUE),
('Tomato', 'Vegetables', 'Fresh organic tomatoes', TRUE),
('Potato', 'Vegetables', 'Farm-fresh potatoes', TRUE),
('Onion', 'Vegetables', 'Red onions', TRUE),
('Mango', 'Fruits', 'Alphonso mangoes', TRUE),
('Apple', 'Fruits', 'Kashmiri apples', TRUE),
('Green Chilli', 'Spices', 'Fresh green chillies', TRUE),
('Turmeric', 'Spices', 'Fresh turmeric powder', TRUE),
('Coriander', 'Herbs', 'Fresh coriander leaves', TRUE);

-- Create admin user (password: Admin@123)
INSERT INTO users (email, password_hash, full_name, phone, user_type, is_verified, is_active) VALUES
('admin@cropmarketplace.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4.VTtYxYJqY.pRDO', 'System Admin', '9999999999', 'ADMIN', TRUE, TRUE);
