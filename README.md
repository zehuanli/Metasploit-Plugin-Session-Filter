# Metasploit Plugin Session Filter

## Introduction

When listening for a reverse shell (eg. under `multi/handler`) from a random IP on a popular port (22, 80, 443, 8080, ...), it's very likely to receive tons of unwanted connections triggered by annoying scripted attacks and scans from the Internet. To save some time and efforts inspecting and closing those trash sessions, the plugin can automatically validate the sessions upon their creation, with the following rules:

- Echo challenge

  The plugin generates a random (NOT crypto secure random) string and executes the command `echo [random_string]\n` on the session. A normal shell is expected to respond with the exact same string in its output, so it will be terminated if it fails to echo the string.

- Blacklist

  A session will be immediately terminated once a blacklisted string is detected in its output, unless it has passed the echo challenge. This can be used to quickly identify attacks and scans.
  
  For example, a connection to port `8080` sending `GET /manager/html HTTP/1.0` is not likely to be a legitimate reverse shell. If we're not expecting `HTTP` during the validation of our reverse shells, we can put `HTTP` into the blacklist, and then most stupid HTTP scans will be filtered out.
  
  Note that once the user interacts with a session, the blacklist function will be disabled for this session, so that the upcoming output will not be affected.

## Features

- Echo challenge

  See above

- Blacklist

  See above

- Notification

  Send message through your own notification channel when a session has been identified valid. Use console command `sf_notify` to toggle on/off for this feature.

- Auto exit

  Exit the session automatically once the shell is deemed valid. This is useful if you want to keep the shell handler running when you're not monitoring it, without stacking hundreds of opened shells in hand and adding too many suspicious processes for the target (if your reverse shell executable is not that smart). Use console command `sf_autoexit` to toggle on/off for this feature.

- Simple HTTP APIs

  Upon loading the plugin, several simple HTTP APIs are exposed to the localhost that allow you to control some of the features mentioned above. This feature may or may not be useful to you, and can be disabled (by you modifying the code, for now).

## Installation

1. Put the `session_filter.rb` under Metasploit Framework `plugins` folder.
1. In `msfconsole`, execute `load session_filter`

## Important Notice

- The "echo challenge" should under no circumstances be used as a means of authentication. It is effortless for an adversary to bypass the challenge and fake a "legitimate reverse shell". However, it shouldn't add any new attack surface to your server either.

- The plugin executes `echo` command on the session, which to some extent makes more noise inside the target environment in the beginning. So as the "auto exit" feature.

- The plugin **might** kill an expected session, when it fails the challenge due to timeout (or other unknown reasons). Use at your own risk!

- The "simple HTTP APIs" feature **will** open a port on the localhost and listen for requests to control the features for the plugin. Disable it if you consider it risky. Improvement to this feature may be posted in the future.

## Miscs

Fail2ban regex: `failregex = core: <HOST> failed echo challenge and got killed\.$`
