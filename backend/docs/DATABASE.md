# Database Documentation

## Tables

### 1. `profiles`
Stores additional user profile data.
- **id** (UUID, PK, References `auth.users.id`)
- **full_name** (Text)
- **phone** (Text)
- **business_name** (Text)

### 2. `product_categories`
- **id** (UUID, PK)
- **name** (Text, Unique)
- **description** (Text)

### 3. `products`
Stores tyres.
- **id** (UUID, PK)
- **category_id** (UUID, FK to `product_categories`)
- **brand**, **model** (Text)
- **width**, **aspect_ratio**, **rim_size** (Numeric > 0)
- **size_display** (Text)
- **tyre_type**, **condition** (Text)
- **purchase_price**, **selling_price** (Numeric(14,2) >= 0)
- **minimum_stock** (Numeric >= 0)

### 4. `customers`
- **id** (UUID, PK)
- **customer_code** (Text, Unique)
- **name**, **phone**, **address** (Text)

### 5. `customer_vehicles`
- **id** (UUID, PK)
- **customer_id** (UUID, FK to `customers` on delete cascade)
- **vehicle_number** (Text, Unique)
- **vehicle_type**, **make**, **model** (Text)

### 6. `suppliers`
- **id** (UUID, PK)
- **supplier_code** (Text, Unique)
- **name**, **phone**, **address** (Text)

### 7. `payment_methods`
- **id** (UUID, PK)
- **name**, **code** (Text, Unique)

### 8. `expense_categories`
- **id** (UUID, PK)
- **name** (Text, Unique)

## Constraints and Indexes
- Check constraints ensure prices and dimensions are positive.
- Timestamps (`created_at`, `updated_at`) are automatically managed via triggers.
- Indexes are added on frequently searched fields like `brand`, `model`, `size_display`, `name`, `phone`, and `customer_code`.
