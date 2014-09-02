{-# LANGUAGE OverloadedStrings #-}


module Main where


import           Control.Error
import           Control.Lens              hiding (element, (<.>))
import           Control.Monad
import           Data.Aeson
import           Data.Aeson.TH
import qualified Data.ByteString.Lazy      as B
import           Data.Char                 (toLower)
import           Data.Monoid
import qualified Data.Text                 as T
import           Data.Text.Format
import qualified Data.Text.Format          as F
import qualified Data.Text.Lazy            as TL
import qualified Data.Text.Lazy.Encoding   as E
import qualified Filesystem                as FS
import           Filesystem.Path.CurrentOS hiding (decode)
import qualified Filesystem.Path.CurrentOS as Path
import           Network.Wreq
import           Prelude                   hiding (FilePath)
import qualified Text.HTML.DOM             as HTML
import           Text.Pandoc
import qualified Text.Pandoc.UTF8          as UTF8
import           Text.XML
import           Text.XML.Cursor

import           Epub.Options
import           Epub.Types


main :: IO ()
main = runScript $ do
    o    <-  scriptIO $ execParser opts'
    spec <-  hoistEither . eitherDecode . B.fromStrict
         =<< scriptIO (FS.readFile $ _epubSpec o)

    let chapters = zip ([1..] :: [Int]) $ _epubChapters spec
        working  = fromMaybe "output" $ _epubWorking o
    scriptIO $
        (`unless` FS.createTree working) =<< FS.isDirectory working

    forM_ chapters $ \(i, url) -> do
        let url'   = T.unpack url
            base   = Path.decode . TL.toStrict . format "{}" . Only
                   $ F.left 2 '0' i
            output = working </> base <.> "md"
        scriptIO $ putStrLn url'

        scriptIO $   writeMD output
                 .   toMD
                 .   renderLBS def
                 .   articles
                 .   parseResp
                 =<< get url'

        scriptIO $ putStrLn ""

    where readerOpts = def { readerExtensions = pandocExtensions }
          writerOpts = def
          doc el     = Document (Prologue [] Nothing []) el []
          writeMD o  = FS.writeTextFile o . T.pack . writeMarkdown writerOpts
          toMD       = readHtml readerOpts . UTF8.toStringLazy
          articles   = doc
                     . Element "div" mempty
                     . map node
                     . ($.// element "article")
                     . fromDocument
          parseResp  = HTML.parseLBS . (^. responseBody)
