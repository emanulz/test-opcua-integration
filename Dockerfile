FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files and install dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy source code
COPY tsconfig.json ./
COPY src ./src

# Uncomment this line if you want to bake environment variables into the image (not recommended for production)
# COPY .env ./

# Build the application
RUN yarn build

# Create production image
FROM node:22-alpine

WORKDIR /app

# Copy package files and install production dependencies only
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production

# Copy built application from builder stage
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

# Create a directory for the SQLite database and logs
RUN mkdir -p /app/data /app/logs

# Set environment variables
ENV NODE_ENV=production

# Create a non-root user and switch to it
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app
USER appuser

# Run the application
CMD ["node", "dist/index.js"] 
