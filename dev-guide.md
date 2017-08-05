# Environment setup

1a. Install PureScript stuff (Linux: pacman, etc.)

1b. Install PureScript stuff (Mac: MacPorts)

    $ sudo port selfupdate
    $ sudo port upgrade outdated
    $ sudo port install npm4
    $ sudo npm install -g purescript pulp bower

2a. Install Haskell stuff (Linux: pacman, etc.)

2b. Install Haskell stuff (Mac)

See https://docs.haskellstack.org/en/stable/install_and_upgrade/#macos

3. Directory structure

    $ mkdir agrippa
    $ cd agrippa
    $ mkdir frontend            # this holds a PureScript project

4. Frontend setup

    $ cd frontend
    $ pulp init     # pulp is a project management tool for PureScript
                    # this creates a PureScript project in current directory
    $ pulp build
    $ pulp test     # make sure everything looks good

5. Backend setup

    $ cd agrippa
    $ stack new backend         # just like pulp, stack is a project management tool for Haskell
                                # this creates a `backend` dir, which holds a Haskell project
    $ stack build               # make sure it's working
                                # may need `stack setup` to install the right ghc

6. Use git to remember this initial environment

    $ cd agrippa
    $ git init
    $ git add .
    $ git commit -m 'Initial environment.'

7. Create a repo on github/bitbucket and push the project.

# Development

## Frontend

1. Install some useful PureScript libraries:

    $ bower install purescript-jquery purescript-numbers purescript-string-parsers purescript-affjax purescript-stringutils purescript-argonaut-core -S

2. Create an HTML page that includes a JavaScript file, which can be generated by

    $ pulp browserify -O --main Agrippa.Main --to web/js/scripts.js

3. To see more useful commands try `pulp`.

    $ pulp build    # type check
    $ pulp psci     # or `pulp repl`
    > import Agrippa.Main

4. Haskell's `undefined` can be mimiced by `unsafeCoerce unit`.

    import Unsafe.Coerce (unsafeCoerce)

5. Resources:

https://github.com/purescript/documentation
https://pursuit.purescript.org/
https://leanpub.com/purescript/read
https://github.com/cbaatz/purescript-intro

## Backend

1. Add a few libraries to  backend.cabal:

    process >= 1.4.3.0
    scotty >= 0.11.0
    text >= 1.2.2.1

Then make sure everything works:

    $ stack build

2. To type check:

    $ stack ghci

3. To run the server:

    $ stack exec backend-exe

4. To see more useful commands try `stack`.

# TODOs

## General

- Snippets
- TODO list
- Top level suggestion
- Check runAff response status code
- Do not look up config repeatedly
- Put Google URL into config
- Formatted string instead of <> (Text.Formatting?)
- Learn Except

## Calculator plugin

- Support power.  See purescript-math's Math.pow

## File Search plugin

- limit size of output
- highlight keyword
- error handler for runAff
- check status code?
- 500 internal error when locate fails

## Online Search plugin

- query using a template library?  Text.Formatting?
- only one query parameter is allowed now