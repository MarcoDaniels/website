FROM nixos/nix:2.23.4 as builder

COPY . .

RUN nix-shell buildWebsite.nix --run "buildWebsite"

FROM nginx:alpine as runner

COPY --from=builder /dist /usr/share/nginx/html