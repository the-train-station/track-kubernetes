---
title: "Docker Fundamentals: Build and Run Your First Container"
type: lab
difficulty: beginner
tier: free
tags: ["docker", "containers", "images", "dockerfile"]
---

# Docker Fundamentals: Build and Run Your First Container

## Overview

Docker is a containerization platform that packages an application together with everything it needs to run — code, runtime, system libraries, and configuration — into a single, portable unit called an image. An image is a static, immutable blueprint. A container is a running instance of that image: an isolated process with its own filesystem view, network namespace, and process tree, launched from an image the same way a running program is launched from a compiled binary. Understanding that distinction — image as blueprint, container as instance — is the single most important mental model in this lesson, because almost every Docker command either builds an image or does something to a container.

This matters because containers solve a problem every team eventually runs into: "it works on my machine." By bundling the runtime and dependencies with the code, a container behaves the same way on a laptop, in CI, and in production. That portability is what makes containers scalable — you can run ten identical copies of the same image behind a load balancer without configuration drift between them — and it is also a meaningful security boundary, since a container's filesystem and process namespace are isolated from the host and from other containers by default.

For a beginner, this lesson is the prerequisite the rest of this track assumes you already have. Every other lesson in this Kubernetes track — Helm charts, Kustomize overlays, cluster tutorials — starts from the assumption that you already know what an image is, how to build one, and how to run it with the right flags. This lesson fills that gap. By the end, you will have written a Dockerfile from scratch, built an image, run it correctly (including the port-mapping step beginners most often skip), inspected a running container, worked with both bind mounts and named volumes, and pushed an image to a registry — the full loop you will use constantly once you move on to orchestrating containers with Kubernetes.

## Prerequisites

