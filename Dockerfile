FROM cm2network/steamcmd:latest

USER root
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y lib32gcc-s1 wget lib32stdc++6 wine wine32 curl xvfb \
    winbind cabextract unzip p7zip-full

USER steam
# Create directory structure without downloading yet
RUN mkdir -p /home/steam/postal2/overrides /home/steam/postal2/System
WORKDIR /home/steam/postal2

# Copy our entrypoint script
COPY --chown=steam:steam entrypoint.sh /home/steam/entrypoint.sh
RUN chmod +x /home/steam/entrypoint.sh

EXPOSE 7777/udp
EXPOSE 7778/udp
EXPOSE 7787/udp
EXPOSE 27900/tcp

ENTRYPOINT ["/home/steam/entrypoint.sh"]