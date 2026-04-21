FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy all other files
COPY . .

# Expose Vite's default port
EXPOSE 5173

# Start Vite dev server exposing it to the network
CMD ["npm", "run", "dev", "--", "--host"]
