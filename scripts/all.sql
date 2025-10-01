-- Complete Database Schema for Blog Application
-- This file contains all tables needed for the blog system

-- Drop existing tables if they exist (in correct order to handle foreign keys)
DROP TABLE IF EXISTS `newsletter_subscribers`;
DROP TABLE IF EXISTS `contact_messages`;
DROP TABLE IF EXISTS `chat_messages`;
DROP TABLE IF EXISTS `comments`;
DROP TABLE IF EXISTS `likes`;
DROP TABLE IF EXISTS `posts`;
DROP TABLE IF EXISTS `user_sessions`;
DROP TABLE IF EXISTS `email_verifications`;
DROP TABLE IF EXISTS `users`;

-- Users table
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL UNIQUE,
  `email` varchar(100) NOT NULL UNIQUE,
  `password` varchar(255) NOT NULL,
  `avatar` varchar(255) DEFAULT 'default-avatar.png',
  `is_admin` tinyint(1) DEFAULT 0,
  `is_verified` tinyint(1) DEFAULT 0,
  `bio` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_email` (`email`),
  KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Email verifications table
CREATE TABLE `email_verifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `code` varchar(10) NOT NULL,
  `type` enum('registration','password_reset') NOT NULL DEFAULT 'registration',
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_email_code` (`email`, `code`),
  KEY `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User sessions table
CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `session_token` varchar(255) NOT NULL UNIQUE,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_token` (`session_token`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_expires` (`expires_at`),
  CONSTRAINT `fk_sessions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Posts table
CREATE TABLE `posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL UNIQUE,
  `content` longtext NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `hashtags` varchar(500) DEFAULT NULL,
  `author_id` int(11) NOT NULL,
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `views` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_author` (`author_id`),
  KEY `idx_status` (`status`),
  KEY `idx_slug` (`slug`),
  KEY `idx_created` (`created_at`),
  FULLTEXT KEY `idx_search` (`title`, `content`, `hashtags`),
  CONSTRAINT `fk_posts_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Likes table
CREATE TABLE `likes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_like` (`user_id`, `post_id`),
  KEY `idx_post` (`post_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `fk_likes_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_likes_post` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Comments table
CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `content` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_post` (`post_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_created` (`created_at`),
  CONSTRAINT `fk_comments_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_comments_post` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Chat messages table
CREATE TABLE `chat_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sender` (`sender_id`),
  KEY `idx_receiver` (`receiver_id`),
  KEY `idx_conversation` (`sender_id`, `receiver_id`),
  KEY `idx_created` (`created_at`),
  CONSTRAINT `fk_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_messages_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Contact messages table
CREATE TABLE `contact_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `status` enum('new','read','replied') NOT NULL DEFAULT 'new',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Newsletter subscribers table
CREATE TABLE `newsletter_subscribers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL UNIQUE,
  `status` enum('active','unsubscribed') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_email` (`email`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default admin user
-- Password: admin123 (hashed with bcrypt)
INSERT INTO `users` (`username`, `email`, `password`, `is_admin`, `is_verified`, `avatar`) VALUES
('admin', 'admin@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, 1, 'default-avatar.png');

-- Insert sample posts (optional)
INSERT INTO `posts` (`title`, `slug`, `content`, `hashtags`, `author_id`, `status`) VALUES
('React Hooks bilan Ishlash', 'react-hooks-bilan-ishlash', '<h2>React Hooks nima?</h2><p>Hooks - bu React 16.8 da qo''shilgan yangi xususiyat bo''lib, function komponentlarda state va lifecycle metodlaridan foydalanish imkonini beradi.</p><h3>useState Hook</h3><pre><code>import React, { useState } from ''react'';

function Counter() {
  const [count, setCount] = useState(0);
  
  return (
    <div>
      <p>Siz {count} marta bosdingiz</p>
      <button onClick={() => setCount(count + 1)}>
        Bosing
      </button>
    </div>
  );
}</code></pre><h3>useEffect Hook</h3><p>useEffect hook komponenta render bo''lgandan keyin side effectlarni bajarish uchun ishlatiladi.</p><pre><code>import React, { useState, useEffect } from ''react'';

function Example() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    document.title = `Siz ${count} marta bosdingiz`;
  });

  return (
    <div>
      <p>Siz {count} marta bosdingiz</p>
      <button onClick={() => setCount(count + 1)}>
        Bosing
      </button>
    </div>
  );
}</code></pre>', 'react,hooks,javascript,frontend', 1, 'published'),

('JavaScript ES6+ Yangiliklari', 'javascript-es6-yangiliklari', '<h2>ES6+ da qanday yangiliklar bor?</h2><p>JavaScript ES6 va undan keyingi versiyalar ko''plab yangi xususiyatlar bilan keldi.</p><h3>Arrow Functions</h3><pre><code>// Eski usul
function add(a, b) {
  return a + b;
}

// Yangi usul
const add = (a, b) => a + b;</code></pre><h3>Destructuring</h3><pre><code>// Array destructuring
const [first, second] = [1, 2, 3];

// Object destructuring
const { name, age } = { name: ''Ali'', age: 25 };</code></pre><h3>Template Literals</h3><pre><code>const name = ''Ali'';
const greeting = `Salom, ${name}!`;</code></pre>', 'javascript,es6,programming', 1, 'published');

-- Create indexes for better performance
CREATE INDEX idx_posts_hashtags ON posts(hashtags(100));
CREATE INDEX idx_chat_unread ON chat_messages(receiver_id, is_read);

-- Show table structure
SHOW TABLES;
