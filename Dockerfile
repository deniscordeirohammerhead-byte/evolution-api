# ---- Stage 1: Build ----
FROM node:20-alpine AS builder
WORKDIR /app
RUN apk add --no-cache git openssl
COPY package*.json ./
COPY tsconfig.json ./
RUN npm install
COPY . .
RUN npx prisma generate --schema=prisma/postgresql-schema.prisma
RUN npm run build

# ---- Stage 2: Runtime (imagem final leve) ----
FROM node:20-alpine
WORKDIR /app
RUN apk add --no-cache git openssl
COPY package*.json ./
RUN npm install --omit=dev
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
EXPOSE 3000
CMD ["node", "dist/main.js"]
