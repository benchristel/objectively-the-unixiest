# objectively-the-unixiest

Finds repos on Github that do one thing and do it well.

I use the "size" property of the repo as a proxy for "doing one thing", the idea being that simple tools will be small, focused, and infrequently updated. I use the number of stars on the repo to measure "doing a thing well".

## Usage

You'll need:

- ruby >= 1.9.3 with the `bundler` gem installed
- a Github account with some starred repositories

```bash
bundle # installs the dependencies - one-time setup
ruby crawl.rb <github username>
```
