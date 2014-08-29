{-# LANGUAGE OverloadedStrings #-}


module Main where


import           Control.Lens
import           Data.Aeson
import           Data.Aeson.TH
import qualified Data.ByteString.Lazy      as B
import           Data.Char                 (toLower)
import qualified Data.Text                 as T
import           Filesystem.Path.CurrentOS hiding (decode)
import           Prelude                   hiding (FilePath)

import           Epub.Options
import           Epub.Types

main :: IO ()
main = do
    o <- execParser opts'
    print o
    e <- (fmap decode . B.readFile . encodeString $ _epubSpec o) :: IO (Maybe Epub)
    print e
