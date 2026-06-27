# Buildkite Annotation Debug Summary

I am summarizing the problems I encountered while trying to create the pipeline and annotate Buildkite steps.

## 1. Docker Desktop macOS bind-mount failure

The first blocker was a Docker Desktop on macOS mount error when Buildkite tried to pass the Job API socket into containerized steps. The failure looked like a bind-mount problem for a socket under the Buildkite agent directory.

### Resolution

I added an agent environment hook that conditionally unsets `BUILDKITE_AGENT_JOB_API_SOCKET` and `BUILDKITE_AGENT_JOB_API_TOKEN` only for Docker plugin steps. That seems to allow Docker-based steps to run without the socket-mount failure while preserving Job API access for non-Docker steps. I am not sure if this is the right way to do this, but I couldn't find a better workaround.

## 2. Empty annotations caused by literal heredoc content

The next issue was that annotations were created, but the body was wrong or effectively empty. The annotation content contained literal shell text such as `tr -d '\r' < result.txt` or `echo $RESULT_2` instead of the file content.

### Resolution

I changed the annotation body to use shell variables containing the file contents, such as `RESULT_1` and `RESULT_2`, and then interpolated those variables into the sh doc. That ensured the annotation received the actual generated sentence text.

## 3. Trying to annotate in the same Docker step

At one point I tried to annotate in the same step that generated the artifact. That did not work reliably because the Docker plugin step did not have the Job API socket/token available after the macOS workaround. Again, unsure if this is a best practice, but it was my workaround.

### Resolution

My solution is to keep generating files in the Docker step and annotations in a separate host-side step. If annotation must happen in the same step, my understanding is that if the step would need to avoid the Docker plugin and run the container manually so Job API access remains available.

## Final Working workflow

- Generate the text in a Docker step.
- Upload the result as an artifact.
- Use a separate non-Docker step to download the artifact and annotate the job.
- Keep the annotation logic in `.buildkite/scripts/annotate_result.sh` so the shell behavior stays consistent.
