# ddignac-homelab - contexte d'architecture (agent)

## Objectif historique

Le homelab expose deux types de services:

- Services publics: accessibles depuis Internet.
- Services prives: accessibles uniquement depuis le LAN et le VPN.

Le controle d'acces des services prives est principalement fait dans Traefik via des middlewares de filtrage IP (LAN + VPN).

## Evolution recente

Cloudflare Tunnel a ete ajoute pour fiabiliser l'exposition des services publics quand l'IP WAN change (fibre / backup 4G).

Depuis ce changement, des erreurs TLS/HSTS intermittentes apparaissent en LAN sur certains FQDN (ex: auth.ddignac.fr, photos.ddignac.fr).

## Diagnostic retenu

Ce depot utilise de fait un split-DNS, meme si non nomme explicitement:

- DNS local (Pi-hole): les FQDN ddignac.fr resolvent vers l'IP LAN du serveur (ex: 192.168.0.2).
- DNS public: les memes FQDN resolvent vers Cloudflare/public.

Le probleme survient quand un client LAN peut consulter tantot le DNS local, tantot un DNS public (DNS secondaire, DoH navigateur, cache/ordre de resolution).

Consequences:

- Le meme FQDN peut suivre deux chemins TLS differents.
- HSTS n'est pas la cause racine mais rend l'erreur bloquante (pas d'exception manuelle possible).

## Regles d'architecture a conserver

- Les clients LAN/VPN doivent voir un seul DNS logique, deterministic.
- Le fallback DNS public est autorise, mais au niveau du resolveur central (routeur/forwarder), pas sur les clients.
- Pour les services prives, conserver un controle d'acces en profondeur:
	- couche reseau (DNS/local routing),
	- couche reverse proxy (IPAllowList Traefik),
	- couche applicative (authentik ou auth applicative).

## Pattern recommande

1. DHCP distribue un seul DNS aux clients (idealement le routeur LAN, ou Pi-hole unique).
2. Le routeur/forwarder gere la chaine de secours (Pi-hole primaire, resolvers publics en secours).
3. Les clients ne doivent pas avoir de DNS public direct en secondaire.
4. Sur Firefox, desactiver DoH sur le LAN (ou exclure ddignac.fr), pour eviter de contourner le DNS local.

## Decision sur les noms DNS

Deux strategies valides:

- Strategie A (conserver les memes FQDN public/prive):
	- impose un DNS client strictement unique,
	- sinon comportements intermittents possibles.

- Strategie B (separer les noms prives):
	- ex: service.home.arpa / *.lan interne,
	- evite les ambiguites public vs prive,
	- reduit les risques HSTS/caches sur les FQDN publics.

## Runbook de verification rapide

1. DNS LAN deterministic
	 - `dig +short photos.ddignac.fr A` (repete) doit donner toujours la meme cible LAN en local.
2. Certificat stable
	 - `echo | openssl s_client -connect photos.ddignac.fr:443 -servername photos.ddignac.fr 2>/dev/null | openssl x509 -noout -subject -issuer`
3. Controle d'acces prive
	 - verifier qu'un client hors LAN/VPN ne passe pas les middlewares de whitelist IP.

## Notes de prudence

- Cloudflare Tunnel est tres adapte aux services publics.
- Pour les services prives, eviter de dependre du chemin public si l'intention est LAN/VPN only.
- Le filtrage IP Traefik seul ne remplace pas une strategie DNS/routage coherente.

