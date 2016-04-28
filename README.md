# objectively-the-unixiest

Finds repos on Github that do one thing and do it well.

I use the "size" property of the repo as a proxy for "doing one thing", the idea being that simple tools will be small, focused, and infrequently updated. I use the number of stars on the repo to measure "doing a thing well".

## usage

You'll need Ruby >= 1.9.3 and a Github account.

```bash
bundle # installs the dependencies - one-time setup
ruby crawl.rb
```
