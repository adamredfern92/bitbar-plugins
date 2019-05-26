#!/usr/local/bin/python
# -*- coding: utf-8 -*-
# <bitbar.title>Git</bitbar.title>
# <bitbar.version>v0.1</bitbar.version>
# <bitbar.author>Timothy Barnard</bitbar.author>
# <bitbar.author.github>collegboi</bitbar.author.github>
# <bitbar.desc>Shows the current status of local repos. https://github.com/collegboi/my-bitbar-plugins</bitbar.desc>
# <bitbar.dependencies>python, GitPython</bitbar.dependencies>
#

import git
from os.path import expanduser
import os

def split_path(path):
    direc = path #path.split('.')[0]
    direc_name = path.split('/')[-1]
    return (direc_name, direc )


def get_list_dir(start_path):
    paths = []
    for root, directories, filenames in os.walk(start_path):
        if any(directory.endswith('.git') for directory in directories):
            if ".build" not in root:
                paths.append(root)
    return paths

output=''

def add_text(text):
    global output
    output = output + '\n' + text

add_text("---")

home = expanduser("~")
quotes = '"'
path = home + '/Developer/'

add_text("---")

content = get_list_dir(path)
content.append('/Users/adamredfern/.dot-files')
content.sort()
total_repos = len(content)
outdated_repos = 0

for file in content:
    direc_name, direc = split_path(file)
    repo = git.Repo(direc)
    branches = repo.branches
    try:
        active_branch = repo.active_branch.name
    except:
        active_branch = 'DETACHED_' + repo.head.object.hexsha
    tags = repo.tags
    head = repo.head
    cur_tag = next((tag for tag in repo.tags if tag.commit == repo.head.commit), None)

    commits_ahead = repo.iter_commits('origin/master..master')
    try:
        count1 = sum(1 for c in commits_ahead)
    except:
        count1 = 0

    commits_behind = repo.iter_commits('master..origin/master')
    try:
        count2 = sum(1 for c in commits_behind)
    except:
        count2 = 0

    changedFiles = [ item.a_path for item in repo.index.diff(None) ]

    count3 = sum(1 for c in changedFiles)
    if count3 > 0:
        add_text(direc_name + "| color=red")
        outdated_repos += 1
    else:
        add_text(direc_name + "| color=green")
    add_text("--" + "Copy path | bash='echo "+direc+" | pbcopy '")
    add_text("--" + "Open location | bash='open "+direc+"'")
    add_text("--" + file)
    add_text("-----")
    add_text("--" + "Branches:")
    for branch in branches:
        add_text("----" + `branch.name`)
        add_text("------ Checkout | bash='cd "+direc+" && git checkout "+branch.name+"' ")
        add_text("------ Pull origin | bash='cd "+direc+" && git pull origin "+branch.name+"' ")
    add_text("--" + "Tags:")
    for tag in tags:
        add_text("----" + `tag.name`)
        add_text("------ Checkout | bash='cd "+direc+" && git checkout "+tag.name+"' ")
    add_text("-----")
    add_text("--"+ "Cur. branch: " + `active_branch` )
    if cur_tag is not None:
        add_text("--"+ "Cur. tag: " + `cur_tag.name` )
    add_text("--" + "No. commits ahead: " + str(count1) )
    add_text("--" + "No. commits behind: " + str(count2) )
    add_text("--" + "No. changed files: " + str(count3) )
    for changedFile in changedFiles:
        add_text("----" + changedFile)

add_text("---")


add_text("Refresh | refresh=true image='iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAADAFBMVEX///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAmJiYnJycoKCgpKSkqKiorKyssLCwtLS0uLi4vLy8wMDAxMTEyMjIzMzM0NDQ1NTU2NjY3Nzc4ODg5OTk6Ojo7Ozs8PDw9PT0+Pj4/Pz9AQEBBQUFCQkJDQ0NERERFRUVGRkZHR0dISEhJSUlKSkpLS0tMTExNTU1OTk5PT09QUFBRUVFSUlJTU1NUVFRVVVVWVlZXV1dYWFhZWVlaWlpbW1tcXFxdXV1eXl5fX19gYGBhYWFiYmJjY2NkZGRlZWVmZmZnZ2doaGhpaWlqampra2tsbGxtbW1ubm5vb29wcHBxcXFycnJzc3N0dHR1dXV2dnZ3d3d4eHh5eXl6enp7e3t8fHx9fX1+fn5/f3+AgICBgYGCgoKDg4OEhISFhYWGhoaHh4eIiIiJiYmKioqLi4uMjIyNjY2Ojo6Pj4+QkJCRkZGSkpKTk5OUlJSVlZWWlpaXl5eYmJiZmZmampqbm5ucnJydnZ2enp6fn5+goKChoaGioqKjo6OkpKSlpaWmpqanp6eoqKipqamqqqqrq6usrKytra2urq6vr6+wsLCxsbGysrKzs7O0tLS1tbW2tra3t7e4uLi5ubm6urq7u7u8vLy9vb2+vr6/v7/AwMDBwcHCwsLDw8PExMTFxcXGxsbHx8fIyMjJycnKysrLy8vMzMzNzc3Ozs7Pz8/Q0NDR0dHS0tLT09PU1NTV1dXW1tbX19fY2NjZ2dna2trb29vc3Nzd3d3e3t7f39/g4ODh4eHi4uLj4+Pk5OTl5eXm5ubn5+fo6Ojp6enq6urr6+vs7Ozt7e3u7u7v7+/w8PDx8fHy8vLz8/P09PT19fX29vb39/f4+Pj5+fn6+vr7+/v8/Pz9/f3+/v7///87ptqzAAAAJXRSTlMAgA5ABAHjYRLswnooVM0CyLDK2mCpIMSvX5AFm5SRscBeH2Kql1edqgAAAGdJREFUeJyNjUcSgCAUQ1GKSlGw9879r6j4Wbogm0zeTBKEgkQSnrFmQBhDTstcyLbu+jH6cqENdT7NFoCq4s+t9QDFYU+/8t3oXYNcKQ8W4pwaXQBYt/04pcjLFCoY0+tmGU9I2NMDXoEEmA7BEvIAAAAASUVORK5CYII=' ")

print('[git:{}/{}]'.format(total_repos-outdated_repos, total_repos))

print(output)
