{-# LANGUAGE OverloadedStrings #-}
module Main where

import Data.Text.Lazy (Text, pack, unpack)
import System.Process (readProcess)
import Web.Scotty (ActionM, file, get, liftAndCatchIO, param, scotty, text)

main :: IO ()
main = scotty 3000 $ do
  get "/agrippa/" $ do
    file "web/index.html"

  get "/agrippa/config" $ do
    file "agrippa-config.json"

  get "/agrippa/js/scripts.js" $ do
    file "web/js/scripts.js"

  get "/agrippa/file-search/:word" $ do
    keyword <- param "word" :: ActionM Text
    result <- (liftAndCatchIO . locate) keyword
    text result

  get "/agrippa/app-launcher/:word" $ do
    app <- param "word" :: ActionM Text
    result <- (liftAndCatchIO . launch) app
    text result

locate :: Text -> IO Text
locate keyword = pack <$> readProcess "locate" [unpack keyword] ""

launch :: Text -> IO Text
launch app = pack <$> readProcess (unpack app) [] ""
