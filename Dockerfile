# Stage 1: Build
FROM node:20.12.2-alpine3.19 AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --cache-clear \
    && npm cache clean --force
COPY . .
RUN npm run build

# Stage 2: Runtime
FROM node:20.12.2-alpine3.19

WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY package*.json ./

RUN npm ci --omit=dev \
    && npm cache clean --force

# Usar usuario no-root para mayor seguridad
USER node

CMD ["node", "dist/index.js"]