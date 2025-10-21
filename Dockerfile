# Use an official Node.js runtime as a parent image
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install application dependencies
RUN npm install

# Bundle app source
COPY . .

# Your app binds to port 8000, so expose it
EXPOSE 8000

# Define the command to run your app
CMD ["npm", "start"]