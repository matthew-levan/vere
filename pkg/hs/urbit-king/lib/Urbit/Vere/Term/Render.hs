{-|
    Terminal Driver
-}
module Urbit.Vere.Term.Render
    ( clearScreen
    , clearLine
    , soundBell
    , cursorMove
    , cursorSave
    , cursorRestore
    , putCSI
    , hijack
    , lojack
    ) where

import ClassyPrelude

import qualified System.Console.ANSI as ANSI


-- Types -----------------------------------------------------------------------

clearScreen :: MonadIO m => m ()
clearScreen = liftIO $ ANSI.clearScreen

clearLine :: MonadIO m => m ()
clearLine = liftIO $ ANSI.clearLine

soundBell :: MonadIO m => m ()
soundBell = liftIO $ putStr "\a"

--NOTE  top-left-0-based coordinates
cursorMove :: MonadIO m => Int -> Int -> m ()
cursorMove r c = liftIO $ ANSI.setCursorPosition r c

cursorSave :: MonadIO m => m ()
cursorSave = liftIO ANSI.saveCursor

cursorRestore :: MonadIO m => m ()
cursorRestore = liftIO ANSI.restoreCursor

putCSI :: MonadIO m => Char -> [Int] -> m ()
putCSI c a = liftIO do
    putStr "\x1b["
    putStr $ pack $ mconcat $ intersperse ";" (fmap show a)
    putStr $ pack [c]

hijack :: MonadIO m => Int -> m ()
hijack h = liftIO do
    putCSI 'r' [1, h-1]  --  set scroll region to exclude bottom line
    putCSI 'S' [1]       --  scroll up one line
    cursorMove (h-2) 0   --  move cursor to empty space --TODO  off-by-one?

lojack :: MonadIO m => m ()
lojack = liftIO do
    putCSI 'r' []  --  reset scroll region
    cursorRestore  --  restory cursor position

--TODO  consider ANSI.setSGR
