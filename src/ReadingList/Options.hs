{-# LANGUAGE OverloadedStrings #-}


module ReadingList.Options
    ( opts
    , opts'
    , execParser
    ) where


import           ReadingList.Types
import           Filesystem.Path.CurrentOS hiding (decode)
import           Options.Applicative
import           Prelude                   hiding (FilePath)


fileOption :: Mod OptionFields FilePath -> Parser FilePath
fileOption = option (pure . decodeString)

opts :: Parser Opts
opts =   Opts
     <$> fileOption (  short 's' <> long "epub-spec" <> metavar "JSON_FILE"
                    <> help "The JSON file detailing what will be in the EPUB.")
     <*> optional   ( fileOption (  short 'w' <> long "working"
                                 <> metavar "WORKING_DIR"
                                 <> help "The location of a working directory."))
     <*> fileOption (  short 'o' <> long "output" <> metavar "EPUB_FILE"
                    <> help "The output file to create.")

opts' :: ParserInfo Opts
opts' = info (helper <*> opts)
             (  fullDesc
             <> progDesc "Downloads web pages into an EPUB."
             <> header "reading-list -- downloads web pages into an EPUB.")
