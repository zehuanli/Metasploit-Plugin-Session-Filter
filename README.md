# Metasploit Plugin Session Filter

## Introduction

When listening for a reverse shell (eg. under `multi/handler`) from unknown IP on a popular port (22, 80, 443, 8080, ...), it's very like to receive tons of unexpected connections triggered by annoying scripted attacks and scans from the Internet. To save some time and effort inspecting those trash sessions, the plugin can automatically validate the sessions upon their creation, with the following rules:

- Echo challenge

  The plugin generates a random (NOT crypto secure random) string and execute the command `echo [random_string]\n` on the session. A reverse shell is expected to respond with the exact same string in its output, so the session will be terminated if it fails to echo the string.

- Blacklist

  A session will be immediately terminated once a blacklisted string is detected in its output, unless it passes the echo challenge. This can be used to quickly identify attacks and scans.
  
  For example, a connection to port `8080` with `GET /manager/html HTTP/1.0` is not likely to be a legitimate reverse shell. If we're not expecting `HTTP` in any of our reverse shells, we can put `HTTP` into the blacklist, and then most stupid HTTP scans will be filtered out.
  
  Note that once the user interacts with a session, the blacklist function will be disabled for it, so that upcoming output will not be affected.

## Features

- Echo challenge

  See above

- Blacklist

  See above

- Notification

  Send message through your own notification channel when a session has been identified valid. Use console command `notify` to toggle on/off for this function.

## Installation

1. Put the `session_filter.rb` under Metasploit Framework `plugins` folder.
1. In `msfconsole`, execute `load session_filter`

## Important Notice

- The "echo challenge" should under no circumstances be used as a means of authentication. It is effortless for an adversary to bypass this challenge and fake a "legitimate reverse shell".

- The plugin executes `echo` command on the session, which to some extent makes more noise inside the target environment in the beginning.

- The plugin **might** kill an expected session, when it fails the challenge due to timeout (or other unknown reasons). Use at your own risk!
