{-# LANGUAGE OverloadedStrings #-}


module ReadingList.Options
    ( readingListOptions
    ) where


import qualified Filesystem.Path.CurrentOS as FS
import           Options.Applicative

import ReadingList.Types


readingListOptions :: ParserInfo ReadingList
readingListOptions =
    info (helper <*> readingList)
            (  fullDesc
            <> progDesc "Generate EPUBs from a reading list."
            <> header "reading-list -- generate EPUBs")

filePathReader :: Mod OptionFields FS.FilePath
filePathReader = reader (return . FS.decodeString)

filePathOption :: Mod OptionFields FS.FilePath -> Parser FS.FilePath
filePathOption options = nullOption (filePathReader <> options)

readingList :: Parser ReadingList
readingList =   RL
            <$> filePathOption
                (  long "input"
                <> short 'i'
                <> metavar "INPUT-FILE"
                <> help "The input file containing URLs to read.")
            <*> filePathOption
                (  long "html-dir"
                <> short 'H'
                <> metavar "HTML-DIR"
                <> value "./html"
                <> help "The working directory to store the HTML files in.")

