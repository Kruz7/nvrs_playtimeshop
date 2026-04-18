# nvrs_playtimeshop

Playtime reward shop for **QBCore** with server-side coin logic, Tebex code support, and Turkish / English UI via config.

---

## English

### Requirements

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [oxmysql](https://github.com/overextended/oxmysql)

### Install

1. Put the folder `nvrs_playtimeshop` in your `resources` directory (name must match).
2. Import `nvrs_playtimeshop.sql` into your database.
3. Set `steamApiKey` in `server_config.lua` (optional, for Steam avatars). Leave empty to use the default image.
4. Set `Discord_Webhook` in `server_config.lua` or leave `CHANGE_WEBHOOK` to disable Tebex Discord posts.
5. Edit `config.lua`: items, `NCHub.Locale` (`en` or `tr`), `NCHub.OpenCommand`, garage name, reward times, bonus zone coordinates.
6. In `server.cfg`: `ensure oxmysql` then `ensure qb-core` then `ensure nvrs_playtimeshop`.

### Notes

- Coin grants are **server-side** only; clients cannot set amounts.
- Purchases validate items and prices on the server; NUI uses the resource folder name automatically for callbacks.
- Optional: set `NCHub.BanResource` / `NCHub.BanExport` for your anticheat ban export, or players are dropped with a message.

---

## Türkçe

### Gereksinimler

- qb-core  
- oxmysql  

### Kurulum

1. `nvrs_playtimeshop` klasörünü `resources` içine koyun (klasör adı önemlidir).
2. `nvrs_playtimeshop.sql` dosyasını veritabanına import edin.
3. `server_config.lua` içinde `steamApiKey` (isteğe bağlı, Steam avatarı için) ve `Discord_Webhook` ayarlarını yapın.
4. `config.lua` dosyasında ürünler, `NCHub.Locale` (`tr` veya `en`), komut, garaj ve ödül sürelerini düzenleyin.
5. `server.cfg`: önce `ensure oxmysql`, sonra `ensure qb-core`, ardından `ensure nvrs_playtimeshop`.

### Notlar

- Jeton ekleme tamamen **sunucuda** doğrulanır; istemci miktar gönderemez.
- Satın almalarda fiyat ve eşya sunucudaki listeden tekrar kontrol edilir.

---

**Migration from old table names:** Rename `ak4y_playtimeshop` → `nvrs_playtimeshop`, `ak4y_playtimeshop_codes` → `nvrs_playtimeshop_codes`, and add column  
`next_playtime_reward_at` INT UNSIGNED NOT NULL DEFAULT 0 to the main table.
