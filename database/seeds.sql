-- Seed data for development and testing

-- Insert demo users
-- Password: 'password123' (hashed with bcrypt)
INSERT INTO users (email, password_hash, name, role) VALUES
('admin@katomo.com', '$2b$10$rXKZ9qLQF5vXxqxqxqxqxOK3k9k9k9k9k9k9k9k9k9k9k9k9k', '管理者', 'admin'),
('manager@katomo.com', '$2b$10$rXKZ9qLQF5vXxqxqxqxqxOK3k9k9k9k9k9k9k9k9k9k9k9k9k', '営業マネージャー', 'manager'),
('sales1@katomo.com', '$2b$10$rXKZ9qLQF5vXxqxqxqxqxOK3k9k9k9k9k9k9k9k9k9k9k9k9k', '山田太郎', 'sales'),
('sales2@katomo.com', '$2b$10$rXKZ9qLQF5vXxqxqxqxqxOK3k9k9k9k9k9k9k9k9k9k9k9k9k', '佐藤花子', 'sales')
ON CONFLICT (email) DO NOTHING;

-- Insert demo customers
INSERT INTO customers (customer_number, name, name_kana, email, phone, mobile, address, source, assigned_sales_rep_id, created_by)
SELECT
  'C' || LPAD(CAST(ROW_NUMBER() OVER () AS TEXT), 5, '0'),
  names.name,
  names.name_kana,
  names.email,
  '03-1234-' || LPAD(CAST(FLOOR(RANDOM() * 10000) AS TEXT), 4, '0'),
  '090-' || LPAD(CAST(FLOOR(RANDOM() * 10000) AS TEXT), 4, '0') || '-' || LPAD(CAST(FLOOR(RANDOM() * 10000) AS TEXT), 4, '0'),
  '東京都渋谷区' || FLOOR(RANDOM() * 100)::TEXT || '-' || FLOOR(RANDOM() * 100)::TEXT,
  (ARRAY['survey', 'phone', 'walk_in', 'referral', 'web'])[FLOOR(RANDOM() * 5 + 1)],
  (SELECT id FROM users WHERE role = 'sales' ORDER BY RANDOM() LIMIT 1),
  (SELECT id FROM users WHERE role = 'sales' ORDER BY RANDOM() LIMIT 1)
FROM (VALUES
  ('田中一郎', 'タナカイチロウ', 'tanaka@example.com'),
  ('鈴木美咲', 'スズキミサキ', 'suzuki@example.com'),
  ('高橋健太', 'タカハシケンタ', 'takahashi@example.com'),
  ('伊藤麻衣', 'イトウマイ', 'ito@example.com'),
  ('渡辺直樹', 'ワタナベナオキ', 'watanabe@example.com')
) AS names(name, name_kana, email);

-- Insert demo deals
INSERT INTO deals (customer_id, title, description, stage, priority, estimated_amount, probability, assigned_to, created_by)
SELECT
  c.id,
  c.name || 'さんの' || (ARRAY['プリウス', 'アクア', 'カローラ', 'ヤリス'])[FLOOR(RANDOM() * 4 + 1)] || '商談',
  '初回接触から商談開始',
  (ARRAY['initial_contact', 'hearing', 'quote_sent', 'negotiation', 'contract'])[FLOOR(RANDOM() * 5 + 1)],
  (ARRAY['low', 'medium', 'high'])[FLOOR(RANDOM() * 3 + 1)],
  FLOOR(RANDOM() * 2000000 + 1500000),
  FLOOR(RANDOM() * 50 + 30),
  c.assigned_sales_rep_id,
  c.created_by
FROM customers c
LIMIT 5;

-- Insert email templates
INSERT INTO email_templates (name, subject, body_template, category, created_by)
SELECT
  templates.name,
  templates.subject,
  templates.body,
  templates.category,
  (SELECT id FROM users WHERE role = 'admin' LIMIT 1)
FROM (VALUES
  ('初回フォローアップ', 'お問い合わせありがとうございます',
   '{{customer_name}} 様\n\nこの度はお問い合わせいただき、誠にありがとうございます。\n担当の{{sales_rep_name}}と申します。\n\nご希望のお車について、詳しくお話をお伺いできればと思います。\nご都合の良い日時をお知らせいただけますでしょうか。\n\nよろしくお願いいたします。',
   'follow_up'),
  ('見積もり送付', 'お見積もりのご案内',
   '{{customer_name}} 様\n\nお待たせいたしました。\nご依頼いただいておりました{{vehicle_model}}のお見積もりをお送りいたします。\n\nご不明な点がございましたら、お気軽にお問い合わせください。\n\nよろしくお願いいたします。',
   'quote'),
  ('納車前連絡', '納車日のご案内',
   '{{customer_name}} 様\n\nいつもお世話になっております。\n\nご契約いただきました{{vehicle_model}}の納車日が確定いたしました。\n納車予定日: {{delivery_date}}\n\n当日は必要書類をご持参くださいますよう、お願いいたします。\n\nよろしくお願いいたします。',
   'delivery'),
  ('納車後お礼', '納車のお礼',
   '{{customer_name}} 様\n\nこの度は{{vehicle_model}}をご購入いただき、誠にありがとうございました。\n\n今後とも末永くお付き合いいただけますよう、よろしくお願いいたします。\nご不明な点やご質問がございましたら、いつでもお気軽にご連絡ください。\n\nありがとうございました。',
   'thank_you')
) AS templates(name, subject, body, category);

-- Success message
SELECT 'Seed data inserted successfully' AS status;
