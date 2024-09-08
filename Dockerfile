# Use an official Nginx image as a base
FROM nginx:alpine

# Copy the static files to the Nginx HTML directory
COPY index.html /usr/share/nginx/html/
COPY script.js /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/

# Expose port 80 to allow access to the container
EXPOSE 80



