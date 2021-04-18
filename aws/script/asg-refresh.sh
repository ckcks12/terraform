#!/bin/bash

region=""
asg_name=""
min_health=""
warmup_seconds=""

usage() {
  echo "
Description: AutoScalingGroups Instance Reresh
Usage: $(basename $0)
  -r region (ap-northeast-2)
  -n autoscaling group name (search-blue-alpha-kr-data)
  -m min health percentage (100)
  -s warmup seconds (300)
  [-h help]
"
exit 1;
}

while getopts 'r:n:m:s:h' optname; do
  case "${optname}" in
    h) usage;;
    r) region=${OPTARG};;
    n) asg_name=${OPTARG};;
    m) min_health=${OPTARG};;
    s) warmup_seconds=${OPTARG};;
    *) usage;;
  esac
done

[ -z "${region}" ] && >&2 echo "Error: -r region required" && usage
[ -z "${asg_name}" ] && >&2 echo "Error: -n asg_name required" && usage
[ -z "${min_health}" ] && >&2 echo "Error: -m min_health required" && usage
[ -z "${warmup_seconds}" ] && >&2 echo "Error: -s warmup_seconds required" && usage

res=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$asg_name" --region "${region}" --output json)
asg=$(echo "$res" | jq -rM '.AutoScalingGroups[0]')
cnt=$(echo "$asg" | jq -rM '.DesiredCapacity')

echo "$asg_name(cnt: $cnt)"

res=$(aws autoscaling start-instance-refresh \
  --region "${region}" \
  --auto-scaling-group-name "$asg_name" \
  --preferences MinHealthyPercentage="$min_health",InstanceWarmup="$warmup_seconds")
id=$(echo "$res" | jq -rM '.InstanceRefreshId')

watch aws autoscaling describe-instance-refreshes \
  --region "${region}" \
  --auto-scaling-group-name "$asg_name" \
  --instance-refresh-ids "$id"

echo "done"

