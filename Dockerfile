FROM nixos/nix:2.23.4 as builder

COPY . .

ENV COCKPIT_API_URL=${COCKPIT_API_URL}
ENV COCKPIT_API_TOKEN=${COCKPIT_API_TOKEN}

RUN nix-shell buildWebsite.nix --run "buildWebsite"

FROM nginx:alpine as runner

COPY --from=builder /dist /usr/share/nginx/html