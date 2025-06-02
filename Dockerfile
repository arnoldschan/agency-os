# ----------- Builder Stage -----------
FROM node:18-alpine AS builder

# Enable pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Set working directory
WORKDIR /app

# Accept build arguments
ARG DIRECTUS_SERVER_TOKEN
ARG DIRECTUS_URL
ARG SITE_URL

# Copy only package-related files
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install

# Copy source files
COPY . .

# Write .env file for build-time usage
RUN echo "DIRECTUS_SERVER_TOKEN=$DIRECTUS_SERVER_TOKEN" > .env && \
    echo "DIRECTUS_URL=$DIRECTUS_URL" >> .env && \
    echo "SITE_URL=$SITE_URL" >> .env

# Build the Nuxt app
RUN pnpm build && rm -f .env

# ----------- Runtime Stage -----------
FROM node:18-alpine AS runner

# Enable pnpm (optional)
RUN corepack enable && corepack prepare pnpm@latest --activate

# Set working directory
WORKDIR /app

# Copy only what's needed to run the app
COPY --from=builder /app/.output ./.output
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Expose port
EXPOSE 3000

# Run the server
CMD ["node", ".output/server/index.mjs"]
