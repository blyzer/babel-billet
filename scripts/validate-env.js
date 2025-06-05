// scripts/validate-env.js

/**
 * Lista de variables obligatorias.
 * Si alguna falta, el script sale con código 1.
 */
const requiredVars = [
    'DB_HOST',
    'DB_USER',
    'DB_PASSWORD',
    'SECRET_KEY'
  ];
  
  let missing = [];
  
  requiredVars.forEach((v) => {
    if (!process.env[v] || process.env[v].trim() === '') {
      missing.push(v);
    }
  });
  
  if (missing.length > 0) {
    console.error(`Variables de entorno faltantes: ${missing.join(', ')}`);
    process.exit(1);
  } else {
    console.log('Todas las variables de entorno están definidas.');
  }
  