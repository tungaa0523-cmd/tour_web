PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS staff (
 id TEXT PRIMARY KEY, email TEXT NOT NULL UNIQUE, name TEXT NOT NULL,
 password_hash TEXT NOT NULL, password_salt TEXT NOT NULL,
 role TEXT NOT NULL CHECK(role IN ('super_admin','manager','staff')),
 active INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
CREATE TABLE IF NOT EXISTS sessions (
 id TEXT PRIMARY KEY, staff_id TEXT NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
 token_hash TEXT NOT NULL UNIQUE, expires_at TEXT NOT NULL,
 created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
CREATE TABLE IF NOT EXISTS tours (
 id TEXT PRIMARY KEY, slug TEXT NOT NULL UNIQUE, title TEXT NOT NULL, summary TEXT NOT NULL DEFAULT '',
 description TEXT NOT NULL DEFAULT '', duration_days INTEGER NOT NULL DEFAULT 1,
 price_amount REAL, price_currency TEXT NOT NULL DEFAULT 'USD',
 status TEXT NOT NULL DEFAULT 'draft' CHECK(status IN ('draft','published','archived')),
 image_url TEXT NOT NULL DEFAULT '', itinerary_json TEXT NOT NULL DEFAULT '[]',
 created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
 updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
CREATE TABLE IF NOT EXISTS bookings (
 id TEXT PRIMARY KEY, booking_code TEXT NOT NULL UNIQUE, tour_id TEXT REFERENCES tours(id) ON DELETE SET NULL,
 customer_name TEXT NOT NULL, customer_email TEXT NOT NULL, customer_phone TEXT NOT NULL DEFAULT '',
 start_date TEXT NOT NULL, travellers INTEGER NOT NULL DEFAULT 1, message TEXT NOT NULL DEFAULT '',
 status TEXT NOT NULL DEFAULT 'new' CHECK(status IN ('new','contacted','confirmed','cancelled','completed')),
 quoted_amount REAL, currency TEXT NOT NULL DEFAULT 'USD', created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
 updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
CREATE TABLE IF NOT EXISTS availability (
 id TEXT PRIMARY KEY, tour_id TEXT NOT NULL REFERENCES tours(id) ON DELETE CASCADE,
 start_date TEXT NOT NULL, end_date TEXT NOT NULL, capacity INTEGER NOT NULL DEFAULT 10,
 booked INTEGER NOT NULL DEFAULT 0, price_amount REAL, currency TEXT NOT NULL DEFAULT 'USD',
 status TEXT NOT NULL DEFAULT 'open' CHECK(status IN ('open','closed')),
 UNIQUE(tour_id,start_date,end_date)
);
CREATE TABLE IF NOT EXISTS reviews (
 id TEXT PRIMARY KEY, customer_name TEXT NOT NULL, country TEXT NOT NULL DEFAULT '', rating INTEGER NOT NULL CHECK(rating BETWEEN 1 AND 5),
 content TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','published','hidden')),
 created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
CREATE TABLE IF NOT EXISTS gallery (
 id TEXT PRIMARY KEY, image_url TEXT NOT NULL, caption TEXT NOT NULL DEFAULT '',
 sort_order INTEGER NOT NULL DEFAULT 0, status TEXT NOT NULL DEFAULT 'published' CHECK(status IN ('published','hidden')),
 created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
CREATE TABLE IF NOT EXISTS inquiries (
 id TEXT PRIMARY KEY, name TEXT NOT NULL, email TEXT NOT NULL, travel_date TEXT DEFAULT '',
 travellers TEXT DEFAULT '', destination TEXT NOT NULL, message TEXT DEFAULT '',
 status TEXT NOT NULL DEFAULT 'new' CHECK(status IN ('new','contacted','confirmed','closed','spam')),
 created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
 updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
CREATE INDEX IF NOT EXISTS idx_bookings_date ON bookings(start_date,status);
CREATE INDEX IF NOT EXISTS idx_bookings_created ON bookings(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tours_status ON tours(status);
CREATE INDEX IF NOT EXISTS idx_sessions_expiry ON sessions(expires_at);
CREATE INDEX IF NOT EXISTS idx_inquiries_created ON inquiries(created_at DESC);

CREATE TABLE IF NOT EXISTS _eba_rate_limits (key_hash TEXT PRIMARY KEY, window_start INTEGER NOT NULL, hits INTEGER NOT NULL);
