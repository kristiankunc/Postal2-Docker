FROM debian:latest


RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y lib32gcc-s1 wget lib32stdc++6 wine wine32 curl xvfb \
    winbind cabextract unzip p7zip-full

RUN useradd -m dude

USER dude

COPY --chown=dude:dude entrypoint.sh /home/dude/entrypoint.sh
RUN chmod +x /home/dude/entrypoint.sh

EXPOSE 7777/udp
EXPOSE 7778/udp
EXPOSE 7787/udp
EXPOSE 27900/tcp

ENTRYPOINT ["/home/dude/entrypoint.sh"]