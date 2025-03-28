# Use Node.js LTS as the base image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Define build arguments for environment variables
ARG VITE_POCKETBASE_URL
ARG POCKETBASE_ADMIN_EMAIL
ARG POCKETBASE_ADMIN_PASSWORD
ARG VITE_RAZORPAY_KEY_ID
ARG RAZORPAY_KEY_SECRET
ARG VITE_SITE_TITLE
ARG VITE_SITE_LOGO
ARG EMAIL_HOST
ARG EMAIL_PORT
ARG EMAIL_USER
ARG EMAIL_PASSWORD
ARG EMAIL_FROM
ARG SMTP_HOST
ARG SMTP_PORT
ARG SMTP_SECURE
ARG SMTP_USER
ARG SMTP_PASSWORD
ARG VITE_GEMINI_API_KEY

# Set environment variables
ENV VITE_POCKETBASE_URL=$VITE_POCKETBASE_URL
ENV POCKETBASE_ADMIN_EMAIL=$POCKETBASE_ADMIN_EMAIL
ENV POCKETBASE_ADMIN_PASSWORD=$POCKETBASE_ADMIN_PASSWORD
ENV VITE_RAZORPAY_KEY_ID=$VITE_RAZORPAY_KEY_ID
ENV RAZORPAY_KEY_SECRET=$RAZORPAY_KEY_SECRET
ENV VITE_SITE_TITLE=$VITE_SITE_TITLE
ENV VITE_SITE_LOGO=$VITE_SITE_LOGO
ENV EMAIL_HOST=$EMAIL_HOST
ENV EMAIL_PORT=$EMAIL_PORT
ENV EMAIL_USER=$EMAIL_USER
ENV EMAIL_PASSWORD=$EMAIL_PASSWORD
ENV EMAIL_FROM=$EMAIL_FROM
ENV SMTP_HOST=$SMTP_HOST
ENV SMTP_PORT=$SMTP_PORT
ENV SMTP_SECURE=$SMTP_SECURE
ENV SMTP_USER=$SMTP_USER
ENV SMTP_PASSWORD=$SMTP_PASSWORD
ENV VITE_GEMINI_API_KEY=$VITE_GEMINI_API_KEY
ENV SERVER_PORT=8080

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install
RUN npm install serve

# Copy the rest of the application code
COPY . .

# Build the frontend
RUN npm run build

# Create a server.js file to serve both API and frontend
RUN echo 'import express from "express";\
import cors from "cors";\
import bodyParser from "body-parser";\
import path from "path";\
import { fileURLToPath } from "url";\
import { dirname } from "path";\
import emailRoutes from "./src/api/email.js";\
\
const __filename = fileURLToPath(import.meta.url);\
const __dirname = dirname(__filename);\
\
const app = express();\
const PORT = process.env.SERVER_PORT || 8080;\
\
// Middleware\
app.use(cors());\
app.use(bodyParser.json({ limit: "10mb" }));\
app.use(bodyParser.urlencoded({ extended: true }));\
\
// API Routes\
app.use("/api/email", emailRoutes);\
\
// Health check endpoint\
app.get("/health", (req, res) => {\
  res.status(200).json({ status: "ok" });\
});\
\
// Serve static files from the dist directory\
app.use(express.static(path.join(__dirname, "dist")));\
\
// For any other route, serve the index.html file\
app.get("*", (req, res) => {\
  res.sendFile(path.join(__dirname, "dist", "index.html"));\
});\
\
// Start the server\
app.listen(PORT, () => {\
  console.log(`Server running on port ${PORT}`);\
});\
' > server.js

# Expose port 8080
EXPOSE 8080

# Start the server
CMD ["node", "server.js"]
