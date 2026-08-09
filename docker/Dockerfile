FROM node:22-alpine
WORKDIR /app
COPY js/package.json js/package.json
COPY js/src js/src
COPY js/bin js/bin
COPY js/LICENSE js/LICENSE
COPY js/DISCLAIMER.md js/DISCLAIMER.md
COPY js/README.md js/README.md
WORKDIR /app/js
RUN npm install --omit=dev
LABEL org.opencontainers.image.title="Futbol Libre Hoy"
LABEL org.opencontainers.image.description="CLI for today's football fixtures from Futbol Libre"
LABEL org.opencontainers.image.url="https://verfutbollibre.net"
LABEL org.opencontainers.image.source="https://github.com/nazzal12/ver-fubtol-libre-pckgs"
LABEL org.opencontainers.image.licenses="MIT"
ENTRYPOINT ["node", "bin/cli.js"]
