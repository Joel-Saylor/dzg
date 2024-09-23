#!/bin/bash
sudo systemctl stop nginx
sudo systemctl stop dzg
sudo systemctl stop dzg-worker

echo "Setting up Server"
cd server
julia --project=. --banner=no --eval="import Pkg; Pkg.activate(\".\"); Pkg.instantiate(); Pkg.precompile();"
julia --project=. --banner=no --eval="using Pkg; using Genie; Genie.Generator.write_secrets_file()"
cd ..


echo  "Setting up Frontend"
sudo rm -rf /var/www/html/public
[ -d "public" ] && sudo rm -rf "public"
sudo cp -r dist public
sudo cp -r public /var/www/html/

echo "Starting Services"
sudo systemctl start dzg
sudo systemctl start dzg-worker

echo "Running example script"
python3 example.py

echo "Starting Nginx"
sudo systemctl start nginx
