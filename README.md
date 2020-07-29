[![codecov](https://codecov.io/gh/mxiamxia/aws-opentelemetry-collector/branch/master/graph/badge.svg)](https://codecov.io/gh/mxiamxia/aws-opentelemetry-collector)
![CI](https://github.com/mxiamxia/aws-opentelemetry-collector/workflows/CI/badge.svg)
![CD](https://github.com/mxiamxia/aws-opentelemetry-collector/workflows/CD/badge.svg)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/mxiamxia/aws-opentelemetry-collector)


### Overview

AWS Observability Collector is a certified Amazon distribution of OpenTelemetry Collector. It will fully support AWS CloudWatch Metrics, Traces and Logs with correlations and export your data from AWS to the other monitoring parterns backend services.

### Getting Help

Use the following community resources for getting help with AWS Observability Collector. We use the GitHub issues for tracking bugs and feature requests.

* Ask a question in [AWS CloudWatch Forum](https://forums.aws.amazon.com/forum.jspa?forumID=138).
* Open a support ticket with [AWS Support](http://docs.aws.amazon.com/awssupport/latest/user/getting-started.html).
* If you think you may have found a bug, open an [issue](https://github.com/mxiamxia/aws-opentelemetry-collector/issues/new).
* For contributing guidelines refer [CONTRIBUTING.md](https://github.com/mxiamxia/aws-opentelemetry-collector/blob/master/CONTRIBUTING.md).

### Get Started

#### AOC AWS Components
* [Trace X-Ray Exporter](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/master/exporter/awsxrayexporter)
* Metrics EMF Exporter
* More coming

#### Try out AOC Beta
* [Run it in Docker](docs/developers/docker-demo.md)
* [Run it on AWS Linux EC2](docs/developers/linux-rpm-demo.md)
* [Run it on AWS Windows EC2](docs/developers/windows-other-demo.md)
* Run it on AWS Debian

#### Build Your Own Executables
* [Build RPM/Deb/MSI](docs/developers/build-aoc.md)
* [Build Docker Image](docs/developers/build-aoc.md)
* more

### Release Process
* [Release new version](docs/developers/release-new-version.md)

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


### License
aws-observability-collector is under Apache 2.0 license.
