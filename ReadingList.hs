{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}


module Main where


import           Control.Error.Script
import           Control.Lens
import qualified Data.Text            as T
import           Filesystem
import           Network.Wreq
import           Options.Applicative
import qualified Filesystem.Path.CurrentOS as FS

import           ReadingList.Options
import           ReadingList.Types


main :: IO ()
main = runScript . readingList =<< execParser readingListOptions


readingList :: ReadingList -> Script ()
readingList RL{..} = do
    scriptIO $ createTree rlHtmlDir
    scriptIO (readTextFile rlInputFile) >>=
        mapM_ (downloadLink rlHtmlDir) . T.lines

downloadLink :: FS.FilePath -> T.Text -> Script FS.FilePath
downloadLink = undefined

