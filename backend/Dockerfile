# -----------------------
# 1️⃣ Base image
# -----------------------
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Working directory inside container
WORKDIR /usr/src/backend

# -----------------------
# 2️⃣ Copy requirements and install
# -----------------------
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# -----------------------
# 3️⃣ Copy backend code
# -----------------------
COPY app ./app

# -----------------------
# 4️⃣ Create uploads directory
# -----------------------
RUN mkdir -p /usr/src/backend/uploads

# -----------------------
# 5️⃣ Expose FastAPI port
# -----------------------
EXPOSE 8000

# -----------------------
# 6️⃣ Run FastAPI
# -----------------------
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
