## <a id=using-image-mms-pattern></a> Using the ML Model MMS Example Edge Service with Deployment Pattern

![MMS Example workflow](docs/MMSExample.png)

1. Register your edge node with Horizon to use the image-tf-mms pattern:

```bash
hzn register -p iportilla/pattern-image-ts-mms-amd64
```

2. The edge device will make an agreement with one of the Horizon agreement bots (this typically takes about 15 seconds). Repeatedly query the agreements of this device until the `agreement_finalized_time` and `agreement_execution_start_time` fields are filled in:

```bash
hzn agreement list
```

3. After the agreement is made, list the docker container edge service that has been started as a result:

``` bash
sudo docker ps
```

4. See the image-tf-mms service output:

  on **Linux**:

  ```bash
  sudo tail -f /var/log/syslog | grep ESS
  ```

  on **Mac**:

  ```bash
  sudo docker logs -f $(sudo docker ps -q --filter name=ESS)

  open a modern browser (Chrome) and navigate to http:/HOSTNAME:9080, open Developer tools and watch the Web Console (HOSTNAME or IP or your node)
  ```

5. Publish the `index.js` file as a new mms object:
```bash
hzn mms object publish -m mms/object.json -f index.js
```

5. View the published mms object:
```bash
hzn mms object list -t js -i index.js -d
```

Once the `Object status` changes to `delivered` you will see the output of the image classification service change
from **load MobileNet**
to **Load cocoSSD**

8. Delete the published mms object:
```bash
hzn mms object delete -t js --id index.js
```

9. Unregister your edge node (which will also stop the image-tf-mms service):

```bash
hzn unregister -f
```
