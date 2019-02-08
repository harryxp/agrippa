module Agrippa.Plugins.FileSystem.LinuxFileSearch (linuxFileSearch) where

import Prelude (Unit)
import Data.Maybe (Maybe)
import Effect (Effect)
import JQuery (JQuery)

import Agrippa.Config (Config)
import Agrippa.Plugins.Base (Plugin(..))
import Agrippa.Plugins.FileSystem.Commons as C

linuxFileSearch :: Plugin
linuxFileSearch = Plugin { name: "LinuxFileSearch"
                         , onInputChange: suggest
                         , onActivation: open
                         }

suggest :: String -> Config -> String -> (JQuery -> Effect Unit) -> Effect (Maybe JQuery)
suggest = C.suggest "/agrippa/linux-file/suggest" "/agrippa/linux-file/open"

open :: String -> Config -> String -> Effect (Maybe JQuery)
open = C.open "/agrippa/linux-file/open"
