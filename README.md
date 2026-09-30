# AY Developer Panel — FiveM

Modern, NUI-alapú admin/developer panel FiveM szerverekhez.

## Fő funkciók

- Admin rank + ACE alapú jogosultságkezelés
- Duty rendszer és ranghoz kötött outfit
- Player tools: godmode, heal, armor, revive, invisible, noclip, super jump, fast run
- Teleport: waypoint, preset, saját koordináta, játékoshoz teleport / bring
- Vehicle tools: spawn, delete, repair, fuel, flip, max upgrade, engine force
- World tools: weather, time, freeze time, blackout, area clear
- Player moderation: kick és globális announcement
- Developer tools: ped/object spawn, entity debug, célzott entity törlés, no ragdoll
- `/copycoords` vec3 / vec4 támogatással
- Magyar / angol UI szövegek
- Discord webhook audit log támogatás
- Szerveroldali jogosultság- és bemenetellenőrzés a hálózati admin műveleteknél
- CI ellenőrzés Lua + JavaScript szintaxisra

## Telepítés

1. Másold a `devpanel` mappát a FiveM `resources` könyvtárába.
2. A `server.cfg` fájlban:

```cfg
ensure ay_devpanel
add_ace group.admin aydevpanel.use allow
add_principal identifier.license:YOUR_LICENSE group.admin
```

3. Indítsd újra a resource-t:

```text
restart ay_devpanel
```

## Használat

- Panel: `F10` vagy `/devpanel`
- Duty: `/dutyay`
- Koordináta: `/copycoords`
- Vec3: `/copycoords vec3`
- Vec4: `/copycoords vec4`
- Rang beállítása Controller vagy konzol által: `/setadminay [id] [rank]`

## Rangok

A rangok a `devpanel/config.lua` fájlban módosíthatók.

- 1–4: admin szintek
- 5: Admin Controller
- 6: Developer

A tényleges jogosultságokat a `Config.ActionRanks` szabályozza.

## Biztonság

A panel NUI-ja önmagában nem tekinthető biztonsági határnak. A hálózaton érkező érzékeny admin műveleteket a `server.lua` újra ellenőrzi:

- rank
- panel ACE
- duty állapot
- target player
- weather/time értékek
- announcement/kick reason hossz
- ismeretlen admin actionök

A webhook URL-t ne commitold nyilvános repositoryba, ha titkos vagy személyes endpointot használsz.

## Fejlesztés

A GitHub Actions CI ellenőrzi:

- Lua szintaxist
- JavaScript szintaxist
- szükséges resource fájlok jelenlétét

## Fájlstruktúra

```text
devpanel/
├── client.lua
├── config.lua
├── fxmanifest.lua
├── server.lua
└── html/
    ├── app.js
    ├── index.html
    └── style.css
```
