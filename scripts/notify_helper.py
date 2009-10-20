#!/usr/bin/env python
# coding=UTF-8
# script by Fortunato Ventre (voRia) - http://www.voria.org - vorione@gmail.com
#
# helper for 'nc10' script, show/update notifications

import sys, os, signal, time, pynotify

if not pynotify.init("notify_helper"):
    sys.exit(1)

## Check if we have all the parameters we need
# sys.argv[1] = pid
# sys.argv[2] = icon
# sys.argv[3] = urgency
# sys.argv[4] = title
# sys.argv[5] = message
if len(sys.argv) != 6:
	sys.exit(2)

# Save current pid
open(sys.argv[1], "w").write(str(os.getpid()))

def notifyUpdate(signum = None, frame = None):
	# Read needed info from temp files
	icon = open(sys.argv[2], "r").read().strip()
	urgency = open(sys.argv[3], "r").read().strip()
	title = open(sys.argv[4], "r").read().strip()
	message = open(sys.argv[5], "r").read().strip()
	notify.update(title, message, icon)
	if urgency == "low":
		notify.set_urgency(pynotify.URGENCY_LOW)
	elif urgency == "normal":
		notify.set_urgency(pynotify.URGENCY_NORMAL)
	else:
		notify.set_urgency(pynotify.URGENCY_CRITICAL)
	notify.show()
	time.sleep(5) # sleep while showing notification

# create a new notification
notify = pynotify.Notification(" ")
# connect signal 12 to notifyUpdate()
signal.signal(12, notifyUpdate)
# show notification bubble at startup
notifyUpdate()
# remove pid file at exit
if os.path.exists(sys.argv[1]):
	os.remove(sys.argv[1])
