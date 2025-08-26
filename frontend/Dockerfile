# Use an official lightweight Node.js image as a base
FROM node:20-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first
COPY package*.json ./

# Install project dependencies
RUN npm install

# Copy the rest of the application code into the container
COPY . .

# Expose the port that Next.js dev server runs on
EXPOSE 3000

# The command to run the DEVELOPMENT server when the container starts
CMD ["npm", "run", "dev"]