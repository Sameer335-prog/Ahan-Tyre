# Row Level Security (RLS)

## Overview
All business application tables have Row Level Security (RLS) enabled. This ensures that even if the API keys are exposed, the data remains secure based on user authentication status.

## Policies Implemented

### 1. `profiles`
The `profiles` table contains user-specific information.
- **Select**: Users can only select their own profile.
- **Insert**: Users can only insert a profile with an `id` that matches their `auth.uid()`.
- **Update**: Users can only update their own profile.

### 2. Business Data Tables
Tables such as `products`, `customers`, `suppliers`, `payment_methods`, `expense_categories`, and `customer_vehicles` store global business data.
- **Phase 1 Model**: One Business, One Owner.
- **Policy**: All authenticated users have full access (SELECT, INSERT, UPDATE, DELETE) to these tables. Unauthenticated (anonymous) access is strictly blocked.
- **Implementation**:
  ```sql
  CREATE POLICY "Authenticated users can access [table]" ON public.[table] 
  FOR ALL TO authenticated USING (true) WITH CHECK (true);
  ```

## Testing RLS
To test RLS:
1. Ensure you are logged out in the frontend.
2. Attempt to fetch products using the Supabase client. You should receive an error or an empty array.
3. Log in using a valid user account.
4. Attempt to fetch products again. The data should now be successfully retrieved.
