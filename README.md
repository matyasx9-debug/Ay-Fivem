# AY Developer Panel (FiveM)

Modern, NUI-alapú fejlesztői panel FiveM szerverekhez, hogy gyorsabb legyen a tesztelés és a fejlesztés.

## Funkciók

- Noclip állítható sebességgel
- God mode
- Pozíció fagyasztása
- Waypoint teleport + preset teleport pontok
- Koordináta másolás (vec3 / vec4)
- Jármű spawn / javítás / törlés
- Idő és időjárás kezelés
- ACE jogosultság alapú védelem

## Telepítés

1. Másold be az `ay_devpanel` mappát a `resources` könyvtárba.
2. `server.cfg`:

```cfg
ensure ay_devpanel
add_ace group.admin aydevpanel.use allow
add_principal identifier.fivem:YOUR_ID group.admin
```

3. Indítsd újra a szervert.

## Használat

- Panel megnyitás: `F10` vagy `/devpanel`
- Koordináta másolás parancs: `/copycoords`

## Konfiguráció

A fő beállítások a `shared/config.lua` fájlban vannak:

- panel gomb / parancs
- jogosultság kezelés
- noclip sebesség határok
- időjárás lista
- teleport presetek
