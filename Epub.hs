{-# LANGUAGE OverloadedStrings #-}


module Main where


import           Control.Applicative
import           Control.Error
import           Control.Lens              hiding (element, (<.>))
import           Control.Monad
import           Data.Aeson
import           Data.Aeson.TH
import qualified Data.ByteString.Lazy      as B
import           Data.Char                 (toLower)
import qualified Data.List                 as L
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

    let chapters   = zip ([1..] :: [Int]) $ _epubChapters spec
        working    = fromMaybe "output" $ _epubWorking o
        titleBlock = "---\ntitle: " <> _epubTitle spec
                   <> "\nauthor: " <> _epubAuthor spec
                   <> "\n---\n\n"
    scriptIO $
        (`unless` FS.createTree working) =<< FS.isDirectory working

    markdowns <- fmap (mappend titleBlock . T.intercalate "\n")
              .  forM chapters $ \(i, url) -> do
        let url'   = T.unpack url
            base   = Path.decode . TL.toStrict . format "{}" . Only
                   $ F.left 2 '0' i
            output = working </> base <.> "md"
        md <-  toText
           .   toMD
           .   renderLBS def
           .   articles
           .   parseResp
           <$> scriptIO (get url')
        writeMD output md
        return md

    scriptIO . FS.writeTextFile (working </> "00.md") $ markdowns
    scriptIO . FS.writeFile (_epubOutput o) . B.toStrict
             =<< scriptIO (writeEPUB epubOpts . readHtml readerOpts $ T.unpack markdowns)

    where readerOpts = def { readerExtensions = pandocExtensions }
          writerOpts = def
          epubOpts   = def { writerTableOfContents = True
                           , writerUserDataDir = Just "/usr/local/Cellar/cabal-pandoc/1.13.1/share/x86_64-osx-ghc-7.8.2/pandoc-1.13.1/data/"
                           , writerEpubVersion = Just EPUB3
                           , writerEpubChapterLevel = 1
                           }
          doc el     = Document (Prologue [] Nothing []) el []
          writeMD o  = scriptIO . FS.writeTextFile o
          toMD       = readHtml readerOpts . UTF8.toStringLazy
          toText     = T.pack . writeMarkdown writerOpts
          articles   = doc
                     . Element "div" mempty
                     . map node
                     . ($.// element "article")
                     . fromDocument
          parseResp  = HTML.parseLBS . (^. responseBody)
