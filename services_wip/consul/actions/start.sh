#!/bin/bash
exec serf agent -tag role=${SERF_ROLE:-base} -event-handler="member-join=/etc/serf/member-join.sh" \
  -event-handler="member-leave,member-failed=/etc/serf/member-leave.sh"
