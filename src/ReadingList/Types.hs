module ReadingList.Types
    ( ReadingList(..)
    ) where


import qualified Filesystem.Path.CurrentOS as FS


data ReadingList
        = RL
        { rlInputFile :: FS.FilePath
        , rlHtmlDir   :: FS.FilePath
        } deriving (Show)

