# Use the official Python image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Install necessary system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone the Flask repository
RUN git clone https://github.com/sneh-create/flask.git /tmp/flask

# Set the working directory to the Flask tutorial example
WORKDIR /tmp/flask/examples/tutorial

# Checkout the latest tagged version
RUN git fetch --tags && \
    git checkout $(git describe --tags $(git rev-list --tags --max-count=1))

# Create a virtual environment
RUN python3 -m venv /venv

# Activate the virtual environment and install Flaskr
RUN . /venv/bin/activate && pip install -e ../.. && pip install -e .

# Copy Flask app to the container
RUN cp -R /tmp/flask/examples/tutorial /app/

# Install test dependencies
RUN . /venv/bin/activate && pip install '.[test]'

# Set environment variables
ENV FLASK_APP=flaskr
ENV FLASK_RUN_HOST=0.0.0.0
ENV PATH="/venv/bin:$PATH"

# Expose the Flask app port
EXPOSE 5000

# Initialize the database
RUN flask --app flaskr init-db

# Run the application
CMD ["flask", "--app", "flaskr", "run", "--debug"]
