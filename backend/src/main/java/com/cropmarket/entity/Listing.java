package com.cropmarket.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "listings", indexes = {
    @Index(name = "idx_farmer_id", columnList = "farmer_id"),
    @Index(name = "idx_crop_id", columnList = "crop_id"),
    @Index(name = "idx_status", columnList = "status"),
    @Index(name = "idx_price", columnList = "price_per_gram"),
    @Index(name = "idx_created_at", columnList = "created_at")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Listing {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "farmer_id", nullable = false)
    private Long farmerId;
    
    @Column(name = "crop_id", nullable = false)
    private Long cropId;
    
    @Column(name = "quantity_grams", nullable = false)
    private BigDecimal quantityGrams;
    
    @Column(name = "original_quantity_grams", nullable = false)
    private BigDecimal originalQuantityGrams;
    
    @Column(name = "price_per_gram", nullable = false, precision = 10, scale = 4)
    private BigDecimal pricePerGram;
    
    @Column(name = "total_price", precision = 12, scale = 2)
    private BigDecimal totalPrice;
    
    private String location;
    
    private Double latitude;
    
    private Double longitude;
    
    @Column(name = "harvest_date")
    private LocalDateTime harvestDate;
    
    @Column(name = "expiry_date")
    private LocalDateTime expiryDate;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @ElementCollection
    @CollectionTable(name = "listing_images", joinColumns = @JoinColumn(name = "listing_id"))
    @Column(name = "image_url")
    private List<String> images;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ListingStatus status = ListingStatus.ACTIVE;
    
    @Column(name = "view_count")
    private Integer viewCount = 0;
    
    @Column(name = "order_count")
    private Integer orderCount = 0;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @Version
    private Integer version;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        originalQuantityGrams = quantityGrams;
        calculateTotalPrice();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
        calculateTotalPrice();
    }
    
    private void calculateTotalPrice() {
        if (quantityGrams != null && pricePerGram != null) {
            this.totalPrice = quantityGrams.multiply(pricePerGram);
        }
    }
    
    public void decrementQuantity(BigDecimal quantity) {
        this.quantityGrams = this.quantityGrams.subtract(quantity);
        if (this.quantityGrams.compareTo(BigDecimal.ZERO) <= 0) {
            this.status = ListingStatus.SOLD;
        }
        this.orderCount++;
    }
}

enum ListingStatus {
    ACTIVE, SOLD, EXPIRED, CANCELLED, DRAFT
}
