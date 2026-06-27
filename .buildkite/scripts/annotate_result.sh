#!/bin/sh
set -eu

artifact_name="$1"
step_key="$2"
annotation_context="$3"
annotation_style="$4"
annotation_title="$5"

buildkite-agent artifact download "$artifact_name" . --step "$step_key"
ls -la "$artifact_name"

result_value="$(tr -d '\r\n' < "$artifact_name")"
if [ -z "$result_value" ]; then
  result_value="($artifact_name was empty)"
fi

cat <<EOF | buildkite-agent annotate --scope job --style "$annotation_style" --context "$annotation_context"
### $annotation_title

$result_value
EOF