[![codecov](https://codecov.io/gh/mxiamxia/aws-opentelemetry-collector/branch/master/graph/badge.svg)](https://codecov.io/gh/mxiamxia/aws-opentelemetry-collector)

### Overview
AWS Observability Collector is Certified Amazon distribution of OpenTelemetry Collectors. It will fully support AWS CloudWatch Metrics, Traces and Logs with correlations and export your data from AWS to the other monitoring parterns backend services.

## Getting Help  

Use the following community resources for getting help with AWS Observability Collector. We use the GitHub issues for tracking bugs and feature requests.  

* Ask a question in the [AWS CloudWatch Forum](https://forums.aws.amazon.com/forum.jspa?forumID=138).  
* Open a support ticket with [AWS Support](http://docs.aws.amazon.com/awssupport/latest/user/getting-started.html).  
* If you think you may have found a bug, open an [issue](https://github.com/mxiamxia/aws-opentelemetry-collector/issues/new).  
* For contributing guidelines refer [CONTRIBUTING.md](https://github.com/mxiamxia/aws-opentelemetry-collector/blob/master/CONTRIBUTING.md).

### Run Demos with Docker
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

#### View result
* X-Ray - aws console
* Jaeger - http://localhost:16686/
* CloudWatch - aws console

### Run Demos on AWS EC2 Linux
#### Steps,
1. On a Linux server, enter the following,  
Eg,
```
wget https://aws-opentelemetry-collector-release.s3.amazonaws.com/amazon_linux/amd64/v0.1.6/aws-opentelemetry-collector.rpm
```
2. Install the package. If you downloaded an RPM package on a Linux server, change to the directory containing the package and enter the following:  
```
sudo rpm -U ./amazon-cloudwatch-agent.rpm
```
If you downloaded a DEB package on a Linux server, change to the directory containing the package and enter the following:
```
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
```
If you downloaded an MSI package on a server running Windows Server, change to the directory containing the package and enter the following:
```
msiexec /i amazon-cloudwatch-agent.msi
```
3. Run AOC on the host with the provided ctl script. The config.yaml is optional, if it is not provided the default [config](https://github.com/mxiamxia/aws-opentelemetry-collector/blob/master/config.yaml) will be applied.
```
sudo /opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector-ctl -c </path/config.yaml> -a start
```
4. Stop the running AOC when finish the testing.
```
sudo /opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector-ctl  -a stop
```

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

### Build Binary
```
make build
```

