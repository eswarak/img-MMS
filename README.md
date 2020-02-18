# Horizon Model Management Service (MMS) Example ML Service with Tensorflow

This is a simple example of using and updating a Horizon ML edge service.

- [Introduction to the Horizon Model Management Service](#introduction)
- [Preconditions for Using the ML MMS Example Edge Service](docs/preconditions.md)
- [Using the ML Tensorflow MMS Example Edge Service with Deployment Pattern](docs/using-image-mms-pattern.md)
- [More MMS Details](docs/mms-details.md)
- [Creating Your Own Example with MMS Edge Service](docs/CreateService.md)

## <a id=introduction></a> Introduction

The Horizon Model Management Service (MMS) enables you to have independent lifecycles for your code and for your data. While Horizon Services, Patterns, and Policies enable you to manage the lifecycles of your code components, the MMS performs an analogous service for your data files.  This can be useful for remotely updating the configuration of your Services in the field. It can also enable you to continuously train and update of your neural network models in powerful central data centers, then dynamically push new versions of the models to your small edge machines in the field. The MMS enables you to manage the lifecycle of data files on your edge node, remotely and independently from your code updates. In general the MMS provides facilities for you to securely send any data files to and from your edge nodes.

This document will walk you through the process of using the Model Management Service to send a file to your edge nodes. It also shows how your nodes can detect the arrival of a new version of the file, and then consume the contents of the file.


See more examples at: (https://github.com/open-horizon/examples/tree/master/edge/services/helloMMS)
