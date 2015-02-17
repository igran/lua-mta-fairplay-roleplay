## FairPlay Plugins

In this directory you can find native plugins made for exclusively FairPlay Gaming's role play gamemode.

These systems are completely modular, which can be started and stopped whenever you please. They use exported functionality provided by the default role play gamemode.

Plugins basically extend the functionality provided by the core code.

### import_table.lua

You can use the `import_table.lua` file in your own plugins. This is a copy-paste file that will create database tables into the very base database that your server is using through the database resource. You only need to edit the `imports` table by adding your new table name as key, and inside of that you make a table with all the columns and their settings in it. You can use the default one as an example on how to make it work right.
