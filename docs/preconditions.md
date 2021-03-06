## <a id=preconditions></a> Preconditions for Using the MMS Example for ML model updates

If you haven't done so already, you must complete these steps before proceeding with the MMS example for ML model updates

1. Install (or gain access to) the IBM Edge Application Manager (IEAM) infrastructure (Horizon Exchange and Agbot). - **This step is completed**.

2. Install the Horizon agent on your edge device and configure it to point to your Horizon Exchange. See [Preparing an edge device](https://www.ibm.com/support/knowledgecenter/SSFKVV_4.0/devices/installing/adding_devices.html) for details. - **This step is completed**.

3. You need to use your docker id. This is required to push the image to docker registry.

   Log in to Docker Hub using your Docker Hub ID:
   ```bash
   export DOCKER_HUB_ID="<dockerhubid>"
   docker login -u $DOCKER_HUB_ID
   ```

4. Install a few development tools:

	 If required  

   ```bash
   sudo apt install -y git jq make
   ```
## Building and Publishing the MMS Example for ML model updates

1. Clone this git repository:

   ```bash
   cd ~   # or wherever you want
   git clone https://github.com/eswarak/img-MMS.git
   cd ~/img-MMS/
   ```

2. Replace the values in `horizon/hzn.json`. Replace `%org%` with the value of variable `HZN_ORG_ID`. Similarly, replace the value `%dockerid%` with your docker ID. These variables are used in the service and MMS metadata `object.json` files. They are also used in some of the commands in this procedure. After editing `horizon/hzn.json`, set the variables in your environment:

   ```bash
   sed -i "s/\%org\%/$HZN_ORG_ID/g" horizon/hzn.json
   sed -i "s/\%dockerid\%/$DOCKER_HUB_ID/g" horizon/hzn.json
   sed -i "s/\%HOSTNAME\%/$HOSTNAME/g" service.sh
   export OBJECT_ID=$HOSTNAME-index.js

   export ARCH=$(hzn architecture)
   eval $(hzn util configconv -f horizon/hzn.json)

   ```  

   Validate the environment variables that were set.  
   ```bash
   echo $SERVICE_NAME
   echo $DOCKER_IMAGE_BASE
   ```

3. Build the docker image:

   ```bash
   make build
   ```

   Alternatively, when using the default values provided in this demo [hnz.json](https://raw.githubusercontent.com/jiportilla/img-MMS/master/horizon/hzn.json) configuration file:

   ```bash
   docker build -t iportilla/image.demo-mms_amd64:1.0.0 -f ./Dockerfile.amd64 .

   Note: Replace iportilla to your docker-id.  
   ```

4. You are now ready to publish your edge service, so that it can be deployed to real edge nodes. Instruct Horizon to push your docker image to your registry and publish your service in the Horizon Exchange:

   ```bash
   hzn exchange service publish -f horizon/service.definition.json
   hzn exchange service list
   ```  
You will see the service with name `$HOSTNAME-image.demo-mms_1.0.0_amd64"` listed.  

See [preparing to create an edge service](https://www.ibm.com/support/knowledgecenter/SSFKVV_4.0/devices/developing/service_containers.html) for additional details.

## Using this Example Edge Service with Deployment Policy

The Horizon Policy mechanism offers an alternative to using Deployment Patterns. Policies provide much finer control over the deployment placement of edge services. Policies also provide a greater separation of concerns, allowing Edge Nodes owners, Service code developers, and Business owners to each independently articulate their own Policies. There are three types of Horizon Policies:

1. Node Policy (provided at registration time by the node owner)

2. Service Policy (may be applied to a published Service in the Exchange)

3. Business Policy (which approximately corresponds to a Deployment Pattern)

### Node Policy

- As an alternative to specifying a Deployment Pattern when you register your Edge Node, you may register with a Node Policy.


1. Below is the file provided in `horizon/node_policy.json` with this example:

   ```json
   {
      "properties": [
      {
         "name": "sensor",
         "value": "camera"
      },
      {
         "name": "location",
         "value": "storage"
      }
      {
         "name": "device",
         "value": "%HOSTNAME%"
      }
    ],
    "constraints": []
   }
   ```

- It provides values for two `properties` (`sensor`, `location` and `device`), that will affect which service(s) get deployed to this edge node, and states no `constraints` .

  The node registration step will be completed in the later section.


### Service Policy

Like the other two Policy types, Service Policy contains a set of `properties` and a set of `constraints`. The `properties` of a Service Policy could state characteristics of the Service code that Node Policy authors or Business Policy authors may find relevant. The `constraints` of a Service Policy can be used to restrict where this Service can be run. The Service developer could, for example, assert that this Service requires a particular hardware setup such as CPU/GPU constraints, memory constraints, specific sensors, actuators or other peripheral devices required, etc.


1. Below is the file provided in  `horizon/service_policy.json` with this example:

   ```json
   {
     "properties": [],
     "constraints": [
         "sensor == camera",
         "device == %HOSTNAME%"
      ]
    }
   ```

- Note this simple Service Policy does not provide any `properties`, but it does have a `constraint`. This example `constraint` is one that a Service developer might add, stating that their Service must only run on sensors named `camera`. If you recall the Node Policy we used above, the sensor `property` was set to `camera`, so this Service should be compatible with our Edge Node.

2. If needed, run the following commands to set the environment variables needed by the `service_policy.json` file in your shell:
   ```bash
   export ARCH=$(hzn architecture)
   eval $(hzn util configconv -f horizon/hzn.json)
   ```

3. Add the service policy in the Horizon Exchange for this Example service:

   ```bash
   sed -i "s/\%HOSTNAME\%/$HOSTNAME/g" horizon/service_policy.json
   make publish-service-policy
   ```
   Alternatively, 
   ```bash
   hzn exchange service addpolicy -f horizon/service_policy.json $HOSTNAME-image.demo-mms_1.0.0_amd64

   ```  

4. View the pubished service policy attached to `image.demo-mms` edge service:

   ```bash
   hzn exchange service listpolicy $HOSTNAME-image.demo-mms_1.0.0_amd64
   ```

- Notice that Horizon has again automatically added some additional `properties` to your Policy. These generated property values can be used in `constraints` in Node Policies and Business Policies.

- Now that you have set up the Policy for your Edge Node and the published Service policy is in the exchange, we can move on to the final step of defining a Business Policy to tie them all together and cause software to be automatically deployed on your Edge Node.


### Business Policy

Business Policy (sometimes called Deployment Policy) is what ties together Edge Nodes, Published Services, and the Policies defined for each of those, making it roughly analogous to the Deployment Patterns you have previously worked with.

Business Policy, like the other two Policy types, contains a set of `properties` and a set of `constraints`, but it contains other things as well. For example, it explicitly identifies the Service it will cause to be deployed onto Edge Nodes if negotiation is successful, in addition to configuration variable values, performing the equivalent function to the `-f horizon/userinput.json` clause of a Deployment Pattern `hzn register ...` command. The Business Policy approach for configuration values is more powerful because this operation can be performed centrally (no need to connect directly to the Edge Node).

1. Below is the file provided in  `horizon/business_policy.json` with this example:

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
     "properties": [],
     "constraints": [
          "location == backyard",
          "device == %HOSTNAME%"
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

- This simple example of a Business Policy provides one `constraint` (`location`) that is satisfied by one of the `properties` set in the `node_policy.json` file, so this Business Policy should successfully deploy our Example Service onto the Edge Node.

- At the end, the userInput section has the same purpose as the `horizon/userinput.json` files provided for other examples if the given services requires them. In this case the example service defines does not have configuration variables.

2. If needed, run the following commands to set the environment variables needed by the `business_policy.json` file in your shell:
   ```bash
   export ARCH=$(hzn architecture)
   eval $(hzn util configconv -f horizon/hzn.json)

   sed -i "s/\%HOSTNAME\%/$HOSTNAME/g" horizon/business_policy.json

   export BUSINESS_POLICY_NAME=${SERVICE_NAME}.bp

   ```

3. Publish this Business Policy to the Exchange to deploy the `image.demo-mms` service to the Edge Node (give it a memorable name):

   ```bash
   make publish-business-policy
   ```

   Alternatively:
   ```bash
   hzn exchange business addpolicy -f horizon/business_policy.json $HOSTNAME-image.demo-mms.bp

  ```  


4. Verify the business policy:

   ```bash
   hzn exchange business listpolicy $HOSTNAME-image.demo-mms.bp
   ```
- The results should look very similar to your original `business_policy.json` file, except that `owner`, `created`, and `lastUpdated` and a few other fields have been added.

You are now ready to register your node with policy and continue this example.

<table align="center">
<tr>
  <td align="left" width="9999"><a href="install-agent.md">Previous - Install Agent ... </a> </td>
  <td align="right" width="9999"><a href="using-image-mms-policy.md">Next - Using the MMS Example ... </a> </td>
</tr>
</table>