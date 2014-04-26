{-# LANGUAGE OverloadedStrings #-}


module Main where


import           Options.Applicative


main :: IO ()
main = print =<< execParser opts

data ReadingList = RL
                 deriving (Show)

opts :: ParserInfo ReadingList
opts = info (helper <*> readingList)
            (  fullDesc
            <> progDesc "Generate EPUBs from a reading list."
            <> header "reading-list -- generate EPUBs")

readingList :: Parser ReadingList
readingList = pure RL
