### Overview
AWS Observability Collector is Certified Amazon distribution of OpenTelemetry Collectors.

### Run Demos
The provided example will bring up AOC agent instance and send Jaeger traces and OpenTelemetry Metrics to AOC. You can view Trace and Metric result on AWS X-Ray, Jaeger and CloudWatch Metric consoles. 
#### Steps,
1. Edit the following section in ```docker-composite.yaml``` under ```examples``` folder. add your own ```AWS_ACCESS_KEY_ID``` and ```AWS_SECRET_ACCESS_KEY``` in the config. The default region is ```us-west-2```.
```yaml
  # Agent
  aws-ot-collector:
    image: mxiamxia/awscollector:v0.1.2
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
      - "14268"       # Jaeger receiver
      - "55679:55679" # zpages extension
      - "55680:55680" # OTLP receiver
      - "13133"       # health_check
```
2. Run the following command under the package root directory
```
make docker-composite
```
3. Stop Application
```
make docker-stop
```

## View result
* X-Ray - aws console
* Jaeger - http://localhost:16686/
* CloudWatch - aws console


###  Build RPM
```
make package-rpm
```

### Build Docker Image
```
make docker-build
```

### Push Docker
```
make docker-push
```


