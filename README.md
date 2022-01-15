# Metasploit Plugin Session Filter

## Introduction

This plugin implements the features below, and can be used to add new filter functionalities as needed.

The "echo challenge" feature has been removed since it has recently been implemented quite similarily in Metasploit framework, namely `AutoVerifySession`.

## Features

- Notification

  Send message through your own notification channel when a session has been identified valid. Use console command `sf_notify` to toggle on/off for this feature.

- Auto exit

  Exit the session automatically once the shell is deemed valid. This is useful if you want to keep the shell handler running when you're not monitoring it, without stacking hundreds of opened shells in hand and adding too many suspicious processes for the target (if your reverse shell executable is not that smart). Use console command `sf_autoexit` to toggle on/off for this feature.

- Simple HTTP APIs

  Upon loading the plugin, several simple HTTP APIs are exposed to the localhost that allow you to control some of the features mentioned above. This feature may or may not be useful to you, and can be disabled (by you modifying the code, for now).

## Installation

1. Put the `session_filter.rb` under Metasploit Framework `metasploit-framework/embedded/framework/plugins/` folder.
1. Put the modified `handler.rb` under Metasploit Framework `metasploit-framework/embedded/framework/lib/msf/core/` folder, or add the `on_session_initialized` section to the original one.
1. In `msfconsole`, execute `load session_filter`
