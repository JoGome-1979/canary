# Premium loot

`monster.loot` keeps its existing roll. `monster.lootpremium` adds a separate
roll only when the corpse owner, or an eligible member of that owner's party,
has Premium Account. An eligible player must also pass `canReceiveLoot()`.
The party leader is included. There is currently no additional distance,
combat participation, or shared-experience filter.

```lua
monster.lootpremium = {
    { name = "gold coin", chance = 100000, minCount = 5, maxCount = 10 },
    { name = "bag", chance = 10000, child = {
        { name = "platinum coin", chance = 100000, maxCount = 2 },
    } },
}
```

The example is documentation only; no monster is configured by this change.
Registration follows `createLootPremium` -> `addLootPremium` ->
`lootPremiumItems`. The callback reads `getLootPremium()` and uses the normal
chance calculation, with the corpse owner's factor and without Gut Charm.
It rolls once, then divides stack quantities between eligible premium players.
Remainders and indivisible items go to randomly selected recipients. A charged
item is one physical item with its configured charges. Containers and their
rolled contents go together to the container's recipient. Child configuration
is recursive for premium loot; ordinary loot registration is unchanged.

Items stay in the corpse. Each item receives the `premium_loot_owner` custom
attribute with its recipient's GUID before insertion. Native code checks the
item, its ancestors, and (when collecting/consuming a container) its descendants.
Opening an unreserved shared corpse remains allowed. Movement, exchange,
autoloot/autobank, item actions, and stash processing must honor the reservation.
The reservation is cleared after successful collection into that recipient's
inventory. The item can then be traded normally. Direct action/stash consumption
checks authorization before removing or converting the item.

Both messages are built in `Creature::dropCorpse` after Lua finishes inserting
items, and sent through `Player::sendLootMessage`. `Container::getContentDescription`
uses the actual corpse contents for both: ordinary loot excludes reservations,
and premium loot selects one recipient GUID. Filled containers are represented
by their contents, just like ordinary loot. No premium message is sent for an
empty share.

Normal messages use `MESSAGE_LOOT` (31) and retain party broadcasting. Premium
messages use `MESSAGE_LOOT_PREMIUM` (59) and are sent individually, never
broadcast through the party. Each recipient receives
`Bonificação Premium de ...: ... Sua parte está reservada no corpo.` Lua no
longer sends either notification. Both descriptions preserve the usual
`{itemId|description}` markers consumed by the client's item colorizer.

In `D:/otclient-main/modules/game_textmessage/textmessage.lua`, mode 59 selects
`MessageSettings.lootPremium`, which uses the middle label and Loot console tab.
The current base color is unchanged. The client supports explicit spans in the
form `{text, #RRGGBB}` for multiple colors inside a single message. Do not wrap
the entire item description in a span: its existing item markers must remain
separate to preserve rarity coloring.

## Deployment and validation

The running binary must contain `addLootPremium`, `getLootPremium`, and the native
access checks together. With the old binary the Lua guards skip premium loot and
warn when registering a configured monster. Never activate premium generation
with a binary that exposes its methods but lacks its access checks.

Run `python3 tests/lua/run_premium_loot.py` from the repository root, or use
`lua tests/lua/premium_loot.lua` with Lua 5.3/5.4. The suite runs actual Lua
scripts against mocks, covering registration, party division, charges, duplicate
IDs, nested children, failures, and legacy-method absence. It does not run the
server or validate native code.

Before activation, compile using `docs/building/local-validation.md` and test
in game: free owner, premium owner, mixed party, movement and exchange, opening
the shared corpse, consuming reserved food, using actions on reserved targets,
Stow, autoloot/autobank, and separate normal/premium messages. Test another
recipient's items, a failed transfer, nested containers, and normal trade after
collection. Compilation, restart, and game validation are separate deployment
steps. Restore the dated backup to undo source changes; new files are listed in
the deployment manifest and must be removed separately if rolling back.
