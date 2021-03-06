# This script will be executed in late_start service mode
# More info in the main Magisk thread
# Copyright 2014 Łukasz "JustArchi" Domeradzki
# Contact: JustArchi@JustArchi.net
# Modified by Zackptg5 @xda-developers
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Delay in seconds, which specifies the amount of time we need to wait for the kernel or other init.d callers
# This is required in order to don't execute all init.d scripts twice
# A 5 seconds should be the safe value and more than enough - if something is going to execute init.d, it should start within 5 seconds from boot
# You can also specify "0" here for no delay and insta-call, but beware that all your init.d scripts probably will be executed twice - by kernel and this hook
DELAY=5
INITDPART="/system/etc/init.d/0000INITD" # This is the init.d part of Init.d
CHECKPART="/data/INITD" # This is the check-file, must be the same here and in the init.d part specified above
LOG="/data/Initd.log" # Log for init.d

# Forward stdout and stderr to our log
exec 1>"$LOG"
exec 2>&1

# Assume that kernel won't execute init.d before us, as we're earlier than sysinit
rm -f "$CHECKPART" # We must make sure CHECKPART doesn't exist yet

date
echo "INFO: Init.d started"

# Core
if [ ! -x "$INITDPART" ]; then
	echo "ERROR: INITDPART $INITDPART was not found, make sure that it exists and is executable, halt"
else
	echo "INFO: INITDPART $INITDPART found, all good"
	if [ ! -f "$CHECKPART" ]; then
		echo "INFO: Init.d not yet executed, waiting $DELAY seconds for kernel's reaction"
		sleep "$DELAY"
	fi

	if [ ! -f "$CHECKPART" ]; then
		echo "INFO: After $DELAY seconds init.d is still not executed, executing all init.d scripts right now"
    su -c sh /system/bin/sysinit
		if [ ! -f "$CHECKPART" ]; then
			echo "ERROR: CHECKPART doesn't exist even after our init.d execution. This shouldn't happen, something is seriously broken here, please investigate"
		else
			echo "INFO: Init.d has been properly executed"
		fi
	else
		echo "INFO: Init.d has been properly executed by the kernel, we don't need to do anything"
	fi
fi

rm -f "$CHECKPART" # We don't need you anymore

echo "INFO: Init.d finished"
date
exit 0
