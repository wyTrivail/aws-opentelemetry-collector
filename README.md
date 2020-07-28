[![codecov](https://codecov.io/gh/mxiamxia/aws-opentelemetry-collector/branch/master/graph/badge.svg)](https://codecov.io/gh/mxiamxia/aws-opentelemetry-collector)
![CI](https://github.com/mxiamxia/aws-opentelemetry-collector/workflows/CI/badge.svg)
![CD](https://github.com/mxiamxia/aws-opentelemetry-collector/workflows/CD/badge.svg)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/mxiamxia/aws-opentelemetry-collector)


### Overview

AWS Observability Collector is Certified Amazon distribution of OpenTelemetry Collectors. It will fully support AWS CloudWatch Metrics, Traces and Logs with correlations and export your data from AWS to the other monitoring parterns backend services.

### Getting Help

Use the following community resources for getting help with AWS Observability Collector. We use the GitHub issues for tracking bugs and feature requests.

* Ask a question in [AWS CloudWatch Forum](https://forums.aws.amazon.com/forum.jspa?forumID=138).
* Open a support ticket with [AWS Support](http://docs.aws.amazon.com/awssupport/latest/user/getting-started.html).
* If you think you may have found a bug, open an [issue](https://github.com/mxiamxia/aws-opentelemetry-collector/issues/new).
* For contributing guidelines refer [CONTRIBUTING.md](https://github.com/mxiamxia/aws-opentelemetry-collector/blob/master/CONTRIBUTING.md).

### Get Started

#### Run AOC Beta Examples with Docker

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
* ![aws metrics](docs/images/metrics_sample.png)  
**AWS Traces Sample Data**
* ![aws traces](docs/images/traces_sample.png)  

4. Stop the running AOC in Docker container
```
make docker-stop
```
#### Run AOC Beta on AWS EC2 Linux

To run AOC on AWS EC2 Linux host, you can choose to install AOC RPM on your host by the following steps.

**Steps,**

1. Login on AWS Linux EC2 host and download aws-observability-collector RPM with the following command.
```
wget https://aws-opentelemetry-collector-release.s3.amazonaws.com/amazon_linux/amd64/v0.1.8/aws-opentelemetry-collector.rpm
```
2. Install aws-observability-collector RPM by the following command on the host
```
sudo rpm -Uvh  ./aws-opentelemetry-collector.rpm
```
3. Once RPM is installed, it will create AOC in directory /opt/aws/aws-opentelemetry-collector/

[Image: image.png]. 

4. We provided a control script to manage AOC. Customer can use it to Start, Stop and Check Status of AOC.

    * Start AOC with CTL script. The config.yaml is optional, if it is not provided the default config (https://github.com/mxiamxia/aws-opentelemetry-collector/blob/master/config.yaml) will be applied.  
    ```
        sudo /opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector-ctl -c </path/config.yaml> -a start
    ```
    * Stop the running AOC when finish the testing.
    ```
        sudo /opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector-ctl  -a stop
    ```
    * Check the status of AOC
    ```
        sudo /opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector-ctl  -a status
    ```
5. Test the data with the running AOC on EC2. you can run the following command on EC2 host. (Docker app has to be pre-installed)
```
docker run --rm -it -e "otlp_endpoint=172.17.0.1:55680" -e "otlp_instance_id=test_insance" mxiamxia/aoc-metric-generator:latest
```
#### Run AOC on Debian and Windows hosts,

If you downloaded a DEB package on a Linux server, change to the directory containing the package and enter the following:
```
sudo dpkg -i -E ./aws-opentelemetry-collector.deb
```
If you downloaded an MSI package on a server running Windows Server, change to the directory containing the package and enter the following:
```
msiexec /i aws-opentelemetry-collector.msi
```
### Build Artifacts

aws-observability-collector is an open source project, we’re looking for the contributing from all the engineers to make it better. You can build your own executable binaries per your own customization. We provide the following command for you the build your own executables.

#### Build Binary
```
make build
```
#### Build RPM
```
make package-rpm
```
#### Build Docker Image
```
make docker-build
```
#### Push Docker
```
make docker-push
```

### Benchmark

aws-observability-collector is based on open-telemetry-collector. Here is the benchmark of each plugins running on AOC.

Test Component |	Receiver |	Exporter |	Max CPU Utilised |	Max Memory Utilised
---------------|-----------|-----------|-------------------|---------------------
OpenCensus|	opencensus	| opencensus |	34.4 |	45
SAPM |	SAPM |	SAPM |	20.7 |	48
AwsXray |	OTLP |	AWSXray |	41.9 |	48
JaegerGRPC |	jaeger |	jaeger |	25.7 |	33
OTLP |	OTLP |	OTLP |	17.2 |	33
Zipkin |	Zipkin |	Zipkin |	45 |	33


