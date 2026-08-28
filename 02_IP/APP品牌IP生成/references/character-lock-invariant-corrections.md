# Character-lock invariant corrections

Use this before generating any raster asset from an approved character lock.

## Invariant matrix

Turn the prose lock into a table before the first image call:

| Field | Exact requirement | Allowed variable | Forbidden drift | Result |
|---|---|---|---|---|
| Countable anatomy | Exact count and shape | None | Extra, missing, branched | PASS / FAIL |
| Identity marks | Exact count, position, color | Stated tolerance only | Relocation or redesign | PASS / FAIL |
| Silhouette | Named geometry and ratio | At most the lock's range | Species or profile change | PASS / FAIL |
| Palette | Exact role per color | Lighting value shift | Swapped primary/secondary roles | PASS / FAIL |
| Limbs and props | Complete and visible | Pose | Missing, fused, added | PASS / FAIL |

Each concept may open one controlled variable such as material or a proportion already allowed by the lock. Repeat every immutable feature in every prompt; do not rely on previous text context.

## Inspect and retry

Inspect each output immediately. A concept with one failed invariant is not an anchor candidate.

Preserve the failed attempt and perform one targeted edit:

```text
Change only <failed invariant>.
Keep <passed composition, identity, palette, material, lighting and layout> unchanged.
```

Treat each requested candidate concept image as one independent asset, even when several concepts are generated as a batch. Allow at most two total attempts for each candidate asset. If its targeted edit still fails, mark that candidate missing and stop any downstream asset that depends on it. Never silently replace it with a different character.

Select one passing concept as `character-anchor.png`. Every icon, launch screen, action sheet and UI direction must include that anchor as the only identity reference.
