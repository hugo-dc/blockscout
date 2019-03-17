#!/bin/bash

. ~/.nvm/nvm.sh

#echo ">>> Compiling dependencies..."
#mix local.hex --force
#mix do deps.get, local.rebar --force, deps.compile, compile

echo ">>>> Starting database engine..."
service postgresql start
sudo -u postgres psql -c "CREATE USER blockscout WITH PASSWORD 'blockscout'" 
sudo -u postgres psql -c "ALTER USER blockscout WITH superuser"

echo ">>> Creating database..."
mix ecto.create
echo ">>> Migrating database..."
mix ecto.migrate

echo ">>> Installing node dependencies..."
cd apps/block_scout_web/assets && npm install ; npm run deploy ; cd -
cd apps/explorer && npm install; npm run deploy ; cd -

echo ">>> Generating ssl certificate..."
cd apps/block_scout_web
mix phx.gen.cert blockscout blockscout.local
cd -

echo ">>> Starting Phx Server..."
mix phx.server
