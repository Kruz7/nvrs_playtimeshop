lua54 "yes"
fx_version "cerulean"
game "gta5"

dependencies {
    "qb-core",
    "oxmysql",
}

shared_scripts {
    "config.lua",
}

client_scripts {
    "client/main.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server_config.lua",
    "server/main.lua",
}

ui_page "html/ui.html"

files {
    "html/ui.html",
    "html/font/*.ttf",
    "html/font/*.otf",
    "html/css/*.css",
    "html/images/*.jpg",
    "html/images/*.png",
    "html/js/*.js",
}
