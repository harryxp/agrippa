module Agrippa.Plugins.Registry (Plugin(..), pluginsByName) where

import Prelude (Unit, (<$>))
import Control.Monad.Eff (Eff)
import Data.StrMap (StrMap, fromFoldable)
import Data.Tuple (Tuple(..))
import DOM (DOM)
import DOM.HTML.Types (WINDOW)
import Network.HTTP.Affjax (AJAX)

import Agrippa.Config (Config)
import Agrippa.Plugins.AppLauncher  as A
import Agrippa.Plugins.Calculator   as C
import Agrippa.Plugins.FileSearch   as F
import Agrippa.Plugins.OnlineSearch as O

newtype Plugin =
  Plugin { name          :: String
         , onInputChange :: forall e. Config
                                   -> String
                                   -> (String -> Eff (ajax :: AJAX, dom :: DOM, window :: WINDOW | e) Unit)
                                   -> Eff (ajax :: AJAX, dom :: DOM, window :: WINDOW | e) String
         , onActivation  :: forall e. Config
                                   -> String
                                   -> (String -> Eff (ajax :: AJAX, dom :: DOM, window :: WINDOW | e) Unit)
                                   -> Eff (ajax :: AJAX, dom :: DOM, window :: WINDOW | e) String
         }

plugins :: Array Plugin
plugins = [ Plugin { name: "AppLauncher"
                   , onInputChange: A.prompt
                   , onActivation: A.launch
                   }
          , Plugin { name: "Calculator"
                   , onInputChange: C.calculate
                   , onActivation: C.calculateOnActivation
                   }
          , Plugin { name: "FileSearch"
                   , onInputChange: F.prompt
                   , onActivation: F.search
                   }
          , Plugin { name: "OnlineSearch"
                   , onInputChange: O.prompt
                   , onActivation: O.search
                   }
          ]

pluginsByName :: StrMap Plugin
pluginsByName = fromFoldable ((\p@(Plugin { name: n }) -> Tuple n p) <$> plugins)
