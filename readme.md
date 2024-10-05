# DZ Grainalyzer

A web app to allow users to run the dzg algorithm on their own data.

Made up of:
- frontend (vue app)
- server (juila server using genie.jl)
- worker (main algorithm that connects to a redis queue to work on jobs)
- redis (queue and and simble db)
- nginx (reverse proxy and static files (frontend) server)
- cron job to delete files in the `data` folder that is older than 7 days

![image](https://github.com/user-attachments/assets/16c8597f-02cb-4293-96ef-6ec54a748465)

The static files of the built frontend server is served as static files via an a nginx server.
The server is responsible for queueing tasks on the redis queue and the worker runs in the background and does each job ob the queue one by one and sends out an email once done (if email is provided). We use a custom gmail account with email: dzgrainalyzer@gmail.com to send out notification emails to users.

### Deployment:
run `npm run build` to build out the frontend.

then, you can push your code to the server using `upload.sh`, paste in credentials when asked for it.

then, ssh into the server,
```
ssh webadmin@dzgrainalyzer.eoas.ubc.ca
```

then start by stopping these services:
```
sudo systemctl stop nginx
sudo systemctl stop dzg
sudo systemctl stop dzg-worker
```

then run this to install any newly added packages on julia server:
```
cd dzg/server
julia --project=. --banner=no --eval="import Pkg; Pkg.activate(\".\"); Pkg.instantiate(); Pkg.precompile();"
julia --project=. --banner=no --eval="using Pkg; using Genie; Genie.Generator.write_secrets_file()"
cd ..
```

then to setup frontend end code:
```
sudo rm -rf /var/www/html/public
[ -d "public" ] && sudo rm -rf "public"
sudo cp -r dist public
sudo cp -r public /var/www/html/
```

then start the services back up
```
sudo systemctl start dzg
sudo systemctl start dzg-worker
```

make sure redis is running as well,
```
sudo systemctl status redis-server
```

after a few minutes, run the example script in the `webadmin/dzg` folder to aot comiple all the julia code. this will make sure that the first request for users dont take a lot of time and helps with performance

```
python3 example.py
```

then once the scriptexecutes without errors, then you can safely start hte nginx server to make it accessible to the world
```
sudo systemctl start nginx
```

make sure cronjob is up by running:
```
crontab -l
```
and it should have
```
0 0 * * * find /home/webadmin/dzg/data -mindepth 1 -ctime +7 -print -exec rm -rf {} \; 2>/dev/null
```

Note: there is a script called `deploy.sh` that runs all the things mentioned above after you ssh in, but doing it all at once sometimes leads to weird errors, so best to do it one at a time.


You should always manually test the app once all this is done to make sure everything is working as expected.

### Misc

This app has an anonymous analytics dashboard at https://app.piratepx.com/m1ZeTXWu1pbyAc2HSp5xDKz-0NZEEFCvX_zpm1k3ENtX3nSCoprCbymaxSFvaBJ4
- identifiers with "-" in them or starts with "frontend:" are page visits by users
- identifiers with "_" are from the backend

All credentials should have been shared by email to joel.

