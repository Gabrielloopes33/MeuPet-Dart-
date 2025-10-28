# Estrutura sugerida para o backend (futuro)

backend/
├── package.json
├── server.js
├── routes/
│   ├── auth.js
│   ├── pets.js
│   └── appointments.js
├── models/
│   ├── User.js
│   ├── Pet.js
│   └── Appointment.js
├── middleware/
│   ├── auth.js
│   └── validation.js
└── config/
    └── database.js

# Comandos para criar backend (quando quiser):
# mkdir backend
# cd backend
# npm init -y
# npm install express pg bcrypt jsonwebtoken cors helmet
# npm install -D nodemon