#!/bin/sh

# Set up an array with outboxes
sentboxes=( "~/Mail/acc1/acc1.sent/ ~/Mail/acc2/acc2.Sent" )

# Run mu on each of them
for dir in "${sentboxes[@]}"
do
    mu index --nocleanup --maildir="${dir}" --muhome=~/.mu-sent-index
done
