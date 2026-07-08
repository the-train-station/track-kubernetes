# Lab 11: Build and Run Your First Container

Use this lab to build a minimal Node.js HTTP server into a Docker image, run it, inspect it, persist data with a volume, and push it to a registry.

## Prerequisites

- Docker Desktop or Docker Engine installed and running
- A shell (`bash`, `zsh`, etc.)
- Optional: a free [Docker Hub](https://hub.docker.com/) account for the registry push step

## Exercise Flow

### 1. Build the Image

```bash
docker build -t my-first-image .
```

Expected observation: the build completes in a handful of steps (`FROM`, `WORKDIR`, `COPY`, `EXPOSE`, `CMD`), and `docker images` lists `my-first-image` with a recent `CREATED` timestamp.

### 2. Run the Container with a Port Mapping

```bash
docker run -d -p 3000:3000 --name my-first-container my-first-image
```

Expected observation: Docker prints a container ID and returns immediately (`-d` runs it detached). If you omit `-p 3000:3000`, the container still starts, but nothing on your host can reach port 3000 — the single most common beginner Docker mistake.

### 3. Verify It's Reachable

```bash
curl http://localhost:3000
```

Expected observation: the response body is `Hello from your first container!`. If this hangs or refuses the connection, check that the port mapping in step 2 was applied (`docker port my-first-container`).

### 4. Inspect the Running Container

```bash
docker ps
```

Expected observation: `my-first-container` is listed with `STATUS` showing `Up` and `PORTS` showing `0.0.0.0:3000->3000/tcp`.

### 5. Check the Logs

```bash
docker logs my-first-container
```

Expected observation: the log line `Server running at http://0.0.0.0:3000/` printed at startup, plus nothing else unless you sent more requests.

### 6. Open a Shell Inside the Container

```bash
docker exec -it my-first-container sh
ls /app
cat /app/index.js
exit
```

Expected observation: you land inside the container's filesystem (Alpine images use `sh`, not `bash`, by default), and `/app` contains only `index.js` — proof the image contains exactly what the `Dockerfile` copied in, nothing from your host beyond that.

### 7. Try a Bind Mount

Stop the first container, then run a second one with your local `lab/` directory mounted over `/app` so edits on the host are visible inside the container without rebuilding:

```bash
docker stop my-first-container
docker run -d -p 3000:3000 --name my-first-container-dev \
  -v "$(pwd):/app" my-first-image
```

Expected observation: `docker exec my-first-container-dev ls /app` shows your host's `lab/` files, including `Dockerfile` and `lab/README.md` — a bind mount overlays the host path directly, which is why it's the standard pattern for local development but the wrong pattern for production images.

### 8. Try a Named Volume

Named volumes are Docker-managed storage, useful for data you want to persist independently of any specific host path (databases, uploaded files, etc.):

```bash
docker volume create my-first-data
docker run -d -p 3001:3000 --name my-first-container-vol \
  -v my-first-data:/data my-first-image
docker volume inspect my-first-data
```

Expected observation: `docker volume inspect` shows a `Mountpoint` managed by Docker, not a path from your working directory. The volume survives even if `my-first-container-vol` is removed.

### 9. Tag and Push to a Registry

```bash
docker tag my-first-image <your-dockerhub-username>/my-first-image:1.0
docker login
docker push <your-dockerhub-username>/my-first-image:1.0
```

Expected observation: the push streams each image layer and finishes with a digest. The image is now pullable from anywhere with `docker pull <your-dockerhub-username>/my-first-image:1.0`. Docker Hub is the default here; GitHub Container Registry (GHCR) and Amazon ECR work the same way — `tag`, authenticate, `push` — just with a different registry hostname in the tag.

### 10. Clean Up

```bash
docker stop my-first-container-dev my-first-container-vol
docker rm my-first-container my-first-container-dev my-first-container-vol
docker volume rm my-first-data
docker rmi my-first-image <your-dockerhub-username>/my-first-image:1.0
```

Expected observation: `docker ps -a` no longer lists any `my-first-container*` entries, and `docker images` no longer lists `my-first-image`.

## Deliverable

Submit a short command worksheet showing the build, the run with port mapping, the successful `curl`, one `docker exec` inspection, one volume example (bind mount or named volume), and the final cleanup — each with the command and the observation you saw.
