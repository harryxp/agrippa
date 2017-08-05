module Agrippa.Config (Config, getBooleanVal, getStrMapVal, getStringVal, getConfigVal) where

import Prelude (bind, (<>))
import Data.Argonaut.Core (Json, toBoolean, toObject, toString)
import Data.Either (Either)
import Data.Maybe (Maybe)
import Data.StrMap (StrMap, lookup)

import Agrippa.Utils (mToE)

type Config = Json

getBooleanVal :: String -> Config -> Either String Boolean
getBooleanVal key config = getConvertedVal key config toBoolean

getStrMapVal :: String -> Config -> Either String (StrMap Config)
getStrMapVal key config = getConvertedVal key config toObject

getStringVal :: String -> Config -> Either String String
getStringVal key config = getConvertedVal key config toString

getConvertedVal :: forall a. String -> Config -> (Config -> Maybe a) -> Either String a
getConvertedVal key config convert = do
  valJson <- getConfigVal key config
  mToE    ("Config Error: expect value of '" <> key <> "' to be a different type.") (convert valJson)

getConfigVal :: String -> Config -> Either String Config
getConfigVal key config = do
  jObject <- mToE  "Config Error: expect JSON object."                                (toObject config)
  mToE            ("Config Error: expect JSON object with a(n) '" <> key <> "' key.") (lookup key jObject)
