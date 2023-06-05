# Source image
FROM node:18-alpine
RUN apk add --no-cache libc6-compat

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# Install dependencies
RUN npm install

# Copy source code and other artifacts
COPY . .

# Expose application port
EXPOSE 3000

CMD ["npm", "start"]
