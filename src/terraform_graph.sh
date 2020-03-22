#!/bin/bash

function terraformGraph {
  # Gather the output of `terraform graph`.
  echo "graph: info: creating a graph"
  graphOutput=$(terraform graph ${*} 2>&1)
  graphExitCode=${?}

  # Exit code of 0 indicates success.
  if [ ${graphExitCode} -eq 0 ]; then
    graphExitSummary="info: graph created"
  fi

  # Exit code of !0 indicates failure.
  if [ ${graphExitCode} -ne 0 ]; then
    graphExitSummary="error: failed to create graph"
  fi

  # Print the summary message and the graph output
  echo "graph: ${graphExitSummary}"
  echo "${graphOutput}"

  # Comment on the pull request if necessary.
  if [ "$GITHUB_EVENT_NAME" == "pull_request" ] && [ "${tfComment}" == "1" ]; then
    graphCommentWrapper="#### \`terraform graph\` ${graphExitSummary}
*Workflow: \`${GITHUB_WORKFLOW}\`, Action: \`${GITHUB_ACTION}\`, Working Directory: \`${tfWorkingDir}\`, Workspace: \`${tfWorkspace}\`*
```
${graphOutput}
```"

    graphCommentWrapper=$(stripColors "${graphCommentWrapper}")
    echo "graph: info: creating JSON"
    graphPayload=$(echo "${graphCommentWrapper}" | jq -R --slurp '{body: .}')
    graphCommentsURL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
    echo "graph: info: commenting on the pull request"
    echo "${graphPayload}" | curl -s -S -H "Authorization: token ${GITHUB_TOKEN}" --header "Content-Type: application/json" --data @- "${graphCommentsURL}" > /dev/null
  fi

  # Write changes to branch
  echo "::set-output name=tf_actions_graph_written::false"
  if [ "${tfGraphOutputFile}" != "" ]; then
    touch ${tfGraphOutputFile}
    echo "graph: info: terraform graph file will be written to ${tfGraphOutputFile}"
    terraform graph "${*}" | cat > ${tfGraphOutputFile}
    graphExitCode=${?}
    echo "::set-output name=tf_actions_graph_written::true"
  fi

  exit ${graphExitCode}
}
