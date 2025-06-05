const config = {
    env: process.env.NODE_ENV || 'development',
    db: {
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
    },
    secretKey: process.env.SECRET_KEY,
  };
  
  module.exports = config;