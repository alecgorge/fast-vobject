# fast-vobject

This is really easy to use and supports vObjects of any name through the
constructor.

## Coffeescript example
```
vobject = require 'fast-vobject'

vcalendar = new vobject.vCalendar()

for event in events
	vevent = new vobject.vEvent

	vevent.set "uid", event.hash
	vevent.set "summary", event.summary

	if event.allday
		vevent.setDate "dtstart", event.start_time, event.allday
	else
		vevent.setDate "dtstart", event.start_time
		vevent.setDate "dtend", event.end_time

	vevent.setDate "dtstamp", new Date
	vevent.setDate "created", new Date

	if event.contact?.name
		org = new vobject.vObject 'organizer'
		org.set 'cn', event.contact.name

		if event.contact?.email
			org.set 'mail', 'mailto:' + event.contact.email

		vevent.addComponent org

	vcalendar.addComponent vevent

```
