# Install dependencies and build using pnpm
FROM node:18-alpine AS builder

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Set working directory
WORKDIR /app

# Copy only package manager files
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install

# Copy rest of the source code
COPY . .

# Build the Nuxt project
RUN pnpm build

# --------------------------------------

# Runtime image
FROM node:18-alpine AS runner

# Enable pnpm (optional, if you need to run pnpm in runtime)
RUN corepack enable && corepack prepare pnpm@latest --activate

# Set working directory
WORKDIR /app

# Copy built output and necessary files
COPY --from=builder /app/.output ./.output
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Expose default Nuxt port
EXPOSE 3000

# Start the server
CMD ["node", ".output/server/index.mjs"]
