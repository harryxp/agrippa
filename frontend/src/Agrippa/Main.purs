module Agrippa.Main (main) where

import Prelude (Unit, bind, discard, pure, show, void, ($), (*>), (>>=), (<>))
import Control.Monad.Aff (runAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.JQuery (JQuery, JQueryEvent, append, create, getWhich, getValue, on, ready, select, setText, toggle)
import Control.Monad.Except (runExcept)
import DOM (DOM)
import DOM.HTML.Types (WINDOW)
import Data.Either (Either(..))
import Data.Foreign (readString)
import Data.StrMap (lookup)
import Data.String (Pattern(..), indexOf, splitAt)
import Data.FoldableWithIndex (traverseWithIndex_)
import Data.Tuple.Nested (Tuple3, tuple3, uncurry3)
import Network.HTTP.Affjax (AJAX, get)

import Agrippa.Config (Config, getTaskAttr, getTasksByKeyword, getTaskNamesByKeyword)
import Agrippa.Plugins.Registry (Plugin(..), pluginsByName)
import Agrippa.Utils (mToE, openUrl)

main :: forall e. Eff (ajax :: AJAX, dom :: DOM, window :: WINDOW | e) Unit
main = ready $
  loadConfig (\config -> buildHelp config *> installInputListener config)

loadConfig :: forall e. (Config -> Eff (ajax :: AJAX, dom :: DOM | e) Unit)
                     -> Eff (ajax :: AJAX, dom :: DOM | e) Unit
loadConfig onSuccess = void $
  runAff
    (\_ -> displayStatus "Failed to retrieve config from server.")
    (\{ response: r } -> onSuccess r)
    (get "/agrippa/config/")

installInputListener :: forall e. Config
                               -> Eff (ajax :: AJAX, dom :: DOM, window :: WINDOW | e) Unit
installInputListener config = select "#agrippa-input" >>= on "keyup" (inputListener config)

-- input and output

inputListener :: forall e. Config
                        -> JQueryEvent
                        -> JQuery
                        -> Eff (ajax :: AJAX, dom :: DOM, window :: WINDOW | e) Unit
inputListener config event inputField = do
  keyCode <- getWhich event
  foreignInput <- getValue inputField
  case runExcept (readString foreignInput) of
    Left err -> displayStatus (show err)
    Right wholeInput -> dispatchToTask config keyCode wholeInput

dispatchToTask :: forall e. Config
                         -> Int
                         -> String
                         -> Eff (ajax :: AJAX, dom :: DOM, window :: WINDOW | e) Unit
dispatchToTask config keyCode wholeInput =
  case findTask config keyCode wholeInput of
    Left err -> case keyCode of
                  13 -> openUrl ("https://www.google.com/search?q=" <> wholeInput) >>= displayOutput
                  otherwise -> displayStatus (err <> "  Press <Enter> to search on Google.") *> clearOutput
    Right t3 -> (uncurry3 execTask t3) keyCode

findTask :: Config -> Int -> String -> Either String (Tuple3 Plugin Config String)
findTask config keyCode wholeInput = do
  i                                     <- mToE "No keyword found in input."                            (indexOf (Pattern " ") wholeInput)
  { before: keyword, after: taskInput } <- mToE "Failed to parse input.  This is impossible!"           (splitAt i wholeInput)
  tasksByKeyword                        <- getTasksByKeyword config
  taskConfig                            <- mToE ("Keyword '" <> keyword <> "' not found in config.")    (lookup keyword tasksByKeyword)
  pluginName                            <- getTaskAttr "plugin" taskConfig
  plugin                                <- mToE ("Can't find plugin with name '" <> pluginName <> "'.") (lookup pluginName pluginsByName)
  pure (tuple3 plugin taskConfig taskInput)

execTask :: forall e. Plugin
                   -> Config
                   -> String
                   -> Int
                   -> Eff (ajax :: AJAX, dom :: DOM, window :: WINDOW | e) Unit
execTask (Plugin { name: n , onIncrementalChange: inc , onActivation: act }) taskConfig taskInput keyCode = do
  displayStatus n
  case keyCode of
    13 -> act taskConfig taskInput displayOutput >>= displayOutput -- activation
    otherwise -> displayOutput (inc taskConfig taskInput)          -- incremental

displayStatus :: forall e. String -> Eff (dom :: DOM | e) Unit
displayStatus r = select "#agrippa-status" >>= setText r

displayOutput :: forall e. String -> Eff (dom :: DOM | e) Unit
displayOutput r = select "#agrippa-output" >>= setText r

clearOutput :: forall e. Eff (dom :: DOM | e) Unit
clearOutput = select "#agrippa-output" >>= setText ""

-- help

buildHelp :: forall e. Config -> Eff (dom :: DOM | e) Unit
buildHelp config = do
  helpLink <- select "#agrippa-help-link"
  helpContent <- select "#agrippa-help-content"
  buildHelpTextForTasks config helpContent
  on "click" (helpLinkListener helpContent) helpLink

buildHelpTextForTasks :: forall e. Config -> JQuery -> Eff (dom :: DOM | e) Unit
buildHelpTextForTasks config helpContent =
  case getTaskNamesByKeyword config of
    Left err -> displayStatus err
    Right m -> traverseWithIndex_ buildHelpTextForTask m

buildHelpTextForTask :: forall e. String -> String -> Eff (dom :: DOM | e) Unit
buildHelpTextForTask keyword taskDesc = do
  helpTable <- select "#agrippa-help-table"
  tr <- create "<tr>"
  createTd keyword tr *> createTd taskDesc tr *> append tr helpTable
  where
    createTd :: String -> JQuery -> Eff (dom :: DOM | e) Unit
    createTd txt tr = create "<td>" >>= \td -> setText txt td *> append td tr

helpLinkListener :: forall e. JQuery -> JQueryEvent -> JQuery -> Eff (dom :: DOM | e) Unit
helpLinkListener helpContent _ _ = toggle helpContent

