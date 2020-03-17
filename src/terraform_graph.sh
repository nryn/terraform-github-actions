#!/bin/bash

function terraformGraph {
  # Gather the output of `terraform graph`.
  echo "graph: info: creating a graph"
  graphOutput=$(terraform graph ${*} 2>&1)
  graphExitCode=${?}

  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${graphExitCode} -eq 0 ]; then
    echo "graph: info: graph created"
    echo "${graphOutput}"
    echo
    exit ${graphExitCode}
  fi

  # Exit code of !0 indicates failure.
  if [ ${graphExitCode} -ne 0 ]; then
    echo "fmt: error: failed to create graph"
    echo "${graphOutput}"
    echo
    exit ${graphExitCode}
  fi

  # Comment on the pull request if necessary.
  if [ "$GITHUB_EVENT_NAME" == "pull_request" ] && [ "${tfComment}" == "1" ]; then

    graphCommentWrapper="#### \`terraform graph\` Failed
*Workflow: \`${GITHUB_WORKFLOW}\`, Action: \`${GITHUB_ACTION}\`, Working Directory: \`${tfWorkingDir}\`, Workspace: \`${tfWorkspace}\`*"

    graphCommentWrapper=$(stripColors "${graphCommentWrapper}")
    echo "graph: info: creating JSON"
    graphPayload=$(echo "${fmtCommentWrapper}" | jq -R --slurp '{body: .}')
    graphCommentsURL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
    echo "graph: info: commenting on the pull request"
    echo "${graphPayload}" | curl -s -S -H "Authorization: token ${GITHUB_TOKEN}" --header "Content-Type: application/json" --data @- "${graphCommentsURL}" > /dev/null
  fi

  # Write changes to branch
  echo "::set-output name=tf_actions_graph_written::false"
  if [ "${tfGraphOutputFile}" != "" ]; then
    echo "graph: info: terraform graph file will be written"
    terraform graph "${*}" > "${tfGraphOutputFile}"
    graphExitCode=${?}
    echo "::set-output name=tf_actions_graph_written::true"
  fi

  exit ${graphExitCode}
}
