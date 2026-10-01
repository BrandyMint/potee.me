Potee
=====

Simple visual project management. New way of planning: now you know what is the
next step in your projects.

https://potee.pismenny.ru

Projects are bars on a zoomable timeline, events are milestones on them. No
sign-up needed: the first visit creates a board with a few sample projects.
Shortcuts are listed in [Keystrokes.md](Keystrokes.md).

Development
-----------

Ruby 3.4, Node 24, Docker (for PostgreSQL) and `port-selector`.

```sh
bundle install && npm install
bin/dev
```

Tests: `bundle exec rspec`, `npm test`, `npm run typecheck`, and with `bin/dev`
running `BASE_URL="http://127.0.0.1:$(port-selector --name web)" npm run e2e`.

Background
----------

Started at Rails Rumble 2012 (original post: http://blog.genue.ru/post/14561230063),
rewritten in 2026 on Rails 8 and React. The history of the original version is
in [Changes.md](Changes.md).

License
-------

[Attribution-Share Alike 3.0 Unported](http://creativecommons.org/licenses/by-sa/3.0/)
