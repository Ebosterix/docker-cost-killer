FROM node:20-alpine AS builder
WORKDIR /app
COPY client/package*.json ./client/
RUN cd client && npm ci
COPY client/ ./client/
RUN cd client && npm run build

FROM node:20-alpine AS deps
WORKDIR /app
COPY server/package*.json ./server/
RUN cd server && npm ci --only=production

FROM node:20-alpine
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=deps /app/server/node_modules ./server/node_modules
COPY server/ ./server/
COPY --from=builder /app/client/dist ./client/dist
USER appuser
EXPOSE 5000
CMD ["node", "server/index.js"]
