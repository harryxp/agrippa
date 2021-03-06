module Agrippa.Plugins.FileSystem.UnixExecutableSearch (unixExecutableSearch) where

import Prelude (Unit)
import Data.Maybe (Maybe)
import Effect (Effect)
import JQuery (JQuery)

import Agrippa.Config (Config)
import Agrippa.Plugins.PluginType (Plugin(..))
import Agrippa.Plugins.FileSystem.Commons as C

unixExecutableSearch :: Plugin
unixExecutableSearch = Plugin { name: "UnixExecutableSearch"
                              , prompt: C.prompt
                              , promptAfterKeyTimeout: suggest
                              , activate: open
                              }

suggest :: String -> Config -> String -> (JQuery -> Effect Unit) -> Effect Unit
suggest = C.suggest "/agrippa/unix-executable/suggest" "/agrippa/unix-executable/open"

open :: String -> Config -> String -> Effect (Maybe JQuery)
open = C.open "/agrippa/unix-executable/open"
