# Stage 1: Build dependencies
FROM python:3.11-slim AS builder

WORKDIR /build

# Copy requirements and install them to a temporary directory
COPY app/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Final minimal image
FROM python:3.11-slim

WORKDIR /app

# Create a non-root user and group
RUN addgroup --system appgroup && adduser --system --group appuser

# Copy installed dependencies from the builder stage
COPY --from=builder /install /usr/local

# Copy application code
COPY app/ .

# Ensure the non-root user owns the application files
RUN chown -R appuser:appgroup /app

# Switch to the non-root user
USER appuser

# Expose port
EXPOSE 8000

# Run the FastAPI application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
