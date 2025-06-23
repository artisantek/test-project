-- Movie Review Database Initialization Script
-- This script creates the database, user, and schema required for the movie review application

-- Create database (this will be created by POSTGRES_DB env var)
-- CREATE DATABASE moviereviews;

-- Create user and grant permissions
CREATE USER movieuser WITH ENCRYPTED PASSWORD 'moviepass';
GRANT ALL PRIVILEGES ON DATABASE moviereviews TO movieuser;

-- Connect to the moviereviews database
\c moviereviews;

-- Grant schema permissions to user
GRANT ALL ON SCHEMA public TO movieuser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO movieuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO movieuser;

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
    id BIGSERIAL PRIMARY KEY,
    movie_id VARCHAR(255) NOT NULL,
    review_text VARCHAR(2000) NOT NULL,
    sentiment VARCHAR(50),
    sentiment_score DOUBLE PRECISION,
    rating DOUBLE PRECISION,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_reviews_movie_id ON reviews(movie_id);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON reviews(created_at);
CREATE INDEX IF NOT EXISTS idx_reviews_sentiment ON reviews(sentiment);

-- Insert some sample data for testing
INSERT INTO reviews (movie_id, review_text, sentiment, sentiment_score, rating, created_at) VALUES
('shawshank', 'This is an absolutely incredible movie! The story is so inspiring and the acting is phenomenal.', 'positive', 0.95, 4.8, '2024-01-15 10:30:00'),
('inception', 'Mind-bending plot that keeps you thinking long after the credits roll. Christopher Nolan at his finest.', 'positive', 0.88, 4.6, '2024-01-16 14:22:00'),
('interstellar', 'A beautiful exploration of love, time, and space. Visually stunning with an emotional core.', 'positive', 0.92, 4.7, '2024-01-17 09:15:00'),
('fight-club', 'Dark and twisted but brilliantly executed. Not for everyone but definitely memorable.', 'neutral', 0.65, 3.8, '2024-01-18 16:45:00'),
('gladiator', 'Epic historical drama with Russell Crowe delivering a powerful performance.', 'positive', 0.85, 4.4, '2024-01-19 11:30:00'),
('dark-knight', 'Heath Ledger''s Joker is absolutely legendary. A masterpiece of the superhero genre.', 'positive', 0.93, 4.9, '2024-01-20 13:20:00'),
('shawshank', 'While well-made, I found it a bit slow for my taste. Good but not great.', 'neutral', 0.45, 3.2, '2024-01-21 15:10:00'),
('inception', 'Too confusing and pretentious. I couldn''t follow the plot at all.', 'negative', 0.25, 2.1, '2024-01-22 18:30:00');

-- Grant permissions on the table to movieuser
GRANT ALL PRIVILEGES ON TABLE reviews TO movieuser;
GRANT USAGE, SELECT ON SEQUENCE reviews_id_seq TO movieuser;

-- Create a view for review statistics (useful for admin dashboard)
CREATE OR REPLACE VIEW review_stats AS
SELECT 
    movie_id,
    COUNT(*) as total_reviews,
    AVG(rating) as avg_rating,
    AVG(sentiment_score) as avg_sentiment_score,
    COUNT(CASE WHEN sentiment = 'positive' THEN 1 END) as positive_reviews,
    COUNT(CASE WHEN sentiment = 'negative' THEN 1 END) as negative_reviews,
    COUNT(CASE WHEN sentiment = 'neutral' THEN 1 END) as neutral_reviews,
    MAX(created_at) as latest_review
FROM reviews 
GROUP BY movie_id;

-- Grant permissions on the view
GRANT ALL PRIVILEGES ON TABLE review_stats TO movieuser;

-- Display initialization summary
\echo ''
\echo '========================================='
\echo 'Movie Review Database Initialized Successfully!'
\echo '========================================='
\echo 'Database: moviereviews'
\echo 'User: movieuser'
\echo 'Tables: reviews, review_stats (view)'
\echo 'Sample data: 8 reviews inserted'
\echo '========================================='
\echo ''

-- Show sample data
SELECT 'Sample Reviews:' as info;
SELECT movie_id, LEFT(review_text, 50) || '...' as review_preview, sentiment, rating 
FROM reviews 
ORDER BY created_at 
LIMIT 5; 