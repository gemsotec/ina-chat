# INA Chat

Fork van [mattermost/mattermost](https://github.com/mattermost/mattermost).

## Variant

Mattermost Team Edition, gebouwd zonder de build tags `enterprise`, `sourceavailable` en
`requirefips`.

## Wijzigingen tegenover upstream

| Bestand | Wijziging |
| --- | --- |
| `server/channels/app/limits.go` | `maxUsersLimit` en `maxUsersHardLimit` op `0` |
| `Dockerfile` | Toegevoegd |
| `.dockerignore` | Toegevoegd |
| `INA.md` | Toegevoegd |
| `server/go.mod`, `server/public/go.mod` | `golang.org/x/net`, `golang.org/x/crypto` (max. v0.58.0: v0.59.0 heeft geen `openpgp` meer), `google.golang.org/grpc` en `github.com/klauspost/compress` verhoogd voor CVE-fixes |

## Versies

Elke releaselijn heeft een branch `ina/<major.minor>`. Nieuwe upstream-patchversies worden
erin gemerged en krijgen een tag `ina/<versie>`. Eigen wijzigingen bovenop dezelfde upstream-versie
krijgen een volgnummer: `ina/<versie>-1`, `ina/<versie>-2`, …

De `Dockerfile` vertrekt van de image `mattermost/mattermost-team-edition` en past die aan:

- `mattermost` en `mmctl` worden zelf gebouwd met de nieuwste Go-patchversie en de verhoogde dependencies;
- de prepackaged plugins worden verwijderd: INA gebruikt ze niet
  (`MM_PLUGINSETTINGS_AUTOMATICPREPACKAGEDPLUGINS=false`) en ze bevatten oude Go-dependencies;
- `libssl3` wordt vervangen door de nieuwste versie uit Debian 12.

Omdat die image distroless is (geen shell), gebeurt dat in een tussenstage. De laatste stage
`FROM scratch` neemt de image-config van upstream over (`ENV`, `USER`, `VOLUME`, `HEALTHCHECK`, …).
Controleer bij elke nieuwe upstream-versie met `docker image inspect` of die config nog klopt.

## Bouwen

```bash
docker build --platform linux/amd64 -t ina-chat .
```

## Licentie

AGPL v3, zie [LICENSE.txt](LICENSE.txt).
