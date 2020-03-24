## <a id=preconditions></a> Preconditions for Using the ML Image MMS Example Edge Service

If you haven't done so already, you must do these steps before proceeding with the ML model mms example:

1. Install the Horizon management infrastructure (exchange and agbot).

2. Install the Horizon agent on your edge device and configure it to point to your Horizon exchange.

3. Set your exchange org:

```bash
export HZN_ORG_ID="<your-cluster-name>"
```

4. Create a cloud API key that is associated with your Horizon instance, set your exchange user credentials, and verify them:

```bash
export HZN_EXCHANGE_USER_AUTH="iamapikey:<your-API-key>"
hzn exchange user list
```

5. Choose an ID and token for your edge node, create it, and verify it:

```bash
export HZN_EXCHANGE_NODE_AUTH="<choose-any-node-id>:<choose-any-node-token>"
hzn exchange node create -n $HZN_EXCHANGE_NODE_AUTH
hzn exchange node confirm
```

6. verify keys

## Using this Example Edge Service with Deployment Policy

The Horizon Policy mechanism offers an alternative to using Deployment Patterns. Policies provide much finer control over the deployment placement of edge services. It also provides a greater separation of concerns, allowing Edge Nodes owners, Service code developers, and Business owners to each independently articulate their own Policies. There are therefore three types of Horizon Policies:

1. Node Policy (provided at registration time by the node owner)

2. Service Policy (may be applied to a published Service in the Exchange)

3. Business Policy (which approximately corresponds to a Deployment Pattern)

### Node Policy

- As an alternative to specifying a Deployment Pattern when you register your Edge Node, you may register with a Node Policy.

1. Get the required helloworld node and business policy files:
```bash
wget https://raw.githubusercontent.com/jiportilla/img-MMS/master/horizon/node.policy.json
```

- Below is the `node_policy.json` file you obtained in step one:

```json
{
  "properties": [
    {
       "name": "sensor",
       "value": "camera"
      }
  ],
  "constraints": [
	"location == backyard"
  ]
}
```

- It provides values for one `property` (`sensor`), that will effect which services get deployed to this edge node, and states one `constraint` (`location`).


7. Create docker image:

```bash
docker build -t $(DOCKER_IMAGE_BASE)_$(ARCH):$(SERVICE_VERSION) -f ./Dockerfile.$(ARCH) .
```
For example:

```bash
docker build -t iportilla/image.demo-mms_amd64:1.0.0 -f ./Dockerfile.amd64 .
```

8. Publish Edge service:

```bash
hzn exchange service publish -O -f horizon/service.definition.json
```
### Service Policy

- Like the other two Policy types, Service Policy contains a set of `properties` and a set of `constraints`. The `properties` of a Service Policy could state characteristics of the Service code that Node Policy authors or Business Policy authors may find relevant. The `constraints` of a Service Policy can be used to restrict where this Service can be run. The Service developer could, for example, assert that this Service requires a particular hardware setup such as CPU/GPU constraints, memory constraints, specific sensors, actuators or other peripheral devices required, etc.

- Below is the `service_policy.json` file the service developer attached to `image.demo-mms` when it was published:

```json
{
  "properties": [
  ],
  "constraints": [
       "sensor == camera"
  ]
}
```

- Note this simple Service Policy doesn't provide any `properties`, but it does have a `constraint`. This example `constraint` is one that a Service developer might add, stating that their Service must only run on sensors named `camera`. If you recall the Node Policy we used above, the sensor `property` was set to `camera`, so this Service should be compatible with our Edge Node.

1. View the pubished service policy attached to `image.demo-mms`:

```bash
hzn exchange service listpolicy image.demo-mms_1.0.0_amd64
```

- Notice that Horizon has again automatically added some additional `properties` to your Policy. These generated property values can be used in `constraints` in Node Policies and Business Policies.

- Now that you have set up the Policy for your Edge Node and the published Service policy is in the exchange, we can move on to the final step of defining a Business Policy to tie them all together and cause software to be automatically deployed on your Edge Node.


### Business Policy

- Business Policy (sometimes called Deployment Policy) is what ties together Edge Nodes, Published Services, and the Policies defined for each of those, making it roughly analogous to the Deployment Patterns you have previously worked with.

- Business Policy, like the other two Policy types, contains a set of `properties` and a set of `constraints`, but it contains other things as well. For example, it explicitly identifies the Service it will cause to be deployed onto Edge Nodes if negotiation is successful, in addition to configuration variable values, performing the equivalent function to the `-f horizon/userinput.json` clause of a Deployment Pattern `hzn register ...` command. The Business Policy approach for configuration values is more powerful because this operation can be performed centrally (no need to connect directly to the Edge Node).

1. Get the required `image.demo-mms` business policy file and the `hzn.json` file:
```bash
wget https://raw.githubusercontent.com/jiportilla/img-MMS/master/horizon/business_policy.json

wget https://raw.githubusercontent.com/jiportilla/img-MMS/master/horizon/hzn.json
```
- Below is the `business_policy.json` file you just grabbed in step one:

```json
{
  "label": "Business policy for $SERVICE_NAME",
  "description": "A super-simple image demo with Horizon MMS updates",
  "service": {
    "name": "$SERVICE_NAME",
    "org": "$HZN_ORG_ID",
    "arch": "$ARCH",
    "serviceVersions": [
      {
        "version": "$SERVICE_VERSION",
        "priority":{}
      }
    ]
  },
  "properties": [
    {
       "name": "location",
       "value": "backyard"
      }
  ],
  "constraints": [
        "sensor == camera"
  ],
  "userInput": [
    {
      "serviceOrgid": "$HZN_ORG_ID",
      "serviceUrl": "$SERVICE_NAME",
      "serviceVersionRange": "[0.0.0,INFINITY)",
      "inputs": [
      ]
    }
  ]
}
```

- This simple example of a Business Policy provides one `propertity`(`location`), and it does have one `constraint` (`sensor`) that is satisfied by the `property` set in the `node.policy.json` file, so this Business Policy should successfully deploy our Service onto the Edge Node.

- At the end, the userInput section has the same purpose as the `horizon/userinput.json` files provided for other examples if the given services requires them. In this case the example service defines does not have configuration variables.

2. Run the following commands to set the environment variables needed by the `business_policy.json` file in your shell:
```bash
export ARCH=$(hzn architecture)
eval $(hzn util configconv -f hzn.json)
eval export $(cat agent-install.cfg)
```

3. Publish this Business Policy to the Exchange to deploy the `ibm.helloworld` service to the Edge Node (give it a memorable name):

```bash
hzn exchange business addpolicy -f business_policy.json <choose-any-policy-name>
```

For example:
```bash
hzn exchange business addpolicy --json-file=business_policy.json image.demo-mms.policy

```

4. Verify the business policy:

```bash
hzn exchange business listpolicy image.demo-mms.policy
```
- The results should look very similar to your original `business_policy.json` file, except that `owner`, `created`, and `lastUpdated` and a few other fields have been added.




