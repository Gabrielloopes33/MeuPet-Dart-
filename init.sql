-- Script de inicialização do banco de dados
-- Cria as tabelas necessárias para o app

-- Tabela de usuários
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de pets
CREATE TABLE IF NOT EXISTS pets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100) NOT NULL, -- 'dog', 'cat', 'bird', etc.
    breed VARCHAR(255),
    birth_date DATE,
    weight DECIMAL(5,2),
    photo_url VARCHAR(500),
    medical_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de agendamentos
CREATE TABLE IF NOT EXISTS appointments (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    pet_id INTEGER REFERENCES pets(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    appointment_date TIMESTAMP NOT NULL,
    appointment_type VARCHAR(100) NOT NULL, -- 'vet', 'grooming', 'vaccination', etc.
    location VARCHAR(255),
    status VARCHAR(50) DEFAULT 'scheduled', -- 'scheduled', 'completed', 'cancelled'
    reminder_minutes INTEGER DEFAULT 60,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_pets_user_id ON pets(user_id);
CREATE INDEX IF NOT EXISTS idx_appointments_user_id ON appointments(user_id);
CREATE INDEX IF NOT EXISTS idx_appointments_pet_id ON appointments(pet_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);

-- Inserir alguns dados de exemplo
INSERT INTO users (name, phone, password_hash) VALUES 
('Gabriel', '(11) 99999-9999', '$2b$10$example_hash_for_123456'),
('Maria Silva', '(11) 88888-8888', '$2b$10$example_hash_for_senha123')
ON CONFLICT (phone) DO NOTHING;

INSERT INTO pets (user_id, name, type, breed, birth_date, weight) VALUES 
(1, 'Rex', 'dog', 'Golden Retriever', '2020-05-15', 28.5),
(1, 'Mimi', 'cat', 'Persa', '2021-03-10', 4.2),
(2, 'Bob', 'dog', 'Bulldog', '2019-08-22', 22.0)
ON CONFLICT DO NOTHING;

INSERT INTO appointments (user_id, pet_id, title, description, appointment_date, appointment_type) VALUES 
(1, 1, 'Consulta Veterinária', 'Check-up anual do Rex', '2024-11-15 14:00:00', 'vet'),
(1, 2, 'Tosa e Banho', 'Tosa completa da Mimi', '2024-11-20 10:00:00', 'grooming'),
(2, 3, 'Vacinação', 'Vacina anual do Bob', '2024-11-25 16:30:00', 'vaccination')
ON CONFLICT DO NOTHING;