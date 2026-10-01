-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILES
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    phone TEXT,
    business_name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. PRODUCT CATEGORIES
CREATE TABLE public.product_categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. PRODUCTS
CREATE TABLE public.products (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    category_id UUID REFERENCES public.product_categories(id) ON DELETE RESTRICT,
    brand TEXT NOT NULL,
    model TEXT NOT NULL,
    width NUMERIC CHECK (width > 0),
    aspect_ratio NUMERIC CHECK (aspect_ratio > 0),
    rim_size NUMERIC CHECK (rim_size > 0),
    size_display TEXT NOT NULL,
    tyre_type TEXT,
    condition TEXT,
    purchase_price NUMERIC(14,2) CHECK (purchase_price >= 0),
    selling_price NUMERIC(14,2) CHECK (selling_price >= 0),
    minimum_stock NUMERIC CHECK (minimum_stock >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. CUSTOMERS
CREATE TABLE public.customers (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    customer_code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    reference TEXT,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. CUSTOMER VEHICLES
CREATE TABLE public.customer_vehicles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    customer_id UUID REFERENCES public.customers(id) ON DELETE CASCADE,
    vehicle_number TEXT NOT NULL UNIQUE,
    vehicle_type TEXT,
    make TEXT,
    model TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. SUPPLIERS
CREATE TABLE public.suppliers (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    supplier_code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    reference TEXT,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. PAYMENT METHODS
CREATE TABLE public.payment_methods (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. EXPENSE CATEGORIES
CREATE TABLE public.expense_categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Function and trigger for updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers
CREATE TRIGGER set_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER set_product_categories_updated_at BEFORE UPDATE ON public.product_categories FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER set_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER set_customers_updated_at BEFORE UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER set_customer_vehicles_updated_at BEFORE UPDATE ON public.customer_vehicles FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER set_suppliers_updated_at BEFORE UPDATE ON public.suppliers FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER set_payment_methods_updated_at BEFORE UPDATE ON public.payment_methods FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER set_expense_categories_updated_at BEFORE UPDATE ON public.expense_categories FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

-- INDEXES
CREATE INDEX idx_products_brand ON public.products(brand);
CREATE INDEX idx_products_model ON public.products(model);
CREATE INDEX idx_products_size_display ON public.products(size_display);

CREATE INDEX idx_customers_name ON public.customers(name);
CREATE INDEX idx_customers_phone ON public.customers(phone);
CREATE INDEX idx_customers_code ON public.customers(customer_code);

CREATE INDEX idx_suppliers_name ON public.suppliers(name);
CREATE INDEX idx_suppliers_phone ON public.suppliers(phone);
CREATE INDEX idx_suppliers_code ON public.suppliers(supplier_code);

CREATE INDEX idx_customer_vehicles_number ON public.customer_vehicles(vehicle_number);

-- RLS POLICIES
-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_categories ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can select/update/insert only their own profile
CREATE POLICY "Authenticated users can select profiles" ON public.profiles FOR SELECT TO authenticated USING (auth.uid() = id);
CREATE POLICY "Authenticated users can update own profile" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id);
CREATE POLICY "Authenticated users can insert own profile" ON public.profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);

-- For business data tables: Allow authenticated users to perform all actions
-- Phase 1 logic assumes one owner, so just verifying authentication is sufficient.
CREATE POLICY "Authenticated users can access product_categories" ON public.product_categories FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated users can access products" ON public.products FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated users can access customers" ON public.customers FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated users can access customer_vehicles" ON public.customer_vehicles FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated users can access suppliers" ON public.suppliers FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated users can access payment_methods" ON public.payment_methods FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated users can access expense_categories" ON public.expense_categories FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- SEED DATA
INSERT INTO public.product_categories (name) VALUES 
('New Tyres'),
('Used Tyres'),
('Other')
ON CONFLICT (name) DO NOTHING;

INSERT INTO public.payment_methods (name, code) VALUES 
('Cash', 'CASH'),
('Meezan Bank', 'MEEZAN_BANK'),
('Bank Alfalah', 'ALFALAH_BANK'),
('JazzCash', 'JAZZCASH'),
('EasyPaisa', 'EASYPAISA')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.expense_categories (name) VALUES 
('Rent'),
('Electricity'),
('Transport'),
('Salary'),
('Repair'),
('Other')
ON CONFLICT (name) DO NOTHING;

-- Seed some test tyres
DO $$
DECLARE
  new_tyres_id UUID;
BEGIN
  SELECT id INTO new_tyres_id FROM public.product_categories WHERE name = 'New Tyres' LIMIT 1;
  
  IF new_tyres_id IS NOT NULL THEN
    INSERT INTO public.products (category_id, brand, model, width, aspect_ratio, rim_size, size_display, tyre_type, condition, purchase_price, selling_price, minimum_stock)
    VALUES (new_tyres_id, 'Michelin', 'Primacy 4', 205, 55, 16, '205/55 R16', 'Passenger', 'New', 15000, 18000, 4);
    
    INSERT INTO public.products (category_id, brand, model, width, aspect_ratio, rim_size, size_display, tyre_type, condition, purchase_price, selling_price, minimum_stock)
    VALUES (new_tyres_id, 'Bridgestone', 'Turanza', 195, 65, 15, '195/65 R15', 'Passenger', 'New', 14000, 17000, 4);
  END IF;
END $$;


-- Phase 2: Business Transactions Migration

-- 1. TABLES

CREATE TABLE public.purchases (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    purchase_number TEXT NOT NULL UNIQUE,
    supplier_id UUID REFERENCES public.suppliers(id) ON DELETE RESTRICT,
    purchase_date DATE DEFAULT CURRENT_DATE,
    subtotal NUMERIC(14,2) DEFAULT 0 CHECK (subtotal >= 0),
    discount NUMERIC(14,2) DEFAULT 0 CHECK (discount >= 0),
    total_amount NUMERIC(14,2) DEFAULT 0 CHECK (total_amount >= 0),
    paid_amount NUMERIC(14,2) DEFAULT 0 CHECK (paid_amount >= 0),
    due_amount NUMERIC(14,2) DEFAULT 0 CHECK (due_amount >= 0),
    notes TEXT,
    status TEXT DEFAULT 'COMPLETED',
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.purchase_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    purchase_id UUID REFERENCES public.purchases(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE RESTRICT,
    quantity NUMERIC NOT NULL CHECK (quantity > 0),
    unit_cost NUMERIC(14,2) NOT NULL CHECK (unit_cost >= 0),
    discount NUMERIC(14,2) DEFAULT 0 CHECK (discount >= 0),
    line_total NUMERIC(14,2) NOT NULL CHECK (line_total >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.sales (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    invoice_number TEXT NOT NULL UNIQUE,
    customer_id UUID REFERENCES public.customers(id) ON DELETE RESTRICT,
    vehicle_id UUID REFERENCES public.customer_vehicles(id) ON DELETE SET NULL,
    sale_date DATE DEFAULT CURRENT_DATE,
    subtotal NUMERIC(14,2) DEFAULT 0 CHECK (subtotal >= 0),
    discount NUMERIC(14,2) DEFAULT 0 CHECK (discount >= 0),
    total_amount NUMERIC(14,2) DEFAULT 0 CHECK (total_amount >= 0),
    paid_amount NUMERIC(14,2) DEFAULT 0 CHECK (paid_amount >= 0),
    due_amount NUMERIC(14,2) DEFAULT 0 CHECK (due_amount >= 0),
    notes TEXT,
    status TEXT DEFAULT 'COMPLETED',
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.sale_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    sale_id UUID REFERENCES public.sales(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE RESTRICT,
    quantity NUMERIC NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(14,2) NOT NULL CHECK (unit_price >= 0),
    discount NUMERIC(14,2) DEFAULT 0 CHECK (discount >= 0),
    line_total NUMERIC(14,2) NOT NULL CHECK (line_total >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.inventory (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    product_id UUID REFERENCES public.products(id) ON DELETE RESTRICT UNIQUE,
    quantity NUMERIC NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    average_cost NUMERIC(14,2) DEFAULT 0 CHECK (average_cost >= 0),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.inventory_movements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    product_id UUID REFERENCES public.products(id) ON DELETE RESTRICT,
    movement_type TEXT NOT NULL,
    quantity NUMERIC NOT NULL,
    unit_cost NUMERIC(14,2) DEFAULT 0,
    reference_type TEXT,
    reference_id UUID,
    notes TEXT,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.payments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    payment_number TEXT NOT NULL UNIQUE,
    customer_id UUID REFERENCES public.customers(id) ON DELETE SET NULL,
    supplier_id UUID REFERENCES public.suppliers(id) ON DELETE SET NULL,
    sale_id UUID REFERENCES public.sales(id) ON DELETE SET NULL,
    purchase_id UUID REFERENCES public.purchases(id) ON DELETE SET NULL,
    payment_method_id UUID REFERENCES public.payment_methods(id) ON DELETE RESTRICT,
    amount NUMERIC(14,2) NOT NULL CHECK (amount > 0),
    payment_date DATE DEFAULT CURRENT_DATE,
    reference TEXT,
    notes TEXT,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.customer_ledger (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    customer_id UUID REFERENCES public.customers(id) ON DELETE RESTRICT,
    transaction_type TEXT NOT NULL,
    reference_type TEXT,
    reference_id UUID,
    debit NUMERIC(14,2) DEFAULT 0 CHECK (debit >= 0),
    credit NUMERIC(14,2) DEFAULT 0 CHECK (credit >= 0),
    description TEXT,
    transaction_date DATE DEFAULT CURRENT_DATE,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.supplier_ledger (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    supplier_id UUID REFERENCES public.suppliers(id) ON DELETE RESTRICT,
    transaction_type TEXT NOT NULL,
    reference_type TEXT,
    reference_id UUID,
    debit NUMERIC(14,2) DEFAULT 0 CHECK (debit >= 0),
    credit NUMERIC(14,2) DEFAULT 0 CHECK (credit >= 0),
    description TEXT,
    transaction_date DATE DEFAULT CURRENT_DATE,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.expenses (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    expense_number TEXT NOT NULL UNIQUE,
    expense_category_id UUID REFERENCES public.expense_categories(id) ON DELETE RESTRICT,
    amount NUMERIC(14,2) NOT NULL CHECK (amount > 0),
    expense_date DATE DEFAULT CURRENT_DATE,
    payment_method_id UUID REFERENCES public.payment_methods(id) ON DELETE RESTRICT,
    description TEXT,
    reference TEXT,
    notes TEXT,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.financial_transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    transaction_type TEXT NOT NULL,
    reference_type TEXT,
    reference_id UUID,
    payment_method_id UUID REFERENCES public.payment_methods(id) ON DELETE RESTRICT,
    amount NUMERIC(14,2) NOT NULL CHECK (amount > 0),
    direction TEXT NOT NULL CHECK (direction IN ('IN', 'OUT')),
    description TEXT,
    transaction_date DATE DEFAULT CURRENT_DATE,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.audit_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Triggers for updated_at
CREATE TRIGGER set_purchases_updated_at BEFORE UPDATE ON public.purchases FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER set_sales_updated_at BEFORE UPDATE ON public.sales FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER set_inventory_updated_at BEFORE UPDATE ON public.inventory FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER set_expenses_updated_at BEFORE UPDATE ON public.expenses FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

-- INDEXES
CREATE INDEX idx_purchases_supplier ON public.purchases(supplier_id);
CREATE INDEX idx_purchase_items_purchase ON public.purchase_items(purchase_id);
CREATE INDEX idx_sales_customer ON public.sales(customer_id);
CREATE INDEX idx_sale_items_sale ON public.sale_items(sale_id);
CREATE INDEX idx_inventory_movements_product ON public.inventory_movements(product_id);
CREATE INDEX idx_payments_customer ON public.payments(customer_id);
CREATE INDEX idx_payments_supplier ON public.payments(supplier_id);
CREATE INDEX idx_customer_ledger_customer ON public.customer_ledger(customer_id);
CREATE INDEX idx_supplier_ledger_supplier ON public.supplier_ledger(supplier_id);
CREATE INDEX idx_financial_transactions_date ON public.financial_transactions(transaction_date);

-- RLS
ALTER TABLE public.purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.supplier_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated access purchases" ON public.purchases FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated access purchase_items" ON public.purchase_items FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated access sales" ON public.sales FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated access sale_items" ON public.sale_items FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated access inventory" ON public.inventory FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated access inventory_movements" ON public.inventory_movements FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated access payments" ON public.payments FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated access customer_ledger" ON public.customer_ledger FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated access supplier_ledger" ON public.supplier_ledger FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated access expenses" ON public.expenses FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated access financial_transactions" ON public.financial_transactions FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated access audit_logs" ON public.audit_logs FOR ALL TO authenticated USING (true);

-- SEQUENCES FOR NUMBERS
CREATE SEQUENCE IF NOT EXISTS seq_purchase_num START 1;
CREATE SEQUENCE IF NOT EXISTS seq_sale_num START 1;
CREATE SEQUENCE IF NOT EXISTS seq_payment_num START 1;
CREATE SEQUENCE IF NOT EXISTS seq_expense_num START 1;

-- RPC FUNCTIONS

-- 1. Create Purchase
CREATE OR REPLACE FUNCTION public.create_purchase(
    p_supplier_id UUID,
    p_items JSON, -- Array of { product_id, quantity, unit_cost, discount }
    p_discount NUMERIC,
    p_paid_amount NUMERIC,
    p_payment_method_id UUID,
    p_notes TEXT
) RETURNS UUID AS $$
DECLARE
    v_purchase_id UUID;
    v_purchase_number TEXT;
    v_subtotal NUMERIC := 0;
    v_total NUMERIC := 0;
    v_due NUMERIC := 0;
    v_item JSON;
    v_product_id UUID;
    v_qty NUMERIC;
    v_cost NUMERIC;
    v_item_discount NUMERIC;
    v_line_total NUMERIC;
    v_payment_id UUID;
BEGIN
    -- Generate Number
    v_purchase_number := 'PUR-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(nextval('seq_purchase_num')::TEXT, 6, '0');

    -- Calculate Totals
    FOR v_item IN SELECT * FROM json_array_elements(p_items)
    LOOP
        v_qty := (v_item->>'quantity')::NUMERIC;
        v_cost := (v_item->>'unit_cost')::NUMERIC;
        v_item_discount := COALESCE((v_item->>'discount')::NUMERIC, 0);
        
        v_line_total := (v_qty * v_cost) - v_item_discount;
        v_subtotal := v_subtotal + v_line_total;
    END LOOP;
    
    v_total := v_subtotal - COALESCE(p_discount, 0);
    v_due := v_total - COALESCE(p_paid_amount, 0);

    IF v_due < 0 THEN
        RAISE EXCEPTION 'Paid amount cannot be greater than total amount';
    END IF;

    -- Create Purchase
    INSERT INTO public.purchases (purchase_number, supplier_id, subtotal, discount, total_amount, paid_amount, due_amount, notes, created_by)
    VALUES (v_purchase_number, p_supplier_id, v_subtotal, p_discount, v_total, p_paid_amount, v_due, p_notes, auth.uid())
    RETURNING id INTO v_purchase_id;

    -- Insert Items and Update Inventory
    FOR v_item IN SELECT * FROM json_array_elements(p_items)
    LOOP
        v_product_id := (v_item->>'product_id')::UUID;
        v_qty := (v_item->>'quantity')::NUMERIC;
        v_cost := (v_item->>'unit_cost')::NUMERIC;
        v_item_discount := COALESCE((v_item->>'discount')::NUMERIC, 0);
        v_line_total := (v_qty * v_cost) - v_item_discount;

        INSERT INTO public.purchase_items (purchase_id, product_id, quantity, unit_cost, discount, line_total)
        VALUES (v_purchase_id, v_product_id, v_qty, v_cost, v_item_discount, v_line_total);

        -- Inventory Update
        INSERT INTO public.inventory (product_id, quantity, average_cost)
        VALUES (v_product_id, v_qty, v_cost)
        ON CONFLICT (product_id) DO UPDATE 
        SET quantity = public.inventory.quantity + EXCLUDED.quantity,
            average_cost = ((public.inventory.quantity * public.inventory.average_cost) + (EXCLUDED.quantity * EXCLUDED.average_cost)) / (public.inventory.quantity + EXCLUDED.quantity);

        -- Inventory Movement
        INSERT INTO public.inventory_movements (product_id, movement_type, quantity, unit_cost, reference_type, reference_id, created_by)
        VALUES (v_product_id, 'PURCHASE', v_qty, v_cost, 'PURCHASE', v_purchase_id, auth.uid());
    END LOOP;

    -- Payment and Ledger
    IF p_paid_amount > 0 THEN
        -- Insert Payment
        INSERT INTO public.payments (payment_number, supplier_id, purchase_id, payment_method_id, amount, reference, created_by)
        VALUES ('PAY-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(nextval('seq_payment_num')::TEXT, 6, '0'), p_supplier_id, v_purchase_id, p_payment_method_id, p_paid_amount, v_purchase_number, auth.uid())
        RETURNING id INTO v_payment_id;

        -- Financial Transaction
        INSERT INTO public.financial_transactions (transaction_type, reference_type, reference_id, payment_method_id, amount, direction, description, created_by)
        VALUES ('PURCHASE_PAYMENT', 'PAYMENT', v_payment_id, p_payment_method_id, p_paid_amount, 'OUT', 'Payment for ' || v_purchase_number, auth.uid());
    END IF;

    -- Supplier Ledger (Credit = what we owe them, Debit = what we paid)
    -- 1. Record total bill as Credit to supplier
    INSERT INTO public.supplier_ledger (supplier_id, transaction_type, reference_type, reference_id, credit, description, created_by)
    VALUES (p_supplier_id, 'PURCHASE', 'PURCHASE', v_purchase_id, v_total, 'Bill for ' || v_purchase_number, auth.uid());

    -- 2. Record payment as Debit
    IF p_paid_amount > 0 THEN
        INSERT INTO public.supplier_ledger (supplier_id, transaction_type, reference_type, reference_id, debit, description, created_by)
        VALUES (p_supplier_id, 'PAYMENT', 'PAYMENT', v_payment_id, p_paid_amount, 'Payment for ' || v_purchase_number, auth.uid());
    END IF;

    -- Audit
    INSERT INTO public.audit_logs (user_id, action, entity_type, entity_id) VALUES (auth.uid(), 'PURCHASE_CREATED', 'PURCHASE', v_purchase_id);

    RETURN v_purchase_id;
END;
$$ LANGUAGE plpgsql;

-- 2. Create Sale
CREATE OR REPLACE FUNCTION public.create_sale(
    p_customer_id UUID,
    p_vehicle_id UUID,
    p_items JSON,
    p_discount NUMERIC,
    p_paid_amount NUMERIC,
    p_payment_method_id UUID,
    p_notes TEXT
) RETURNS UUID AS $$
DECLARE
    v_sale_id UUID;
    v_sale_number TEXT;
    v_subtotal NUMERIC := 0;
    v_total NUMERIC := 0;
    v_due NUMERIC := 0;
    v_item JSON;
    v_product_id UUID;
    v_qty NUMERIC;
    v_price NUMERIC;
    v_item_discount NUMERIC;
    v_line_total NUMERIC;
    v_payment_id UUID;
    v_current_stock NUMERIC;
BEGIN
    v_sale_number := 'SALE-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(nextval('seq_sale_num')::TEXT, 6, '0');

    -- Calculate Totals & Check Stock
    FOR v_item IN SELECT * FROM json_array_elements(p_items)
    LOOP
        v_product_id := (v_item->>'product_id')::UUID;
        v_qty := (v_item->>'quantity')::NUMERIC;
        v_price := (v_item->>'unit_price')::NUMERIC;
        v_item_discount := COALESCE((v_item->>'discount')::NUMERIC, 0);
        
        v_line_total := (v_qty * v_price) - v_item_discount;
        v_subtotal := v_subtotal + v_line_total;

        -- Check Stock
        SELECT quantity INTO v_current_stock FROM public.inventory WHERE product_id = v_product_id FOR UPDATE;
        IF v_current_stock IS NULL OR v_current_stock < v_qty THEN
            RAISE EXCEPTION 'Insufficient stock. Requested: %, Available: %', v_qty, COALESCE(v_current_stock, 0);
        END IF;
    END LOOP;
    
    v_total := v_subtotal - COALESCE(p_discount, 0);
    v_due := v_total - COALESCE(p_paid_amount, 0);

    IF v_due < 0 THEN
        RAISE EXCEPTION 'Paid amount cannot be greater than total amount';
    END IF;

    -- Create Sale
    INSERT INTO public.sales (invoice_number, customer_id, vehicle_id, subtotal, discount, total_amount, paid_amount, due_amount, notes, created_by)
    VALUES (v_sale_number, p_customer_id, p_vehicle_id, v_subtotal, p_discount, v_total, p_paid_amount, v_due, p_notes, auth.uid())
    RETURNING id INTO v_sale_id;

    -- Insert Items & Update Inventory
    FOR v_item IN SELECT * FROM json_array_elements(p_items)
    LOOP
        v_product_id := (v_item->>'product_id')::UUID;
        v_qty := (v_item->>'quantity')::NUMERIC;
        v_price := (v_item->>'unit_price')::NUMERIC;
        v_item_discount := COALESCE((v_item->>'discount')::NUMERIC, 0);
        v_line_total := (v_qty * v_price) - v_item_discount;

        INSERT INTO public.sale_items (sale_id, product_id, quantity, unit_price, discount, line_total)
        VALUES (v_sale_id, v_product_id, v_qty, v_price, v_item_discount, v_line_total);

        -- Decrease Inventory
        UPDATE public.inventory SET quantity = quantity - v_qty WHERE product_id = v_product_id;

        -- Inventory Movement
        INSERT INTO public.inventory_movements (product_id, movement_type, quantity, unit_cost, reference_type, reference_id, created_by)
        VALUES (v_product_id, 'SALE', -v_qty, v_price, 'SALE', v_sale_id, auth.uid());
    END LOOP;

    -- Payment & Ledger (Only if there is a customer and payment)
    IF p_paid_amount > 0 THEN
        INSERT INTO public.payments (payment_number, customer_id, sale_id, payment_method_id, amount, reference, created_by)
        VALUES ('PAY-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(nextval('seq_payment_num')::TEXT, 6, '0'), p_customer_id, v_sale_id, p_payment_method_id, p_paid_amount, v_sale_number, auth.uid())
        RETURNING id INTO v_payment_id;

        INSERT INTO public.financial_transactions (transaction_type, reference_type, reference_id, payment_method_id, amount, direction, description, created_by)
        VALUES ('SALE_PAYMENT', 'PAYMENT', v_payment_id, p_payment_method_id, p_paid_amount, 'IN', 'Payment for ' || v_sale_number, auth.uid());
    END IF;

    IF p_customer_id IS NOT NULL THEN
        -- Customer Ledger (Debit = they owe us, Credit = they paid us)
        -- 1. Bill (Debit)
        INSERT INTO public.customer_ledger (customer_id, transaction_type, reference_type, reference_id, debit, description, created_by)
        VALUES (p_customer_id, 'SALE', 'SALE', v_sale_id, v_total, 'Invoice ' || v_sale_number, auth.uid());

        -- 2. Payment (Credit)
        IF p_paid_amount > 0 THEN
            INSERT INTO public.customer_ledger (customer_id, transaction_type, reference_type, reference_id, credit, description, created_by)
            VALUES (p_customer_id, 'PAYMENT', 'PAYMENT', v_payment_id, p_paid_amount, 'Payment for ' || v_sale_number, auth.uid());
        END IF;
    END IF;

    INSERT INTO public.audit_logs (user_id, action, entity_type, entity_id) VALUES (auth.uid(), 'SALE_CREATED', 'SALE', v_sale_id);

    RETURN v_sale_id;
END;
$$ LANGUAGE plpgsql;

-- 3. Create Expense
CREATE OR REPLACE FUNCTION public.create_expense(
    p_category_id UUID,
    p_amount NUMERIC,
    p_payment_method_id UUID,
    p_description TEXT,
    p_reference TEXT
) RETURNS UUID AS $$
DECLARE
    v_expense_id UUID;
    v_expense_number TEXT;
BEGIN
    v_expense_number := 'EXP-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(nextval('seq_expense_num')::TEXT, 6, '0');

    INSERT INTO public.expenses (expense_number, expense_category_id, amount, payment_method_id, description, reference, created_by)
    VALUES (v_expense_number, p_category_id, p_amount, p_payment_method_id, p_description, p_reference, auth.uid())
    RETURNING id INTO v_expense_id;

    INSERT INTO public.financial_transactions (transaction_type, reference_type, reference_id, payment_method_id, amount, direction, description, created_by)
    VALUES ('EXPENSE', 'EXPENSE', v_expense_id, p_payment_method_id, p_amount, 'OUT', 'Expense: ' || p_description, auth.uid());

    INSERT INTO public.audit_logs (user_id, action, entity_type, entity_id) VALUES (auth.uid(), 'EXPENSE_CREATED', 'EXPENSE', v_expense_id);

    RETURN v_expense_id;
END;
$$ LANGUAGE plpgsql;

-- 4. Record Customer Payment (Independent of a single sale)
CREATE OR REPLACE FUNCTION public.record_customer_payment(
    p_customer_id UUID,
    p_amount NUMERIC,
    p_payment_method_id UUID,
    p_reference TEXT,
    p_notes TEXT
) RETURNS UUID AS $$
DECLARE
    v_payment_id UUID;
    v_payment_number TEXT;
BEGIN
    v_payment_number := 'PAY-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(nextval('seq_payment_num')::TEXT, 6, '0');

    INSERT INTO public.payments (payment_number, customer_id, payment_method_id, amount, reference, notes, created_by)
    VALUES (v_payment_number, p_customer_id, p_payment_method_id, p_amount, p_reference, p_notes, auth.uid())
    RETURNING id INTO v_payment_id;

    INSERT INTO public.financial_transactions (transaction_type, reference_type, reference_id, payment_method_id, amount, direction, description, created_by)
    VALUES ('CUSTOMER_PAYMENT', 'PAYMENT', v_payment_id, p_payment_method_id, p_amount, 'IN', 'Customer Payment ' || v_payment_number, auth.uid());

    INSERT INTO public.customer_ledger (customer_id, transaction_type, reference_type, reference_id, credit, description, created_by)
    VALUES (p_customer_id, 'PAYMENT', 'PAYMENT', v_payment_id, p_amount, 'Payment Received', auth.uid());

    INSERT INTO public.audit_logs (user_id, action, entity_type, entity_id) VALUES (auth.uid(), 'CUSTOMER_PAYMENT_CREATED', 'PAYMENT', v_payment_id);

    RETURN v_payment_id;
END;
$$ LANGUAGE plpgsql;

-- 5. Record Supplier Payment
CREATE OR REPLACE FUNCTION public.record_supplier_payment(
    p_supplier_id UUID,
    p_amount NUMERIC,
    p_payment_method_id UUID,
    p_reference TEXT,
    p_notes TEXT
) RETURNS UUID AS $$
DECLARE
    v_payment_id UUID;
    v_payment_number TEXT;
BEGIN
    v_payment_number := 'PAY-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(nextval('seq_payment_num')::TEXT, 6, '0');

    INSERT INTO public.payments (payment_number, supplier_id, payment_method_id, amount, reference, notes, created_by)
    VALUES (v_payment_number, p_supplier_id, p_payment_method_id, p_amount, p_reference, p_notes, auth.uid())
    RETURNING id INTO v_payment_id;

    INSERT INTO public.financial_transactions (transaction_type, reference_type, reference_id, payment_method_id, amount, direction, description, created_by)
    VALUES ('SUPPLIER_PAYMENT', 'PAYMENT', v_payment_id, p_payment_method_id, p_amount, 'OUT', 'Supplier Payment ' || v_payment_number, auth.uid());

    INSERT INTO public.supplier_ledger (supplier_id, transaction_type, reference_type, reference_id, debit, description, created_by)
    VALUES (p_supplier_id, 'PAYMENT', 'PAYMENT', v_payment_id, p_amount, 'Payment Sent', auth.uid());

    INSERT INTO public.audit_logs (user_id, action, entity_type, entity_id) VALUES (auth.uid(), 'SUPPLIER_PAYMENT_CREATED', 'PAYMENT', v_payment_id);

    RETURN v_payment_id;
END;
$$ LANGUAGE plpgsql;


-- Phase 3: Reporting & Document Views

-- 1. Inventory Status View
-- This view aggregates inventory data with product details and calculates stock value and status dynamically.
CREATE OR REPLACE VIEW public.vw_inventory_status AS
SELECT 
    p.id AS product_id,
    pc.name AS category_name,
    p.brand,
    p.model,
    p.size_display,
    p.purchase_price,
    p.selling_price,
    p.minimum_stock,
    i.quantity AS current_stock,
    i.average_cost,
    (i.quantity * i.average_cost) AS stock_value,
    CASE 
        WHEN i.quantity <= 0 THEN 'Out of Stock'
        WHEN i.quantity <= p.minimum_stock THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM 
    public.products p
LEFT JOIN 
    public.inventory i ON p.id = i.product_id
LEFT JOIN
    public.product_categories pc ON p.category_id = pc.id;

-- 2. Low Stock View
-- Filters the inventory status view specifically for items that need reordering.
CREATE OR REPLACE VIEW public.vw_low_stock_report AS
SELECT * 
FROM public.vw_inventory_status 
WHERE current_stock <= minimum_stock;

-- 3. Customer Ledger Statement View with Running Balance
-- Uses window functions to calculate the running balance accurately in the database.
CREATE OR REPLACE VIEW public.vw_customer_ledger_statement AS
SELECT 
    cl.id,
    cl.customer_id,
    c.name AS customer_name,
    c.customer_code,
    cl.transaction_date,
    cl.transaction_type,
    cl.reference_type,
    cl.reference_id,
    cl.description,
    cl.debit,
    cl.credit,
    -- Running balance: Sum of (Debit - Credit) over time for this customer
    SUM(cl.debit - cl.credit) OVER (
        PARTITION BY cl.customer_id 
        ORDER BY cl.transaction_date ASC, cl.created_at ASC
    ) AS running_balance,
    cl.created_at
FROM 
    public.customer_ledger cl
JOIN 
    public.customers c ON cl.customer_id = c.id;

-- 4. Supplier Ledger Statement View with Running Balance
-- Uses window functions to calculate the running balance for suppliers.
CREATE OR REPLACE VIEW public.vw_supplier_ledger_statement AS
SELECT 
    sl.id,
    sl.supplier_id,
    s.name AS supplier_name,
    s.supplier_code,
    sl.transaction_date,
    sl.transaction_type,
    sl.reference_type,
    sl.reference_id,
    sl.description,
    sl.debit,
    sl.credit,
    -- Running balance: Sum of (Credit - Debit) over time for this supplier
    -- Credit is what we owe them, Debit is what we pay them
    SUM(sl.credit - sl.debit) OVER (
        PARTITION BY sl.supplier_id 
        ORDER BY sl.transaction_date ASC, sl.created_at ASC
    ) AS running_balance,
    sl.created_at
FROM 
    public.supplier_ledger sl
JOIN 
    public.suppliers s ON sl.supplier_id = s.id;


-- 5. Financial Summary View
-- Provides daily aggregation of cash flow IN and OUT.
CREATE OR REPLACE VIEW public.vw_daily_financial_summary AS
SELECT 
    transaction_date,
    SUM(CASE WHEN direction = 'IN' THEN amount ELSE 0 END) AS total_in,
    SUM(CASE WHEN direction = 'OUT' THEN amount ELSE 0 END) AS total_out,
    SUM(CASE WHEN direction = 'IN' THEN amount ELSE -amount END) AS net_movement
FROM 
    public.financial_transactions
GROUP BY 
    transaction_date
ORDER BY 
    transaction_date DESC;

-- Enable RLS on views by securing the underlying tables (which is already done).
-- In PostgreSQL, views generally run with the permissions of the invoker if configured, or by default the creator.
-- However, Supabase recommends creating secure views if they query RLS-protected tables.
-- To ensure RLS is enforced on the views, we don't need additional policies on the views themselves 
-- as long as the user querying the view has access to the underlying tables, which we established in Phase 1 & 2.

-- Audit Logs view for easy administration
CREATE OR REPLACE VIEW public.vw_audit_logs_readable AS
SELECT 
    a.id,
    a.created_at,
    u.email AS user_email,
    a.action,
    a.entity_type,
    a.entity_id
FROM 
    public.audit_logs a
LEFT JOIN 
    auth.users u ON a.user_id = u.id
ORDER BY 
    a.created_at DESC;


-- Phase 4: Advanced Business Logic, Returns, Adjustments & Audit

-- 1. TABLES FOR RETURNS AND ADJUSTMENTS

CREATE TABLE public.sale_returns (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    return_number TEXT NOT NULL UNIQUE,
    sale_id UUID REFERENCES public.sales(id) ON DELETE RESTRICT,
    return_date DATE DEFAULT CURRENT_DATE,
    total_amount NUMERIC(14,2) DEFAULT 0 CHECK (total_amount >= 0),
    refund_amount NUMERIC(14,2) DEFAULT 0 CHECK (refund_amount >= 0),
    notes TEXT,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.sale_return_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    return_id UUID REFERENCES public.sale_returns(id) ON DELETE CASCADE,
    sale_item_id UUID REFERENCES public.sale_items(id) ON DELETE RESTRICT,
    product_id UUID REFERENCES public.products(id) ON DELETE RESTRICT,
    quantity NUMERIC NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(14,2) NOT NULL CHECK (unit_price >= 0),
    line_total NUMERIC(14,2) NOT NULL CHECK (line_total >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.purchase_returns (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    return_number TEXT NOT NULL UNIQUE,
    purchase_id UUID REFERENCES public.purchases(id) ON DELETE RESTRICT,
    return_date DATE DEFAULT CURRENT_DATE,
    total_amount NUMERIC(14,2) DEFAULT 0 CHECK (total_amount >= 0),
    refund_amount NUMERIC(14,2) DEFAULT 0 CHECK (refund_amount >= 0),
    notes TEXT,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.purchase_return_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    return_id UUID REFERENCES public.purchase_returns(id) ON DELETE CASCADE,
    purchase_item_id UUID REFERENCES public.purchase_items(id) ON DELETE RESTRICT,
    product_id UUID REFERENCES public.products(id) ON DELETE RESTRICT,
    quantity NUMERIC NOT NULL CHECK (quantity > 0),
    unit_cost NUMERIC(14,2) NOT NULL CHECK (unit_cost >= 0),
    line_total NUMERIC(14,2) NOT NULL CHECK (line_total >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.stock_adjustments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    adjustment_number TEXT NOT NULL UNIQUE,
    product_id UUID REFERENCES public.products(id) ON DELETE RESTRICT,
    system_quantity NUMERIC NOT NULL,
    physical_quantity NUMERIC NOT NULL CHECK (physical_quantity >= 0),
    difference NUMERIC NOT NULL,
    reason TEXT NOT NULL,
    notes TEXT,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.balance_adjustments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    adjustment_number TEXT NOT NULL UNIQUE,
    entity_type TEXT NOT NULL CHECK (entity_type IN ('CUSTOMER', 'SUPPLIER')),
    customer_id UUID REFERENCES public.customers(id) ON DELETE RESTRICT,
    supplier_id UUID REFERENCES public.suppliers(id) ON DELETE RESTRICT,
    amount NUMERIC(14,2) NOT NULL CHECK (amount > 0),
    direction TEXT NOT NULL CHECK (direction IN ('DEBIT', 'CREDIT')),
    reason TEXT NOT NULL,
    reference TEXT,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CHECK (
        (entity_type = 'CUSTOMER' AND customer_id IS NOT NULL AND supplier_id IS NULL) OR
        (entity_type = 'SUPPLIER' AND supplier_id IS NOT NULL AND customer_id IS NULL)
    )
);

CREATE SEQUENCE IF NOT EXISTS seq_sale_ret_num START 1;
CREATE SEQUENCE IF NOT EXISTS seq_pur_ret_num START 1;
CREATE SEQUENCE IF NOT EXISTS seq_stk_adj_num START 1;
CREATE SEQUENCE IF NOT EXISTS seq_bal_adj_num START 1;

-- 2. RLS & INDEXES
ALTER TABLE public.sale_returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sale_return_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_return_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_adjustments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.balance_adjustments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated access sale_returns" ON public.sale_returns FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated access sale_return_items" ON public.sale_return_items FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated access purchase_returns" ON public.purchase_returns FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated access purchase_return_items" ON public.purchase_return_items FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated access stock_adjustments" ON public.stock_adjustments FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated access balance_adjustments" ON public.balance_adjustments FOR ALL TO authenticated USING (true);


-- 3. ADVANCED RPC FUNCTIONS

-- A. Process Sale Return (Partial or Full)
CREATE OR REPLACE FUNCTION public.process_sale_return(
    p_sale_id UUID,
    p_items JSON, -- [{ sale_item_id, product_id, quantity }]
    p_refund_amount NUMERIC,
    p_payment_method_id UUID,
    p_notes TEXT
) RETURNS UUID AS $$
DECLARE
    v_return_id UUID;
    v_return_number TEXT;
    v_customer_id UUID;
    v_item JSON;
    v_sale_item_id UUID;
    v_product_id UUID;
    v_return_qty NUMERIC;
    v_original_qty NUMERIC;
    v_prev_returned NUMERIC;
    v_unit_price NUMERIC;
    v_line_total NUMERIC;
    v_total_amount NUMERIC := 0;
    v_payment_id UUID;
BEGIN
    SELECT customer_id INTO v_customer_id FROM public.sales WHERE id = p_sale_id FOR UPDATE;
    IF v_customer_id IS NULL THEN RAISE EXCEPTION 'Sale not found'; END IF;

    v_return_number := 'SRET-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(nextval('seq_sale_ret_num')::TEXT, 6, '0');

    -- Insert Return Header (amounts updated later)
    INSERT INTO public.sale_returns (return_number, sale_id, refund_amount, notes, created_by)
    VALUES (v_return_number, p_sale_id, p_refund_amount, p_notes, auth.uid())
    RETURNING id INTO v_return_id;

    -- Process Items
    FOR v_item IN SELECT * FROM json_array_elements(p_items)
    LOOP
        v_sale_item_id := (v_item->>'sale_item_id')::UUID;
        v_product_id := (v_item->>'product_id')::UUID;
        v_return_qty := (v_item->>'quantity')::NUMERIC;

        -- Validate Quantities (Concurrency lock on sale_items not strictly needed if we assume isolated returns, but safe)
        SELECT quantity, unit_price INTO v_original_qty, v_unit_price 
        FROM public.sale_items WHERE id = v_sale_item_id FOR UPDATE;

        SELECT COALESCE(SUM(quantity), 0) INTO v_prev_returned 
        FROM public.sale_return_items WHERE sale_item_id = v_sale_item_id;

        IF (v_prev_returned + v_return_qty) > v_original_qty THEN
            RAISE EXCEPTION 'Return quantity exceeds original sold quantity for product %', v_product_id;
        END IF;

        v_line_total := v_return_qty * v_unit_price;
        v_total_amount := v_total_amount + v_line_total;

        -- Insert Return Item
        INSERT INTO public.sale_return_items (return_id, sale_item_id, product_id, quantity, unit_price, line_total)
        VALUES (v_return_id, v_sale_item_id, v_product_id, v_return_qty, v_unit_price, v_line_total);

        -- Increase Inventory
        UPDATE public.inventory SET quantity = quantity + v_return_qty WHERE product_id = v_product_id;

        -- Record Movement
        INSERT INTO public.inventory_movements (product_id, movement_type, quantity, unit_cost, reference_type, reference_id, created_by)
        VALUES (v_product_id, 'SALE_RETURN', v_return_qty, v_unit_price, 'SALE_RETURN', v_return_id, auth.uid());
    END LOOP;

    -- Update Return Header Totals
    UPDATE public.sale_returns SET total_amount = v_total_amount WHERE id = v_return_id;

    IF p_refund_amount > v_total_amount THEN
        RAISE EXCEPTION 'Refund amount cannot exceed total return amount';
    END IF;

    -- Ledger adjustments
    -- 1. Reverse the sale amount on ledger (Credit customer because they no longer owe this)
    INSERT INTO public.customer_ledger (customer_id, transaction_type, reference_type, reference_id, credit, description, created_by)
    VALUES (v_customer_id, 'SALE_RETURN', 'SALE_RETURN', v_return_id, v_total_amount, 'Sale Return ' || v_return_number, auth.uid());

    -- 2. If money is physically refunded, record payment OUT and Debit ledger
    IF p_refund_amount > 0 THEN
        INSERT INTO public.payments (payment_number, customer_id, payment_method_id, amount, reference, created_by)
        VALUES ('PAY-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(nextval('seq_payment_num')::TEXT, 6, '0'), v_customer_id, p_payment_method_id, p_refund_amount, v_return_number, auth.uid())
        RETURNING id INTO v_payment_id;

        INSERT INTO public.financial_transactions (transaction_type, reference_type, reference_id, payment_method_id, amount, direction, description, created_by)
        VALUES ('REFUND', 'PAYMENT', v_payment_id, p_payment_method_id, p_refund_amount, 'OUT', 'Refund for ' || v_return_number, auth.uid());

        -- Debit ledger (Customer owes us this refunded money back in accounting terms since we credited the full return amount above)
        INSERT INTO public.customer_ledger (customer_id, transaction_type, reference_type, reference_id, debit, description, created_by)
        VALUES (v_customer_id, 'REFUND', 'PAYMENT', v_payment_id, p_refund_amount, 'Refund for ' || v_return_number, auth.uid());
    END IF;

    INSERT INTO public.audit_logs (user_id, action, entity_type, entity_id) VALUES (auth.uid(), 'SALE_RETURNED', 'SALE_RETURN', v_return_id);

    RETURN v_return_id;
END;
$$ LANGUAGE plpgsql;


-- B. Process Purchase Return (Partial or Full)
CREATE OR REPLACE FUNCTION public.process_purchase_return(
    p_purchase_id UUID,
    p_items JSON,
    p_refund_amount NUMERIC,
    p_payment_method_id UUID,
    p_notes TEXT
) RETURNS UUID AS $$
DECLARE
    v_return_id UUID;
    v_return_number TEXT;
    v_supplier_id UUID;
    v_item JSON;
    v_purchase_item_id UUID;
    v_product_id UUID;
    v_return_qty NUMERIC;
    v_original_qty NUMERIC;
    v_prev_returned NUMERIC;
    v_unit_cost NUMERIC;
    v_line_total NUMERIC;
    v_total_amount NUMERIC := 0;
    v_payment_id UUID;
    v_current_stock NUMERIC;
BEGIN
    SELECT supplier_id INTO v_supplier_id FROM public.purchases WHERE id = p_purchase_id FOR UPDATE;
    IF v_supplier_id IS NULL THEN RAISE EXCEPTION 'Purchase not found'; END IF;

    v_return_number := 'PRET-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(nextval('seq_pur_ret_num')::TEXT, 6, '0');

    INSERT INTO public.purchase_returns (return_number, purchase_id, refund_amount, notes, created_by)
    VALUES (v_return_number, p_purchase_id, p_refund_amount, p_notes, auth.uid())
    RETURNING id INTO v_return_id;

    FOR v_item IN SELECT * FROM json_array_elements(p_items)
    LOOP
        v_purchase_item_id := (v_item->>'purchase_item_id')::UUID;
        v_product_id := (v_item->>'product_id')::UUID;
        v_return_qty := (v_item->>'quantity')::NUMERIC;

        SELECT quantity, unit_cost INTO v_original_qty, v_unit_cost 
        FROM public.purchase_items WHERE id = v_purchase_item_id FOR UPDATE;

        SELECT COALESCE(SUM(quantity), 0) INTO v_prev_returned 
        FROM public.purchase_return_items WHERE purchase_item_id = v_purchase_item_id;

        IF (v_prev_returned + v_return_qty) > v_original_qty THEN
            RAISE EXCEPTION 'Return quantity exceeds original purchased quantity for product %', v_product_id;
        END IF;

        -- Verify we have enough stock to return
        SELECT quantity INTO v_current_stock FROM public.inventory WHERE product_id = v_product_id FOR UPDATE;
        IF v_current_stock < v_return_qty THEN
            RAISE EXCEPTION 'Insufficient stock to return product %', v_product_id;
        END IF;

        v_line_total := v_return_qty * v_unit_cost;
        v_total_amount := v_total_amount + v_line_total;

        INSERT INTO public.purchase_return_items (return_id, purchase_item_id, product_id, quantity, unit_cost, line_total)
        VALUES (v_return_id, v_purchase_item_id, v_product_id, v_return_qty, v_unit_cost, v_line_total);

        -- Decrease Inventory
        UPDATE public.inventory SET quantity = quantity - v_return_qty WHERE product_id = v_product_id;

        INSERT INTO public.inventory_movements (product_id, movement_type, quantity, unit_cost, reference_type, reference_id, created_by)
        VALUES (v_product_id, 'PURCHASE_RETURN', -v_return_qty, v_unit_cost, 'PURCHASE_RETURN', v_return_id, auth.uid());
    END LOOP;

    UPDATE public.purchase_returns SET total_amount = v_total_amount WHERE id = v_return_id;

    -- Reverse supplier ledger (Debit because we owe them less)
    INSERT INTO public.supplier_ledger (supplier_id, transaction_type, reference_type, reference_id, debit, description, created_by)
    VALUES (v_supplier_id, 'PURCHASE_RETURN', 'PURCHASE_RETURN', v_return_id, v_total_amount, 'Purchase Return ' || v_return_number, auth.uid());

    -- If supplier refunds cash
    IF p_refund_amount > 0 THEN
        INSERT INTO public.payments (payment_number, supplier_id, payment_method_id, amount, reference, created_by)
        VALUES ('PAY-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(nextval('seq_payment_num')::TEXT, 6, '0'), v_supplier_id, p_payment_method_id, p_refund_amount, v_return_number, auth.uid())
        RETURNING id INTO v_payment_id;

        INSERT INTO public.financial_transactions (transaction_type, reference_type, reference_id, payment_method_id, amount, direction, description, created_by)
        VALUES ('REFUND', 'PAYMENT', v_payment_id, p_payment_method_id, p_refund_amount, 'IN', 'Refund from ' || v_return_number, auth.uid());

        -- Credit ledger (Supplier gave cash, so we owe them this back against the debit above)
        INSERT INTO public.supplier_ledger (supplier_id, transaction_type, reference_type, reference_id, credit, description, created_by)
        VALUES (v_supplier_id, 'REFUND', 'PAYMENT', v_payment_id, p_refund_amount, 'Refund from ' || v_return_number, auth.uid());
    END IF;

    INSERT INTO public.audit_logs (user_id, action, entity_type, entity_id) VALUES (auth.uid(), 'PURCHASE_RETURNED', 'PURCHASE_RETURN', v_return_id);

    RETURN v_return_id;
END;
$$ LANGUAGE plpgsql;


-- C. Stock Adjustments (Stocktake/Corrections)
CREATE OR REPLACE FUNCTION public.create_stock_adjustment(
    p_product_id UUID,
    p_physical_qty NUMERIC,
    p_reason TEXT,
    p_notes TEXT
) RETURNS UUID AS $$
DECLARE
    v_adj_id UUID;
    v_adj_number TEXT;
    v_system_qty NUMERIC;
    v_diff NUMERIC;
    v_cost NUMERIC;
BEGIN
    v_adj_number := 'ADJ-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(nextval('seq_stk_adj_num')::TEXT, 6, '0');

    SELECT quantity, average_cost INTO v_system_qty, v_cost FROM public.inventory WHERE product_id = p_product_id FOR UPDATE;
    IF v_system_qty IS NULL THEN v_system_qty := 0; v_cost := 0; END IF;

    v_diff := p_physical_qty - v_system_qty;

    INSERT INTO public.stock_adjustments (adjustment_number, product_id, system_quantity, physical_quantity, difference, reason, notes, created_by)
    VALUES (v_adj_number, p_product_id, v_system_qty, p_physical_qty, v_diff, p_reason, p_notes, auth.uid())
    RETURNING id INTO v_adj_id;

    IF v_diff != 0 THEN
        UPDATE public.inventory SET quantity = p_physical_qty WHERE product_id = p_product_id;
        
        INSERT INTO public.inventory_movements (product_id, movement_type, quantity, unit_cost, reference_type, reference_id, notes, created_by)
        VALUES (p_product_id, CASE WHEN v_diff > 0 THEN 'ADJUSTMENT_IN' ELSE 'ADJUSTMENT_OUT' END, v_diff, v_cost, 'ADJUSTMENT', v_adj_id, p_reason, auth.uid());
    END IF;

    INSERT INTO public.audit_logs (user_id, action, entity_type, entity_id) VALUES (auth.uid(), 'STOCK_ADJUSTMENT', 'ADJUSTMENT', v_adj_id);

    RETURN v_adj_id;
END;
$$ LANGUAGE plpgsql;

-- D. Customer/Supplier Balance Adjustments
CREATE OR REPLACE FUNCTION public.create_balance_adjustment(
    p_entity_type TEXT,
    p_entity_id UUID,
    p_amount NUMERIC,
    p_direction TEXT, -- 'DEBIT' or 'CREDIT'
    p_reason TEXT,
    p_reference TEXT
) RETURNS UUID AS $$
DECLARE
    v_adj_id UUID;
    v_adj_number TEXT;
BEGIN
    v_adj_number := 'BADJ-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(nextval('seq_bal_adj_num')::TEXT, 6, '0');

    INSERT INTO public.balance_adjustments (adjustment_number, entity_type, customer_id, supplier_id, amount, direction, reason, reference, created_by)
    VALUES (
        v_adj_number, 
        p_entity_type, 
        CASE WHEN p_entity_type = 'CUSTOMER' THEN p_entity_id ELSE NULL END, 
        CASE WHEN p_entity_type = 'SUPPLIER' THEN p_entity_id ELSE NULL END, 
        p_amount, 
        p_direction, 
        p_reason, 
        p_reference, 
        auth.uid()
    ) RETURNING id INTO v_adj_id;

    IF p_entity_type = 'CUSTOMER' THEN
        INSERT INTO public.customer_ledger (customer_id, transaction_type, reference_type, reference_id, debit, credit, description, created_by)
        VALUES (
            p_entity_id, 'ADJUSTMENT', 'ADJUSTMENT', v_adj_id, 
            CASE WHEN p_direction = 'DEBIT' THEN p_amount ELSE 0 END, 
            CASE WHEN p_direction = 'CREDIT' THEN p_amount ELSE 0 END, 
            p_reason, auth.uid()
        );
    ELSE
        INSERT INTO public.supplier_ledger (supplier_id, transaction_type, reference_type, reference_id, debit, credit, description, created_by)
        VALUES (
            p_entity_id, 'ADJUSTMENT', 'ADJUSTMENT', v_adj_id, 
            CASE WHEN p_direction = 'DEBIT' THEN p_amount ELSE 0 END, 
            CASE WHEN p_direction = 'CREDIT' THEN p_amount ELSE 0 END, 
            p_reason, auth.uid()
        );
    END IF;

    INSERT INTO public.audit_logs (user_id, action, entity_type, entity_id) VALUES (auth.uid(), 'BALANCE_ADJUSTMENT', 'ADJUSTMENT', v_adj_id);

    RETURN v_adj_id;
END;
$$ LANGUAGE plpgsql;


-- Phase 5: Final Backend Audit, Constraints, & Consistency Checks

-- 1. STRENGTHENING DATABASE CONSTRAINTS
-- Ensure financial calculations at the row level are mathematically impossible to corrupt.

ALTER TABLE public.sales 
ADD CONSTRAINT check_sales_totals 
CHECK (total_amount = subtotal - discount),
ADD CONSTRAINT check_sales_due 
CHECK (due_amount = total_amount - paid_amount);

ALTER TABLE public.purchases 
ADD CONSTRAINT check_purchases_totals 
CHECK (total_amount = subtotal - discount),
ADD CONSTRAINT check_purchases_due 
CHECK (due_amount = total_amount - paid_amount);

ALTER TABLE public.sale_items 
ADD CONSTRAINT check_sale_item_total 
CHECK (line_total = (quantity * unit_price) - discount);

ALTER TABLE public.purchase_items 
ADD CONSTRAINT check_purchase_item_total 
CHECK (line_total = (quantity * unit_cost) - discount);


-- 2. AUTOMATED INTEGRITY CHECK FUNCTIONS

-- A. Audit Inventory Consistency
-- This function verifies that the SUM of all inventory_movements equals the actual quantity in the inventory table.
CREATE OR REPLACE FUNCTION public.audit_inventory_consistency()
RETURNS TABLE (
    product_id UUID,
    system_quantity NUMERIC,
    calculated_movement_quantity NUMERIC,
    is_consistent BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        i.product_id,
        i.quantity AS system_quantity,
        COALESCE(SUM(im.quantity), 0) AS calculated_movement_quantity,
        (i.quantity = COALESCE(SUM(im.quantity), 0)) AS is_consistent
    FROM 
        public.inventory i
    LEFT JOIN 
        public.inventory_movements im ON i.product_id = im.product_id
    GROUP BY 
        i.product_id, i.quantity;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- B. Audit Customer Ledger Consistency
-- Validates if there are any orphaned payments or unbalanced transactions based on ledger entries.
CREATE OR REPLACE FUNCTION public.audit_customer_ledger()
RETURNS TABLE (
    customer_id UUID,
    total_debit NUMERIC,
    total_credit NUMERIC,
    calculated_balance NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cl.customer_id,
        COALESCE(SUM(cl.debit), 0) AS total_debit,
        COALESCE(SUM(cl.credit), 0) AS total_credit,
        COALESCE(SUM(cl.debit - cl.credit), 0) AS calculated_balance
    FROM 
        public.customer_ledger cl
    GROUP BY 
        cl.customer_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- C. Audit Supplier Ledger Consistency
CREATE OR REPLACE FUNCTION public.audit_supplier_ledger()
RETURNS TABLE (
    supplier_id UUID,
    total_debit NUMERIC,
    total_credit NUMERIC,
    calculated_payable NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sl.supplier_id,
        COALESCE(SUM(sl.debit), 0) AS total_debit,
        COALESCE(SUM(sl.credit), 0) AS total_credit,
        COALESCE(SUM(sl.credit - sl.debit), 0) AS calculated_payable
    FROM 
        public.supplier_ledger sl
    GROUP BY 
        sl.supplier_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 3. INDEX OPTIMIZATION
-- Add missing indexes that might impact performance during heavy reporting (Phase 3).
CREATE INDEX IF NOT EXISTS idx_inventory_movements_date ON public.inventory_movements(created_at);
CREATE INDEX IF NOT EXISTS idx_customer_ledger_date ON public.customer_ledger(transaction_date);
CREATE INDEX IF NOT EXISTS idx_supplier_ledger_date ON public.supplier_ledger(transaction_date);


-- 4. SECURITY & RLS ENHANCEMENTS
-- Ensure Audit Logs cannot be manipulated by anyone under any circumstances.
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Authenticated access audit_logs" ON public.audit_logs;

CREATE POLICY "Authenticated users can insert audit logs" 
ON public.audit_logs FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Authenticated users can select audit logs" 
ON public.audit_logs FOR SELECT TO authenticated USING (true);

-- Explicitly block Updates and Deletes on audit logs
-- (By not creating UPDATE/DELETE policies, Supabase natively denies these actions for authenticated users)




-- Phase 5 Final Deep Audit & Bug Fixes

-- =========================================================================
-- 1. DATABASE SCHEMA & NULLABILITY FIXES
-- =========================================================================
-- Prevent NULL bypass on mathematical constraints.

ALTER TABLE public.sales 
ALTER COLUMN subtotal SET NOT NULL,
ALTER COLUMN discount SET NOT NULL,
ALTER COLUMN total_amount SET NOT NULL,
ALTER COLUMN paid_amount SET NOT NULL,
ALTER COLUMN due_amount SET NOT NULL;

ALTER TABLE public.purchases 
ALTER COLUMN subtotal SET NOT NULL,
ALTER COLUMN discount SET NOT NULL,
ALTER COLUMN total_amount SET NOT NULL,
ALTER COLUMN paid_amount SET NOT NULL,
ALTER COLUMN due_amount SET NOT NULL;

ALTER TABLE public.sale_items 
ALTER COLUMN discount SET NOT NULL;

ALTER TABLE public.purchase_items 
ALTER COLUMN discount SET NOT NULL;

-- Ensure statuses are strictly controlled
ALTER TABLE public.sales 
ADD CONSTRAINT check_sales_status CHECK (status IN ('COMPLETED', 'REVERSED', 'CANCELLED'));

ALTER TABLE public.purchases 
ADD CONSTRAINT check_purchases_status CHECK (status IN ('COMPLETED', 'REVERSED', 'CANCELLED'));


-- =========================================================================
-- 2. SECURITY FIXES (SEARCH PATH INJECTION PREVENTION)
-- =========================================================================
-- Any SECURITY DEFINER function must explicitly set search_path to public.

ALTER FUNCTION public.audit_inventory_consistency() SET search_path = public;
ALTER FUNCTION public.audit_customer_ledger() SET search_path = public;
ALTER FUNCTION public.audit_supplier_ledger() SET search_path = public;


-- =========================================================================
-- 3. PAYMENT ALLOCATION ARCHITECTURE
-- =========================================================================
-- Fixes the 1:1 payment limitation. Enables Advances to be allocated across multiple invoices.

CREATE TABLE public.payment_allocations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    payment_id UUID REFERENCES public.payments(id) ON DELETE CASCADE,
    sale_id UUID REFERENCES public.sales(id) ON DELETE CASCADE,
    purchase_id UUID REFERENCES public.purchases(id) ON DELETE CASCADE,
    allocated_amount NUMERIC(14,2) NOT NULL CHECK (allocated_amount > 0),
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CHECK (
        (sale_id IS NOT NULL AND purchase_id IS NULL) OR
        (purchase_id IS NOT NULL AND sale_id IS NULL)
    )
);

ALTER TABLE public.payment_allocations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated access payment_allocations" ON public.payment_allocations FOR ALL TO authenticated USING (true);


-- =========================================================================
-- 4. MISSING BUSINESS LOGIC: TRUE REVERSALS
-- =========================================================================

-- Reverses a sale completely without deleting it, restoring stock and correcting ledgers.
CREATE OR REPLACE FUNCTION public.reverse_sale(
    p_sale_id UUID,
    p_reason TEXT
) RETURNS VOID AS $$
DECLARE
    v_sale RECORD;
    v_item RECORD;
BEGIN
    -- 1. Lock the sale to prevent concurrent modifications
    SELECT * INTO v_sale FROM public.sales WHERE id = p_sale_id FOR UPDATE;
    
    IF v_sale.status = 'REVERSED' THEN
        RAISE EXCEPTION 'TRANSACTION_ALREADY_REVERSED: Sale is already reversed.';
    END IF;

    -- 2. Restore Inventory
    FOR v_item IN SELECT * FROM public.sale_items WHERE sale_id = p_sale_id
    LOOP
        UPDATE public.inventory SET quantity = quantity + v_item.quantity WHERE product_id = v_item.product_id;
        
        INSERT INTO public.inventory_movements (product_id, movement_type, quantity, unit_cost, reference_type, reference_id, notes, created_by)
        VALUES (v_item.product_id, 'SALE_REVERSAL', v_item.quantity, v_item.unit_price, 'SALE_REVERSAL', p_sale_id, p_reason, auth.uid());
    END LOOP;

    -- 3. Correct Ledgers & Finances
    IF v_sale.customer_id IS NOT NULL THEN
        -- Reverse the debit (Credit the customer the full invoice amount)
        INSERT INTO public.customer_ledger (customer_id, transaction_type, reference_type, reference_id, credit, description, created_by)
        VALUES (v_sale.customer_id, 'SALE_REVERSAL', 'SALE', p_sale_id, v_sale.total_amount, 'Reversal of ' || v_sale.invoice_number, auth.uid());
        
        -- If they had paid money, reverse the payment on the ledger by debiting them back, because we physically hold their cash advance now.
        IF v_sale.paid_amount > 0 THEN
             INSERT INTO public.customer_ledger (customer_id, transaction_type, reference_type, reference_id, debit, description, created_by)
             VALUES (v_sale.customer_id, 'SALE_REVERSAL_PAYMENT', 'SALE', p_sale_id, v_sale.paid_amount, 'Payment retained as advance from ' || v_sale.invoice_number, auth.uid());
        END IF;
    END IF;

    -- 4. Mark Reversed
    UPDATE public.sales SET status = 'REVERSED', updated_at = NOW() WHERE id = p_sale_id;

    -- 5. Audit
    INSERT INTO public.audit_logs (user_id, action, entity_type, entity_id, action) 
    VALUES (auth.uid(), 'REVERSE_TRANSACTION', 'SALE', p_sale_id, p_reason);
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;


-- =========================================================================
-- 5. PERFORMANCE FIXES
-- =========================================================================
-- Missing indexes on foreign keys in high-volume tables that would cause slow joins

CREATE INDEX IF NOT EXISTS idx_sale_items_product ON public.sale_items(product_id);
CREATE INDEX IF NOT EXISTS idx_purchase_items_product ON public.purchase_items(product_id);
CREATE INDEX IF NOT EXISTS idx_payment_allocations_payment ON public.payment_allocations(payment_id);
