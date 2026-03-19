# ddignac-homelab
Configuration et documentation de la stack docker du homelab Ddignac


## Networks

Liste des networks et leur commande de création

```
docker network create --driver=bridge --subnet=10.10.0.0/24 admin_net
docker network create --driver=bridge --subnet=10.30.0.0/24 dmz_net
docker network create --driver=bridge --subnet=10.40.0.0/24 db_mariadb_net
docker network create --driver=bridge --subnet=10.41.0.0/24 db_redis_net
docker network create --driver=bridge --subnet=10.42.0.0/24 db_postgresql_net
```

## Core

### Traefik
Traefik doit être lancé manuellement hors Docker car c'est lui qui expose le dashboard Portainer

Utilisation du dnsChallenge plus complet que httpChallenge pour ddignac.fr

A permis d'avoir un certificat quand traefik en migration. ports = 444/81

HttpChallenge ne permet que sur les ports par défaut HTTP/HTTPS

### Portainer


### VPN / DNS (wireguard + Pihole + unbound)

- VPN en mode host pour que les clients aient accès au réseau local de la maison
    - utilisation du DNS exposé directement via l'host : 192.168.0.2:53 car impossible via réseau Docker
- DNS en mode bridge : Utilisation du DNS pour le LAN comme pour le VPN, on utilise donc l'IP hôte à la place de l'IP docker  
    - exposition sur le port 53 du serveur (désactivation de systemd-resolved)
    - ajout `listeningMode = "ALL"` car le LAN `192.168.0.0/24` n'est pas le réseau interne docker [cf doc](https://docs.pi-hole.net/ftldns/configfile/#listeningmode)
    - définir `dns.reply.host.IPv4 : 192.168.0.2`sur l'IP hôte pour que pihole renvoie cette IP lors d'une requpete DNS vers son hostname `dns.ddignac.fr` 