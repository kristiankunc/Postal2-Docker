# Dockerized POSTAL 2 dedicated server

This repository contains a Docker setup for running a dedicated server for the game POSTAL 2 using the [NicksCoop](https://www.moddb.com/mods/nickscoop-postal-2-coop)

[![Build and Push Docker Image](https://github.com/kristiankunc/Postal2-Docker/actions/workflows/build.yml/badge.svg)](https://github.com/kristiankunc/Postal2-Docker/actions/workflows/build.yml)

## Setup

### POSTAL 2 game files

As of NicksCoop `v1.4.3`, POSTAL 2 Beta `5025` is required. I have only tested with the Steam version.

### Pulling the image

```bash
docker pull kristn1/postal2-server:latest
```

### Preparing the game files

Copy the vanilla game files (excluding NicksCoop files) into any directory locally, this guide assumes `./base` relative to the `docker-compose.yml` file.

### Configuration

Create a `.env` file in the same directory as `docker-compose.yml` with the following variables

```env
POSTAL_ADMIN_USERNAME=admin-username
POSTAL_ADMIN_PASSWORD=admin-password
POSTAL_SERVER_PASSWORD=game-server-password
```

Modify these values to your liking.

### Running the image

Following the config specified in [docker-compose.yml](docker-compose.yml), you can use it to directly run the server as a compose stack

```bash
docker-compose up -d
```

Optionally, you can run it as a standalone container directly

```bash
docker run -d \
  --name postal2-server \
  --env-file .env \
  -v postal2-data:/home/dude/game \
  -v ./base:/tmp/postal2-base:ro \ # Replace base with your game files directory if needed
  -p 7777:7777/udp \
  -p 7778:7778/udp \
  -p 7787:7787/udp \
  -p 27900:27900/tcp \
  postal2-server:latest
```

That's it! You should now have a running POSTAL 2 dedicated server with NicksCoop.

## Background info

All the magic happens in the [entrypoint.sh](entrypoint.sh) locally as I can not distribute the game/mod files.
The script does the following:

1) Copies all game files
2) Downloads and applies the NicksCoop mod, this overrides some of the game files
3) Downloads the recommended `Postal2.ini` for Linux and overrides the password and admin credentials
4) Configures Wine
5) Starts the server

Steps 1, 2 and 3 are only executed once, meaning you can unmount the base game files after the first run and it will still work. To execute any steps again. You can either delete the `postal2-data` volume or manually delete the status dotfiles (`.basegame-imported`, `.overrides-imported`, `.config-imported`) as you please. This will force the appropriate steps to be re-executed on the next start.

## Known limitations and warnings

This setup is not officially supported by anyone I dare to say. I have not yet tested this setup extensively (or at all for that matter). So here's some things to be aware of:

- I have not tested with any additional mods, only vanilla + NicksCoop.
- The setup is pretty clumsy.
- **The authentication does not seem to work properly. This needs to be investigated.**
- Both the mod and the config file are downloaded from third-party sources on runtime which is not ideal.
- The game may have security vulnerabilities, potentially exploitable via the server so running in a non-privileged container is recommended.
