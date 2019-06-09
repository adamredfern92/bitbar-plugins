#!/bin/sh

tmpfile=$(mktemp)
tmpfile2=$(mktemp)

osascript -e '
tell application "OmniFocus"
	set OutputText to ""
	set PerspectiveList to {"Today", "Urgent", "Work Today", "Work Urgent"}

    set OmniDoc to front document window of default document
    set CurrentPerspective to perspective name of OmniDoc

	repeat with PerspectiveName in PerspectiveList
		tell OmniDoc to set its perspective name to PerspectiveName
		tell content of OmniDoc  to set TreeList to (value of every leaf)

		repeat with ListItem in TreeList
			set ProjectName to name of containing project of ListItem as text
			set TaskName to name of ListItem
            set TaskID to id of ListItem
            set TaskDue to due date of ListItem
			set OutputText to OutputText & PerspectiveName & "," & ProjectName & "," & TaskName & "," & TaskID & "," & TaskDue & return
		end repeat

	end repeat
    tell OmniDoc to set its perspective name to CurrentPerspective

	do shell script "echo " & OutputText
end tell
' | tr '\r' '\n' > $tmpfile2

currenttime=$(date +%H:%M)
currentday=$(date +%a)
if [ "$currentday" == "Sat" ] || [ "$currentday" == "Sun" ]
then
    grep -v '^Work' $tmpfile2 > $tmpfile
else
    if [[ "$currenttime" > "09:00" ]] && [[ "$currenttime" < "18:30" ]]
    then
        grep '^Work' $tmpfile2 | sed 's/^Work //' > $tmpfile
    else
        grep -v '^Work' $tmpfile2 > $tmpfile
    fi
fi

today_count=$(grep '^Today' $tmpfile | wc -l | tr -d ' ')
urgent_count=$(grep '^Urgent' $tmpfile | wc -l | tr -d ' ')

echo "\033[1;30m[tdo:$urgent_count/$today_count]\033[37m"

grep '^Urgent' $tmpfile | sed 's/Urgent/Today/' > $tmpfile2

echo "---"
echo "Priority"
awk -F',' '/^Urgent/ {if ($5 == "missing value") printf(" ☐ %s | bash=/usr/bin/open param1=omnifocus://task/%s terminal=false\n",$3,$4); else printf(" ☐ %s | bash=/usr/bin/open param1=omnifocus://task/%s terminal=false\n--Due: %s%s\n",$3,$4,$5,$6)}' $tmpfile

echo "---"
echo "Available"
grep -v -f $tmpfile2 $tmpfile | awk -F',' '/^Today/ {if ($5 == "missing value") printf(" ☐ %s | bash=/usr/bin/open param1=omnifocus://task/%s terminal=false\n",$3,$4); else printf(" ☐ %s | bash=/usr/bin/open param1=omnifocus://task/%s terminal=false\n--Due: %s%s\n",$3,$4,$5,$6)}'


prev_project=""
echo "---"
echo "Projects"

awk -F',' '{printf("%s,%s,%s,%s%s\n",$2,$3,$4,$5,$6)}' $tmpfile | sort | uniq | while read line
do
    current_project=$(echo "$line" | cut -d',' -f1)
    current_task=$(echo "$line" | cut -d',' -f2)
    current_task_id=$(echo "$line" | cut -d',' -f3)
    current_task_due=$(echo "$line" | cut -d',' -f4)
    if [ "$current_project" != "$prev_project" ]
    then
        echo "$current_project"
    fi
    echo "-- ☐ $current_task | bash=/usr/bin/open param1=omnifocus://task/$current_task_id terminal=false"
    if [ "$current_task_due" != "missing value" ]
    then
        echo "----Due: $current_task_due"
    fi
    prev_project=$current_project
done

prev_perspective=""
prev_project=""
echo '---'
echo 'Perspectives'

while read line
do
    current_perspective=$(echo "$line" | cut -d',' -f1)
    current_project=$(echo "$line" | cut -d',' -f2)
    current_task=$(echo "$line" | cut -d',' -f3)
    current_task_id=$(echo "$line" | cut -d',' -f4)

    if [ "$current_perspective" != "$prev_perspective" ]
    then
        echo "$current_perspective"
        prev_project=""
    fi
    if [ "$current_project" != "$prev_project" ]
    then
        echo "--$current_project"
    fi
    echo "---- ☐ $current_task | bash=/usr/bin/open param1=omnifocus://task/$current_task_id terminal=false"
    prev_perspective=$current_perspective
    prev_project=$current_project
done < $tmpfile

echo "---"

echo "Refresh | refresh=true"
