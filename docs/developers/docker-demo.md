### Run AOC Beta Examples with Docker

The provided example will run AOC Beta within Docker container. This demo also includes AWS data emitter container image that will generate OTLP format of metrics and traces data to AWS CloudWatch and X-Ray consoles.  Please follow the steps below to have a try AWS Observability Collector Beta.

**Steps,**

1. Download the source code of this repo and edit the following section in docker-composite.yaml under examples folder. Then add your own AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in the config. The default region is us-west-2 where the data will be sent to.
```
  # Agent aws-observability-collector:
    image: mxiamxia/awscollector:v0.1.8
    command: ["--config=/etc/otel-agent-config.yaml", "--log-level=DEBUG"]
    environment:
      - AWS_ACCESS_KEY_ID=<set your aws key> // TO EDIT
      - AWS_SECRET_ACCESS_KEY=<set your aws credential> // TO EDIT
      - AWS_REGION=us-west-2 // TO EDIT
    volumes:
      - ../config.yaml:/etc/otel-agent-config.yaml // use default config
      - ~/.aws:/root/.aws
    ports:
      - "1777:1777"   # pprof extension
      - "55679:55679" # zpages extension
      - "55680:55680" # OTLP receiver
      - "13133"       # health_check
```
2. Once your AWS credential has been attached into config file, run the following make command.
```
make docker-composite
```
3. View you data in AWS console

    * X-Ray - aws console
    * CloudWatch - aws console  
    
**AWS Metrics Sample Data**   
* ![aws metrics](../images/metrics_sample.png)  
**AWS Traces Sample Data**
* ![aws traces](../images/traces_sample.png)  

4. Stop the running AOC in Docker container
```
make docker-stop
```