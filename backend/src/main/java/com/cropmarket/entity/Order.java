package com.cropmarket.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "orders", indexes = {
    @Index(name = "idx_customer_id", columnList = "customer_id"),
    @Index(name = "idx_listing_id", columnList = "listing_id"),
    @Index(name = "idx_order_status", columnList = "order_status"),
    @Index(name = "idx_payment_status", columnList = "payment_status"),
    @Index(name = "idx_order_date", columnList = "order_date")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Order {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "order_number", unique = true, nullable = false)
    private String orderNumber;
    
    @Column(name = "customer_id", nullable = false)
    private Long customerId;
    
    @Column(name = "listing_id", nullable = false)
    private Long listingId;
    
    @Column(name = "farmer_id", nullable = false)
    private Long farmerId;
    
    @Column(name = "crop_id", nullable = false)
    private Long cropId;
    
    @Column(name = "quantity_grams", nullable = false)
    private BigDecimal quantityGrams;
    
    @Column(name = "unit_price", nullable = false, precision = 10, scale = 4)
    private BigDecimal unitPrice;
    
    @Column(name = "total_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal totalAmount;
    
    @Column(name = "delivery_charge")
    private BigDecimal deliveryCharge = BigDecimal.ZERO;
    
    @Column(name = "tax_amount")
    private BigDecimal taxAmount = BigDecimal.ZERO;
    
    @Column(name = "grand_total", precision = 12, scale = 2)
    private BigDecimal grandTotal;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "order_status", nullable = false)
    private OrderStatus orderStatus = OrderStatus.PENDING;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "payment_status", nullable = false)
    private PaymentStatus paymentStatus = PaymentStatus.PENDING;
    
    @Column(name = "payment_id")
    private String paymentId;
    
    @Column(name = "payment_method")
    private String paymentMethod;
    
    @Column(name = "delivery_address", columnDefinition = "TEXT")
    private String deliveryAddress;
    
    @Column(name = "delivery_latitude")
    private Double deliveryLatitude;
    
    @Column(name = "delivery_longitude")
    private Double deliveryLongitude;
    
    @Column(name = "tracking_id")
    private String trackingId;
    
    @Column(columnDefinition = "TEXT")
    private String notes;
    
    @Column(name = "cancellation_reason")
    private String cancellationReason;
    
    @Column(name = "cancelled_at")
    private LocalDateTime cancelledAt;
    
    @Column(name = "order_date")
    private LocalDateTime orderDate;
    
    @Column(name = "confirmed_at")
    private LocalDateTime confirmedAt;
    
    @Column(name = "shipped_at")
    private LocalDateTime shippedAt;
    
    @Column(name = "delivered_at")
    private LocalDateTime deliveredAt;
    
    @Column(name = "expected_delivery_date")
    private LocalDateTime expectedDeliveryDate;
    
    @PrePersist
    protected void onCreate() {
        orderDate = LocalDateTime.now();
        orderNumber = generateOrderNumber();
        calculateGrandTotal();
    }
    
    private String generateOrderNumber() {
        return "ORD" + System.currentTimeMillis() + String.format("%04d", (int)(Math.random() * 10000));
    }
    
    private void calculateGrandTotal() {
        this.grandTotal = totalAmount.add(deliveryCharge).add(taxAmount);
    }
}

enum OrderStatus {
    PENDING, CONFIRMED, PROCESSING, SHIPPED, OUT_FOR_DELIVERY, DELIVERED, CANCELLED, REFUNDED
}

enum PaymentStatus {
    PENDING, COMPLETED, FAILED, REFUNDED, PARTIALLY_REFUNDED
}
