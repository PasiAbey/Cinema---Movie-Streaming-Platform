FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5002
# Limit Node memory to avoid OOM crashes (Exit Code 137)
ENV NODE_OPTIONS="--max-old-space-size=256"
CMD ["node", "index.js"]
