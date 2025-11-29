##  Deploy Backend to Free Hosting — Step by Step (With Optional Private DockerHub Image)

### **Push Docker Image to DockerHub (Private, Optional)**

1. **Login to DockerHub:**

```bash
docker login
```

* Enter your DockerHub username and password.

2. **Tag Your Local Docker Image:**

```bash
docker tag welding-backend yourdockerhubusername/welding-backend:latest
```

3. **Push Image to DockerHub:**

```bash
docker push yourdockerhubusername/welding-backend:latest
```

* Make sure the repository on DockerHub is set to  **Private.**

> - if you changes something and need rebuild and deploy the new version
>
>   - docker build -t ahmedferganey/welding-backend:v1.1 .
>   - docker tag ahmedferganey/welding-backend:v1.1 ahmedferganey/welding-backend:latest
>   - docker push ahmedferganey/welding-backend:v1.1
>   - docker push ahmedferganey/welding-backend:latest
>   - redeploy on Render:
>
>   If Render is set to **Auto-Deploy**, it will automatically detect the new Docker image and redeploy your service.
>
>   If Auto-Deploy is **disabled**, you can manually deploy:
>
>   1. Go to **Render Dashboard**
>   2. Open **Your Web Service**
>   3. Click **Deploy**
>   4. Select **Deploy Latest Image**
>
>   Render will then pull the updated image:

### **Option 1: Render.com (Free Tier)**

#### **Using GitHub Repository**

1. **Sign Up / Login:**
   * Go to [Render.com](https://render.com/) and create a free account.
2. **Create a New Web Service:**
   * Click on  **New → Web Service** .
   * Connect your GitHub account and select the repository containing your backend.
3. **Configure Service:**
   * Choose **Docker** as the environment.
   * Name your service (e.g., `welding-backend`).
   * Set **Branch** to deploy (usually `main`).
4. **Set Environment Variables:**
   * Scroll to **Environment** section.
   * Add variables from your `.env` file:
     * `FRONTEND_URL=https://your-project.firebaseapp.com`
     * `DATA_DIR=data`
5. **Start Command:**

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

6. **Deploy:**

   * Click  **Create Web Service** .
   * Render will build the Docker container and deploy your backend.
7. **Access:**

   * Render provides a public URL, e.g., `https://welding-backend.onrender.com`.

   > - https://welding-backend-v1-0.onrender.com/
   >

#### **Using Private DockerHub Image (Optional)**

1. **Create Web Service:**
   * Click  **New → Web Service** , select  **Docker Image** .
2. **Private Image Authentication:**
   * Provide DockerHub username and password/token.
   * Enter the image name, e.g., `yourdockerhubusername/welding-backend:latest`.
3. **Set Environment Variables & Start Command:**
   * Same as above.
4. **Deploy & Access:**
   * Render pulls the private Docker image and provides a public URL.
5. **Excel Storage Options:**
   * **Static Files:** Include small Excel files in the `data/` folder.
   * **Dynamic Uploads:** Use Firebase Storage or Google Drive API for persistent storage since Render’s free-tier containers have ephemeral storage.

---

### **Option 2: Railway.app (Free Tier)**

1. **Sign Up / Login:**
   * Go to [Railway.app](https://railway.app/) and create a free account.
2. **Create a New Project:**
   * Click **New Project → Deploy from GitHub** or choose Docker deployment.
3. **Configure Deployment:**
   * Railway detects `Dockerfile` automatically.
   * Add environment variables:
     * `FRONTEND_URL=https://your-project.firebaseapp.com`
     * `DATA_DIR=data`
4. **Set Start Command:**

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

5. **Deploy:**
   * Click  **Deploy** . Railway will build the container or pull the private Docker image (if configured).
6. **Access:**
   * Railway provides a public URL, e.g., `https://welding-backend.up.railway.app`.
7. **Excel Storage Options:**
   * Because Railway free containers have ephemeral storage, store Excel files in:
     * Firebase Storage (1 GB free) or
     * Google Drive API (15 GB free) for persistence.

---

✅ **Notes:**

* Both Render and Railway free tiers automatically provide HTTPS.
* Ensure your Flutter frontend URL matches `FRONTEND_URL` to avoid CORS issues.
* For dynamic Excel uploads, always rely on free cloud storage rather than container storage.
* Private Docker images keep your code and data secure while enabling deployment to Render or Railway.

---

##  Flutter Web Frontend Deployment (Free)

1. Build Flutter web:

```bash
cd frontend
flutter build web
flutter build web --release

```

* Output: `frontend/build/web/`

2. Initialize Firebase Hosting:

```bash
firebase login
firebase init hosting
```

* Choose existing project, public directory: `frontend/build/web`, SPA: Yes

3. Backend URL in Flutter:

```dart
final backendUrl = "https://welding-backend.onrender.com/analytics/workorders";
```

4. Deploy:

```bash
firebase deploy
```

> Firebase Hosting automatically provides HTTPS. CORS now only allows your Firebase domain.

---

##  Excel Storage (Free Options)

* **Option 1:** Keep small files inside backend repo (`data/`) for testing or prototyping.
* **Option 2:** Upload to **Firebase Storage** (1 GB free) via FastAPI endpoint.
* **Option 3:** Use **Google Drive API** (15 GB free) for cloud backups.

> Ensures persistent storage even if backend container resets.

---
