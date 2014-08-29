{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}


module Main where


import           Control.Lens
import           Data.Aeson
import           Data.Aeson.TH
import qualified Data.ByteString.Lazy      as B
import           Data.Char                 (toLower)
import qualified Data.Text                 as T
import           Filesystem.Path.CurrentOS hiding (decode)
import           Options.Applicative
import           Prelude                   hiding (FilePath)


fileOption :: Mod OptionFields FilePath -> Parser FilePath
fileOption fields = nullOption (reader (pure . decodeString) <> fields)

data Opts = Opts
          { _epubSpec   :: FilePath
          , _epubOutput :: FilePath
          } deriving (Show)
$(makeLenses ''Opts)

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

data Epub = Epub
          { _epubTitle       :: T.Text
          , _epubAuthor      :: T.Text
          , _epubSource      :: T.Text
          , _epubDescription :: T.Text
          , _epubChapters    :: [T.Text]
          } deriving (Show, Eq)
$(makeLenses ''Epub)
$(deriveJSON defaultOptions{ fieldLabelModifier = map toLower . drop 5, constructorTagModifier = map toLower }
             ''Epub)


main :: IO ()
main = do
    o <- execParser opts'
    print o
    e <- (fmap decode . B.readFile . encodeString $ _epubSpec o) :: IO (Maybe Epub)
    print e
