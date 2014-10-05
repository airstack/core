# Shell Examples


### Exit Status

Get non-zero exit status of background processes.
`/some/command` could be a process that forks children.

```bash
# Start command in background
/some/command &
# Wait for command and any forked children to exit
exitcode=0
for job in `jobs -p`; do
  # Set exitcode if not 0
  wait $job || let "exitcode=$?"
done
echo $exitcode
```
