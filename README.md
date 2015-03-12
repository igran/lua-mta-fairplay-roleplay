## Welcome to FairPlay Gaming

FairPlay Gaming is a gaming community created in December 2010. We enjoy playing games without limits and we try to push our community forward by having fun and searching new unique ways to expand our community to more games for more people. You are more than welcome to our community and we hope that you will enjoy your stay with us!

### Gamemode introduction

This is a Multi Theft Auto Roleplay gamemode, designed specifically for FairPlay Gaming. This script is based on modules, which extend each others functionality and combine to make the gamemode actually happen. Core modules run the server, and plugins add more freedom for developers to create other systems on top of the main layer. These two layers are able to communicate with each other and extend each other. This is a powerful and efficient way to run a server, because you can slide one module out, patch it, slide it back in and it will be compatible.

I highly recommend installing Git on your servers and running both live and development servers simultaneously on separate databases and branches – live on master, and development on its own branch, or vice versa. This way you have the greatness of Git at hand, and good development process going on – and then you can just tuck the release version to the live server by taking it offline and then restarting it a minute afterwards. Fast, simple and efficient.

I do not give any direct assistance with Git server communications, but you can find good solutions and documentation on how to do that online with step-by-step tutorials. I highly recommend doing this, as it is really worth it.

**Please note**, that this is in development, and should not be used for anything yet! You can mark issues and make pull requests. This script is missing some features, which is exactly why this should not be used yet.

### Installation and setup

1. **Clone the repository.** Clone the repository to your Multi Theft Auto folder through your favoured Git program, if you do not yet have a Git program I highly recommend you get one, or otherwise you will not be able to make changes on your computer (except online on GitHub, which is a bit difficult at times). You can find a list of a few Git programs below.

2. **Set up database configuration.** Set up your database configuration in `database/meta.xml` settings.

3. **Start the Multi Theft Auto server.** You now have a full copy of the repository on your computer. With this copy you should now be able to run your server.

4. **Join your local server.** After you started your Multi Theft Auto server you are now able to play on it. Your server has automatically initialized all the resources just like on the live server.

5. **You are ready to go.** Now I would say you are pretty much done! You can now develop on your local server and make changes to the resource files as much as you want. You do not need to push through the Git server each time you make a commit necessarily, but even if you do, it is easy since all changes are automatically subscribed on to your local Git copy. This helps you do your work faster and more efficiently!

### Quick start

#### Starting via F8 console

`srun startResource( getResourceFromName( "initializer" ) )`

#### Starting via mtaserver.conf

`<resource src="initializer" startup="1" protected="0" />`

### Important note

In order for the script to initialize correctly, you need to run the server once and let it show all errors until errors stop outputting to the server console. After this, restart the server and there should be no errors whatsoever.

This is the process at the moment, because the script automatically creates the database tables and initializes the core code accordingly to your server configuration. It will also generate a secret key to your server files, which will keep your user passwords secured after they log in.

There will be a small change to this process later on, when I have more time to spend on it. In the future there will be no need for a restart, because the script will not initialize before the database tables have been created and MySQL connection is working properly.

Initializer will automatically shut down the server, or alternatively all resources, if it finds that a core module has been damaged and cannot respond to requests. Whenever you make changes to the core modules, I highly recommend you test them on a development server first and disable this shutdown feature in the initializer resource. There is a dedicated variable that will toggle this functionality in case you want to run resources in development mode.

All core modules have to be running, as some of them share data, functionality or other things. You can restart these modules if you wish, as it will not cause any interruptions usually. However, some modules are more actively used, which can interrupt interactions by people or the server, which is why a development server should be your place to test new features on.

Plugins however can be stopped and not even started if you wish. Plugins serve no other than themselves, and work as small extensions to the core. I have included a couple native plugins of the script in the plugins folder (e.g. cctv system, superman for administrators and scoreboard window). These plugins have the ability to use the exported functionality of the core modules, and are able to import database tables if needed (the cctv plugin does this at the moment). This import functionality script can be found on the *plugins* -folder root `import_table.lua`.

### Git programs

There are several Git programs that give you the ability to clone a remote repository to your local machine. You should see the up -and downsides of each program individually and see which one is the best fit for you and your use.

* **[GitHub for Windows](https://windows.github.com/), [GitHub for Mac](https://mac.github.com/).** This is GitHub's native Git program. It comes with the best core functionality on the UI, but also installs you a command line application so you can test out both and decide which one is for you. You log in with your GitHub credientials and start doing some fancy commits!
* **[SourceTree](http://www.sourcetreeapp.com/).** Not necessarily one of the best tools for beginners, but does its thing. The UI is a little bit messy as they tried to tuck in all Git functionality (even the slightest ones). But if you feel like SourceTree fits your class, feel free to do that!
* **[Tower](http://www.git-tower.com/).** Tower is a rather easy to use and well made Git tool. You can do all of the things you need, pretty much the same way as on GitHub for X. The only downside for this tool is, that it has a 30-day trial until it becomes necessary for you to purchase the full version.

If you feel that you only just want to use the very basic command line version, you may do that as well. Download Git through [Git's official site](http://git-scm.com/) and get started!

### Official repository introduction

This is the official Multi Theft Auto repository of FairPlay Gaming. We synchronize all files through Git, specifically GitHub, so that all contributors can list and find all commits and files for easier use. We do not use FTP to modify files, but instead work with local copies of the gamemode and after we are satisfied we push the commits to the live server. This way we do not have to bother other players with constant updates and bugs.

Git is also a good tool for keeping up data on different versions, branches and such. With Git we are able to push commits and each commit is its own "revision". If we want to, we can always create a branch for a specific incoming update. We can batch specific system(s) into that branch and later merge it with the master copy when we feel that it is ready to go for a release version.

We are not able to push commits directly on to the server through Git. The reason why this is not possible is that we are running on a dedicated game server machine and I do not possess any privileges for installing and setting up Git programs. We could potentially be able to use command line to update the local Git repository copy on the server, so that all updates would be pulled and when we hit 'refreshall', it would reload all of the changed resources. This system is something I would love to get to know better and I hope we can manage this later if we ever do, and if ever purchase and set up a virtual private server.

With Git all contributors have the same data, same files and pretty much same version of everything. If all contributors opened one single file and started making changes to it in different spots, these changes would not cause overwriting problems. If we used FTP, we would all make changes to the single file, but as there is no "file synchronization handler", the file is always overwritten to the version, which the owner has at the very moment it is pushed on to the server. Git on the other hand specifically looks for actual changes and pushes those accordingly to all known versions so, that the actual file is never overwritten by accident. So it never actually pushes a full file, but just that one typographical fix you made - that, is just awesome.

You also do not need internet connection to make changes. You can do local changes at any place at any time, and when you do have access to internet you can see the recent changes if any, and push to the server accordingly. This way you can work anywhere, and then later save it to "the cloud", and by cloud I mean, that your work is saved on a different machine somewhere else in the world. This way if your hard drive is lost, you should always be able to pull that one last commit via Git, hooray!

If all of this still seems a little bit fuzzy for you, feel free to [check out a web-based test on Git](https://try.github.io/)!
