### About

I was using [SpaceVim](https://github.com/SpaceVim/SpaceVim) and noticed that the plugin manager was cloning 
git repositories without using the ```--depth``` option on ```git clone```. 
The end result, of course, is that you end up with a complete git repository (when you might not want/need one). 

I also thought about the number of times I had done a non-shallow clone and how it would be nice to have a way to clean that up.

### Install/Usage

Copying the script to a location in your ```bash $PATH``` would be preferable - I tend to like places like ```/usr/local/sbin/ or /usr/local/bin```. Or perhaps another directory where you keep your favorite scripts :grin:. 

If in your PATH, simply run the script -- ```git-shallowdepth1.sh```. As explained below, if the current directory is a git repo, it will operate on that directory (and all submodules of that repo). If not, it will search *from the current directory* for all directories below that contain a .git directory (e.g. all repos beneath the current directory). 

### Warning

Be really extra careful running this in high level directories... Running it in / could produce some very undesirable results. 

### Purpose/Function

As of the initial commit, this is just a simple bash script that, when run:

* Checks the current directory for a ".git" directory (e.g. is the current dir a git repository)
* If yes, confirms before continuing - then shallows the git repo to a depth of 1
* It then checks whether or not there are submodules
* If yes, runs the cleanup commands recurisvely on all submodules using the ```git submodule foreach``` command

If the current directory is ***not*** a git repository (e.g. no ".git" directory was found): 

* Runs a ```find``` for all directories beneath the current directory that contain a ".git" directory
* Confirms with the user whether or not to proceed
* Loops through the above code (sans individual confirmation) and runs the shallow operation on each directory found

Additionally, the script totals space used before/after and the difference saved for each repo -- and outputs it at the end. 

### Todo

- [ ] Some additional warnings/checks perhaps? Like "if pwd is /, put up red and yellow flashing ext and ask for double secret confirmation before proceeding"
- [ ] Probably double check to make sure that all of the git cleanup commands are necessary (could be overlap)
- [ ] More documentation (e.g. --help)
- [ ] Options for depth control (e.g. specify a depth to use or a date)
- [ ] Error Checking / Prettier Output
- [ ] Test on more systems (Initial version was written on Termux/Android)


