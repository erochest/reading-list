{-# LANGUAGE OverloadedStrings #-}


module Epub.Options
    ( opts
    , opts'
    , execParser
    ) where


import           Epub.Types
import           Filesystem.Path.CurrentOS hiding (decode)
import           Options.Applicative
import           Prelude                   hiding (FilePath)


fileOption :: Mod OptionFields FilePath -> Parser FilePath
fileOption fields = nullOption (reader (pure . decodeString) <> fields)

opts :: Parser Opts
opts =   Opts
     <$> fileOption (  short 's' <> long "epub-spec" <> metavar "JSON_FILE"
                    <> help "The JSON file detailing what will be in the EPUB.")
     <*> fileOption (  short 'o' <> long "output" <> metavar "EPUB_FILE"
                    <> help "The output file to create.")

opts' :: ParserInfo Opts
opts' = info (helper <*> opts)
             (  fullDesc
             <> progDesc "Downloads web pages into an EPUB."
             <> header "epub -- downloads web pages into an EPUB.")
