# Supabase Setup

## Prerequisites
1. A Supabase project created at [supabase.com](https://supabase.com).
2. The Supabase URL and Anon Key from your Project Settings > API.

## Environment Variables
Create a `.env` file in the root of your frontend project (based on the provided `.env.example`):
```env
VITE_SUPABASE_URL=https://awuwyxntczazprftomwp.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key_here
```
**Warning**: Never commit your `.env` file to version control. Ensure it is in your `.gitignore`. Never use the Service Role Key in the frontend.

## Database Migrations
Since Phase 1 sets up the initial schema, you need to execute the SQL migration script:
1. Open your Supabase Dashboard.
2. Go to the SQL Editor.
3. Copy the contents of `supabase/migrations/20261001000000_core_master_data.sql`.
4. Paste and Run the SQL script to create tables, constraints, functions, RLS policies, and seed data.

## Client Configuration
The Supabase client is configured as a singleton in `src/lib/supabase.js`. All API calls from the frontend should import and use this client.
