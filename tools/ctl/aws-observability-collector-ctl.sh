  #!/bin/sh

  # Copyright 2017 Amazon.com, Inc. and its affiliates. All Rights Reserved.
  #
  # Licensed under the Amazon Software License (the "License").
  # You may not use this file except in compliance with the License.
  # A copy of the License is located at
  #
  #   http://aws.amazon.com/asl/
  #
  # or in the "license" file accompanying this file. This file is distributed
  # on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
  # express or implied. See the License for the specific language governing
  # permissions and limitations under the License.

  set -e
  set -u

  readonly AGENTDIR="/opt/aws/aws-observability-collector"
  readonly CMDDIR="${AGENTDIR}/bin"
  readonly CONFDIR="${AGENTDIR}/etc"
  readonly LOGDIR="${AGENTDIR}/logs"
  readonly RESTART_FILE="${CONFDIR}/restart"
  readonly VERSION_FILE="${CMDDIR}/VERSION"

  # The systemd and upstart scripts assume exactly this .toml file name
  readonly TOML="${CONFDIR}/config.yaml"
  readonly JSON_DIR="${CONFDIR}/aws-observability-collector.d"

  SYSTEMD='false'

  UsageString="

  usage: amazon-cloudwatch-agent-ctl -a stop|start|status|

  fetch-config|append-config|remove-config [-m ec2|onPremise|auto] [-c default|ssm:<parameter-store-name>|file:<file-path>] [-s]

  e.g.
  1. apply a SSM parameter store config on EC2 instance and restart the agent afterwards:
  amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:AmazonCloudWatch-Config.json -s
  2. append a local json config file on onPremise host and restart the agent afterwards:
  amazon-cloudwatch-agent-ctl -a append-config -m onPremise -c file:/tmp/config.json -s
  3. query agent status:
  amazon-cloudwatch-agent-ctl -a status

  -a: action
  stop:                                   stop the agent process.
  start:                                  start the agent process.
  status:                                 get the status of the agent process.
  fetch-config:                           use this json config as the agent's only configuration.
  append-config:                          append json config with the existing json configs if any.
  remove-config:                          remove json config based on the location (ssm parameter store name, file name)

  -m: mode
  ec2:                                    indicate this is on ec2 host.
  onPremise:                              indicate this is on onPremise host.
  auto:                                   use ec2 metadata to determine the environment, may not be accurate if ec2 metadata is not available for some reason on EC2.

  -c: configuration
  default:                                default configuration for quick trial.
  ssm:<parameter-store-name>:             ssm parameter store name
  file:<file-path>:                       file path on the host

  -s: optionally restart after configuring the agent configuration
  this parameter is used for 'fetch-config', 'append-config', 'remove-config' action only.

  "

  aoc_start() {
    config="${1:-}"

    if [ -f "$(config)" ]; then
      cp "$(config)" "$(CONFDIR)"
    fi

    if [ "${SYSTEMD}" = 'true' ]; then
      systemctl daemon-reload
      systemctl enable aws-opentelemetry-collector.service
      service aws-opentelemetry-collector restart
    else
      start aws-opentelemetry-collector
      sleep 1
    fi
  }

  aoc_stop() {
    if [ "$(aoc_runstatus)" = 'stopped' ]; then
      return 0
    fi

    if [ "${SYSTEMD}" = 'true' ]; then
      service aws-opentelemetry-collector stop
    else
      stop aws-opentelemetry-collector || true
    fi
  }

  aoc_preun() {
    cwa_stop
    if [ "${SYSTEMD}" = 'true' ]; then
      systemctl disable aws-opentelemetry-collector.service
      systemctl daemon-reload
      systemctl reset-failed
    fi
  }

  aoc_status() {
    pid=''
    if [ "${SYSTEMD}" = 'true' ]; then
      pid="$(systemctl show -p MainPID aws-opentelemetry-collector.service | sed s/MainPID=//)"
    else
      pid="$(initctl status aws-opentelemetry-collector | sed -n s/^.*process\ //p)"
    fi

    starttime_fmt=''
    if [ ${pid} ] && [ ${pid} -ne 0 ]; then
      starttime="$(TZ=UTC ps -o lstart= "${pid}")"
      starttime_fmt="$(TZ=UTC date -Isec -d "${starttime}")"
    fi

    version="$(cat ${VERSION_FILE})"

    echo "{"
    echo "  \"status\": \"$(aoc_runstatus)\","
    echo "  \"starttime\": \"${starttime_fmt}\","
    echo "  \"version\": \"${version}\""
    echo "}"
  }

  aoc_runstatus() {
    running=false
    if [ "${SYSTEMD}" = 'true' ]; then
      set +e
      if systemctl is-active aws-opentelemetry-collector.service 1>/dev/null; then
        running='true'
      fi
      set -e
    else
      if [ "$(initctl status aws-opentelemetry-collector | grep -c running)" = 1 ]; then
        running='true'
      fi
    fi

    if [ "${running}" = 'true' ]; then
      echo "running"
    else
      echo "stopped"
    fi
  }

    main() {
      action=''
      restart='false'
      mode='ec2'
      config_location=''

      # detect which init system is in use
      if [ "$(/sbin/init --version 2>/dev/null | grep -c upstart)" = 1 ]; then
        SYSTEMD='false'
      elif [ "$(systemctl | grep -c '\-\.mount')" = 1 ]; then
        SYSTEMD='true'
      elif [ -f /etc/init.d/cron ] && [ ! -h /etc/init.d/cron ]; then
        echo "sysv-init is not supported" >&2
        exit 1
      else
        echo "unknown init system" >&2
        exit 1
      fi

      OPTIND=1
      while getopts ":hsa:r:c:m:" opt; do
        case "${opt}" in
          h) echo "${UsageString}"
        exit 0
        ;;
        s) restart='true' ;;
        a) action="${OPTARG}" ;;
        c) config_location="${OPTARG}" ;;
        m) mode="${OPTARG}" ;;
        \?) echo "Invalid option: -${OPTARG} ${UsageString}" >&2
        ;;
        :)  echo "Option -${OPTARG} requires an argument ${UsageString}" >&2
        exit 1
        ;;
      esac
      done
shift "$(( ${OPTIND} - 1 ))"

case "${mode}" in
  ec2)
  ;;
  onPremise)
  ;;
  auto)
  ;;
  *)  echo "Invalid mode: ${mode} ${UsageString}" >&2
  exit 1
  ;;
esac

case "${action}" in
  stop) aoc_stop ;;
  start) aoc_start "${config_location}" ;;
  status) aoc_status ;;
  # helper for rpm+deb uninstallation hooks, not expected to be called manually
  preun) aoc_preun ;;
  *) echo "Invalid action: ${action} ${UsageString}" >&2
  exit 1
  ;;
esac
}

main "$@"
