-- ============================================
-- Summer Camp 2026 - Supabase Database Schema
-- Run this in your Supabase SQL editor
-- ============================================

-- Create children table
CREATE TABLE IF NOT EXISTS children (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id TEXT UNIQUE NOT NULL,
  child_name TEXT NOT NULL,
  age INTEGER NOT NULL CHECK (age >= 1 AND age <= 18),
  parent_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT NOT NULL,
  entry_status BOOLEAN DEFAULT FALSE,
  entry_time TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS (Row Level Security)
ALTER TABLE children ENABLE ROW LEVEL SECURITY;

-- Allow anyone to INSERT (register)
CREATE POLICY "allow_insert" ON children
  FOR INSERT
  WITH CHECK (true);

-- Allow anyone to SELECT by phone (parent access) or by child_id (admin scan)
CREATE POLICY "allow_select" ON children
  FOR SELECT
  USING (true);

-- Only authenticated admin can UPDATE (mark entry)
CREATE POLICY "allow_admin_update" ON children
  FOR UPDATE
  USING (auth.role() = 'authenticated');

-- Index for fast phone number lookups
CREATE INDEX IF NOT EXISTS idx_children_phone ON children (phone);

-- Index for fast camp ID lookups
CREATE INDEX IF NOT EXISTS idx_children_child_id ON children (child_id);

-- ============================================
-- Admin Setup
-- ============================================
-- Go to Supabase Dashboard → Authentication → Users
-- Create an admin user manually with your admin email & password.
-- That user will be used for the Admin Login screen.
