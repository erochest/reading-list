{-# LANGUAGE OverloadedStrings #-}


module Main where


import           Options.Applicative

import ReadingList.Options


main :: IO ()
main = print =<< execParser readingListOptions

