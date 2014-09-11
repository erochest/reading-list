{-# LANGUAGE TemplateHaskell #-}


module ReadingList.Types where


import           Control.Lens
import           Data.Aeson.TH
import           Data.Char                 (toLower)
import qualified Data.Text                 as T
import           Filesystem.Path.CurrentOS hiding (decode)
import           Prelude                   hiding (FilePath)


data Opts = Opts
          { _epubSpec    :: FilePath
          , _epubWorking :: Maybe FilePath
          , _epubOutput  :: FilePath
          } deriving (Show)
$(makeLenses ''Opts)

data Epub = Epub
          { _epubTitle       :: T.Text
          , _epubAuthor      :: T.Text
          , _epubSource      :: T.Text
          , _epubDescription :: T.Text
          , _epubChapters    :: [T.Text]
          } deriving (Show, Eq)
$(makeLenses ''Epub)
$(deriveJSON defaultOptions{ fieldLabelModifier = map toLower . drop 5
                           , constructorTagModifier = map toLower }
             ''Epub)
