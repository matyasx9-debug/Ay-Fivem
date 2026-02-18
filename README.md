# AY Developer Panel (FiveM)

Modern, NUI-alapú fejlesztői panel FiveM szerverekhez, hogy gyorsabb legyen a tesztelés és a fejlesztés.

## Funkciók

- Új, modern ESX-stílusú dashboard dizájn (kompakt + görgethető, eredeti kék árnyalatokkal)
- Kategorizált, görgethető és kompakt panel nézet
- Noclip állítható sebességgel
- God mode
- Pozíció fagyasztása
- Waypoint teleport + preset teleport pontok
- Koordináta másolás (vec3 / vec4)
- Jármű spawn / javítás / törlés
- Idő és időjárás kezelés
- játékos admin eszközök (TP playerhez, bring, kick, revive target)
- ESX admin funkciók (item adás/elvétel, money/bank/black_money, setjob)
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
- Koordináta másolás parancs: `/copycoords` (alapértelmezett: vec4, vagy `/copycoords vec3`)

## Konfiguráció

A fő beállítások a `devpanel/config.lua` fájlban vannak:

- panel gomb / parancs
- jogosultság kezelés (ACE: `aydevpanel.use`)
- noclip sebesség határok
- időjárás lista
- teleport presetek
- /copycoords formátum (vec3/vec4)
