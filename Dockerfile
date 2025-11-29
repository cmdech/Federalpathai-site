# Stage 1: Build the React application
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package.json and install dependencies
# Use yarn if that's what you prefer, otherwise npm
COPY package.json yarn.lock* ./
RUN yarn install --immutable

# Copy the rest of your application code
COPY . .

# Build the React app for production
# This command uses the 'build' script defined in package.json
# It will create the 'dist' folder as per vite.config.ts
RUN yarn build

# Stage 2: Serve the application with Nginx
FROM nginx:alpine

# Copy the built React app from the builder stage to Nginx's html directory
# Cloud Run expects the server to listen on the PORT env var (default 8080)
# Nginx typically listens on port 80 internally, Cloud Run maps external 8080 to internal 80.
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy a custom Nginx configuration for single-page application routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 (Nginx default internal port)
EXPOSE 80

# Start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]
