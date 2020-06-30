AWS Observability Collector is Certified Amazon distribution of OpenTelemetry Collectors.

### Run Demos
The provided example will bring up AOC agent instance and send Jaeger traces and OpenTelemetry Metrics to AOC. You can view Trace and Metric result on AWS X-Ray, Jaeger and CloudWatch Metric consoles. 
Edit ```docker-composite.yaml``` in ```examples``` folder
```
  # Agent
  aws-ot-collector:
    image: mxiamxia/awscollector:v0.1.2
    command: ["--config=/etc/otel-agent-config.yaml", "--log-level=DEBUG"]
    environment:
      - AWS_ACCESS_KEY_ID=<set your aws key> // TO EDIT
      - AWS_SECRET_ACCESS_KEY=<set your aws credential> // TO EDIT
      - AWS_REGION=us-west-2 // TO EDIT
    volumes:
      - ../config.yaml:/etc/otel-agent-config.yaml // bring your own config for AOC
      - ~/.aws:/root/.aws
    ports:
      - "1777:1777"   # pprof extension
      - "14268"       # Jaeger receiver
      - "55679:55679" # zpages extension
      - "55680:55680" # OTLP receiver
      - "13133"       # health_check
```
Once finish the docker config setup, run the following command
```
make docker-composite
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


