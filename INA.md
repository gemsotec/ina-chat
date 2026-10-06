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
| `INA.md` | Toegevoegd |

## Versies

Elke releaselijn heeft een branch `ina/<major.minor>`. Nieuwe upstream-patchversies worden
erin gemerged en krijgen een tag `ina/<versie>`.

## Bouwen

```bash
docker build --platform linux/amd64 -t ina-chat .
```

## Licentie

AGPL v3, zie [LICENSE.txt](LICENSE.txt).
