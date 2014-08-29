{-# LANGUAGE OverloadedStrings #-}


module Main where


import           Control.Lens
import           Control.Monad
import           Data.Aeson
import           Data.Aeson.TH
import qualified Data.ByteString.Lazy      as B
import           Data.Char                 (toLower)
import qualified Data.Text                 as T
import           Filesystem.Path.CurrentOS hiding (decode)
import           Network.Wreq
import           Prelude                   hiding (FilePath)

import           Epub.Options
import           Epub.Types

main :: IO ()
main = do
    o     <- execParser opts'
    mspec <- fmap decode . B.readFile . encodeString $ _epubSpec o

    case mspec of
        Nothing   -> putStrLn "ERROR: Invalid epub spec file."
        Just spec -> forM_ (_epubChapters spec) $ \url -> do
            let url' = T.unpack url
            putStrLn url'
            print . (^. responseStatus . statusCode) =<< get url'
