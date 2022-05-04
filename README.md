# paperMC-arch
papermc docker rewrite

# Getting started
The easiest way for a quick start would be:
```bash
docker run -it \
    -p 25565:25565 \
    -v ~/minecraft/config:/opt/minecraft/config \
    -v ~/minecraft/worlds:/opt/minecraft/worlds \
    -v ~/minecraft/plugins:/opt/minecraft/plugins \
    -v ~/minecraft/data:/opt/minecraft/data \
    -v ~/minecraft/logs:/opt/minecraft/logs \
    ghcr.io/kunihir0/papermc-arch:1.18.2
```

# Tags and Versions
The Docker images are tagged for their Minecraft versions. These versions are currently available:
- ghcr.io/kunihir0/papermc-arch:1.18.2

# Volumes
There are five volumes which are used for:
- Worlds
- Plugins
- Config files (paper.yml, bukkit.yml, spigot.yml, server.properties, commands.yml)
- Data (banned-ips.json, banned-players.json, help.yml, ops.json, permissions.yml, whitelist.json)
- Logs

You can find the mount locations in `docker-compose.yml`.
