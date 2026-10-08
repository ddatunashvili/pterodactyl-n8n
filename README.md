# pterodactyl-n8n

[n8n](https://n8n.io) packaged for Pterodactyl / Wings.

- Image: `ghcr.io/ddatunashvili/pterodactyl-n8n:latest`, built from `n8nio/n8n:2.43.2`
- Egg: `egg-n8n.json`

The image runs as Wings' user (uid 988), keeps all n8n data in the server
volume (`/home/container/.n8n`), listens on the server's allocated port, and
exits when n8n exits. Every push to `main` boots the image the way Wings does
(its uid, its dropped capabilities, no-new-privileges, a tty) and checks
`/healthz` before anything is published.

## Use

1. Admin → Nests → Import Egg → `egg-n8n.json`.
2. Create a server: 1 GB RAM or more, one allocation.
3. Start it and open `http://<node>:<port>`; create the owner account.

Behind an HTTPS proxy, set `N8N_HOST`, `WEBHOOK_URL`, `N8N_PROTOCOL=https`
and `N8N_SECURE_COOKIE=true`.

## Licence

n8n is under the [Sustainable Use License](https://docs.n8n.io/sustainable-use-license/),
which restricts offering n8n to third parties as a paid hosted service.
Check it before selling this.
