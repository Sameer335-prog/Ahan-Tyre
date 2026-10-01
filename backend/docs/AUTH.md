# Authentication Documentation

## Overview
Authentication is handled entirely by **Supabase Auth**. No custom password tables or manual hashing are used.

## Configuration
- Supabase manages credentials securely.
- In Phase 1, the system is designed for **ONE BUSINESS, ONE OWNER**.
- A custom `profiles` table is created to store additional user-specific application data, extending the default `auth.users` behavior.

## Application Flow
1. **Login/Logout**: Handled via `supabase.auth.signInWithPassword()` and `supabase.auth.signOut()`.
2. **Session Persistence**: `@supabase/supabase-js` automatically persists the session to local storage (or another mechanism depending on the environment) and restores it on refresh.
3. **Protected Routes**: Your React application must check `supabase.auth.getSession()` or listen to `supabase.auth.onAuthStateChange()` to determine if a user is logged in before rendering protected views.

## User Creation
For Phase 1, you can create the owner's account directly through the Supabase Dashboard -> Authentication -> Users -> Add User, or through the sign-up API if implemented in your UI.