- Docker Desktop (macOS/Windows) or Docker Engine (Linux) installed and running
- Basic command-line comfort (running commands, navigating directories)
- A text editor
- Optional: a free [Docker Hub](https://hub.docker.com/) account for the registry push step
- No prior container or Kubernetes experience required

## Key Takeaways

1. **An image is a blueprint; a container is a running instance** - You build an image once and can run any number of independent containers from it, each with its own isolated filesystem and process space.
2. **A Dockerfile is a declarative build recipe** - Each instruction (`FROM`, `WORKDIR`, `COPY`, `CMD`) adds a layer, and getting the instructions right — including exact filenames — is what separates a build that works from one that fails silently or crashes at runtime.
3. **Port mapping is what makes a container reachable from your host** - Without `-p <host-port>:<container-port>` on `docker run`, the app inside the container is running but completely unreachable from outside it — the most common mistake beginners make.
4. **Pin your base image tags** - `FROM node:latest` is a bad practice because "latest" is a moving target: your build can silently pick up a different Node.js version tomorrow than it did today. Pinning to something like `node:20-alpine` gives you a reproducible, smaller image, the same immutable-artifact thinking behind tools like Packer for VM images.
5. **Registries are how you distribute what you built** - `docker tag`, `docker login`, and `docker push` move an image from your machine to a shared registry (Docker Hub, GHCR, ECR) so it can be pulled and run anywhere, including by a Kubernetes cluster later in this track.

## How to Use

### Step 1: Understand images vs. containers before you write any code

Before touching a Dockerfile, get the vocabulary straight:

- An **image** is a read-only, layered filesystem plus metadata (default command, exposed ports, working directory). It does not run anything by itself.
- A **container** is a writable layer on top of an image, plus an isolated process. `docker run` creates and starts one.
- You can create many containers from one image, and each one is independent — stopping or deleting a container never touches the image it came from.

Keep this in mind as you work: everything below either changes the image (build) or does something to a container (run, stop, exec, inspect).

### Step 2: Write the Dockerfile

Look at `lab/index.js`: a minimal Node.js HTTP server built on the standard library's `http.createServer`, listening on port 3000. Now look at `lab/Dockerfile`:

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY index.js .
EXPOSE 3000
CMD ["node", "index.js"]
```

Pay attention to:

- **`FROM node:20-alpine`** — a pinned major version on a small Alpine-based image, not `node:latest`. Immutable, reproducible base images matter for the same reason pinned AMIs matter when building machine images with tools like Packer: you want to know exactly what you're shipping.
- **`COPY index.js .`** — the filename has to match exactly. A one-character typo here (a missing dot, a missing extension) is a real, common failure mode: the build either fails outright with "file not found" or, worse, succeeds and then crashes at container startup when `CMD` tries to run a file that was never copied in.
- **`EXPOSE 3000`** — documents which port the container listens on. It's metadata, not a mapping — it does not, by itself, make the port reachable from your host.
- **`CMD ["node", "index.js"]`** — the default command run when a container starts from this image. Must reference the exact same filename you copied in.

### Step 3: Build the image

```bash
cd lab
docker build -t my-first-image .
```

`-t my-first-image` tags the image with a human-readable name instead of leaving you with only a hash. Run `docker images` afterward and confirm `my-first-image` is listed.

### Step 4: Run the container with a port mapping

```bash
docker run -d -p 3000:3000 --name my-first-container my-first-image
```

- `-d` runs the container detached (in the background) so you get your terminal back.
- `-p 3000:3000` maps port 3000 on your host to port 3000 inside the container. **This is the flag beginners forget.** Without it, the server is running fine inside the container's own network namespace, but nothing outside the container — including `curl` on your host — can reach it. Confirm the app works with `curl http://localhost:3000`.

### Step 5: Inspect the running container

Three commands cover almost everything you need day to day:

- `docker ps` — lists running containers, their status, and their port mappings. `docker ps -a` includes stopped ones too.
- `docker logs my-first-container` — shows everything the process printed to stdout/stderr, your first stop when something isn't behaving.
- `docker exec -it my-first-container sh` — opens an interactive shell inside the running container. Alpine-based images ship `sh`, not `bash`, by default. Use this to confirm exactly what's on disk inside the container (`ls /app`) versus what you expect.

### Step 6: Work with volumes

By default, anything written inside a container's writable layer disappears when the container is removed. Two mechanisms fix that, and they solve different problems:

- **Bind mount** (`-v $(pwd):/app`) — maps a specific path on your host directly into the container. Great for local development, since edits on your host are immediately visible inside the container without rebuilding. Not appropriate for production images, since it depends on a host path that won't exist the same way on another machine.
- **Named volume** (`-v my-first-data:/data`) — Docker-managed storage with a name instead of a host path. Data persists across container restarts and removals, and Docker handles where it actually lives on disk. This is the pattern for anything you want to persist independently of any one host, such as database data.

`lab/README.md` walks through both with commands and expected output.

### Step 7: Tag and push to a registry

An image only on your laptop is useless to anyone else. Push it:

```bash
docker tag my-first-image <your-dockerhub-username>/my-first-image:1.0
docker login
docker push <your-dockerhub-username>/my-first-image:1.0
```

Docker Hub is the default target used in this lab because it requires no extra setup beyond a free account. GitHub Container Registry (GHCR) and Amazon ECR follow the identical `tag` / authenticate / `push` pattern — only the registry hostname in the tag changes. This is also exactly what a Kubernetes cluster will do later in this track: pull a named, tagged image from a registry to run your workload.

## Deliverable

Build a short artifact bundle for one completed run of this lab: the exact `docker build` and `docker run` commands you used from `lab/Dockerfile`, the `curl` output proving the port mapping worked, one `docker exec` inspection showing the container's filesystem, one volume example (bind mount or named volume) with its inspect output, and the final `docker tag`/`docker push` output (or a note if you skipped the registry step). Reference `lab/index.js` and `lab/Dockerfile` directly rather than retyping them.

## Practice Notes

- Run hands-on work in a sandbox and keep a short lab log with commands, screenshots or outputs, resources created, cleanup steps, and the one pattern you would reuse in production.
- Connect the lesson to cluster operations by noting the workload, namespace, RBAC boundary, rollout behavior, observability signal, and failure mode it helps you manage.
- Completion checkpoint: you can adapt the pattern to a second environment, identify its tradeoffs, and explain the operational risks it introduces.
- Portfolio artifact: create a short note titled "Docker Fundamentals: Build and Run Your First Container - applied takeaway" with the scenario you used, the decision you made, and one follow-up task you would assign to yourself or a team.

## Related Resources

- [Docker Documentation](https://docs.docker.com/) - Primary reference for the Docker CLI, Dockerfile syntax, and image/container lifecycle
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) - Official guidance on layering, caching, and image size, including why pinned base image tags matter
- [Docker Volumes](https://docs.docker.com/storage/volumes/) - Deeper reference on bind mounts vs. named volumes and when to use each
- [Docker Hub](https://hub.docker.com/) - Default public registry used for the tag/push step in this lab
- [Node.js Docker Best Practices](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md) - Practical guidance specific to containerizing Node.js apps, including networking gotchas

## Estimated Time

- **Reading the Dockerfile and understanding each instruction**: 10-15 minutes
- **Building the image and running it with a correct port mapping**: 15-20 minutes
- **Inspecting the container with `ps`, `logs`, and `exec`**: 10-15 minutes
- **Working through the bind mount and named volume examples**: 15-20 minutes
- **Tagging and pushing to a registry**: 10-15 minutes
- **Total for this lesson**: ~1-1.5 hours for a full first pass including cleanup
