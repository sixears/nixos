{-# OPTIONS_GHC -Wall #-}

{-# LANGUAGE NoImplicitPrelude    #-}
{-# LANGUAGE RankNTypes           #-}
{-# LANGUAGE ScopedTypeVariables  #-}
{-# LANGUAGE UnicodeSyntax        #-}
{-# LANGUAGE ViewPatterns         #-}

import Base1

-- fpath -------------------------------

import FPath.AbsFile           ( AbsFile, absfile )
import FPath.Error.FPathError  ( AsFPathError )
import FPath.File              ( File( FileA ) )
import FPath.Parseable         ( readM )

-- log-plus ----------------------------

import Log  ( Log )

-- logging-effect ----------------------

import Control.Monad.Log  ( LoggingT, Severity( Informational ) )

-- mockio-log --------------------------

import MockIO.Log          ( DoMock )
import MockIO.MockIOClass  ( MockIOClass )

-- mockio-plus -------------------------

import MockIO.File  ( fileFoldLinesUTF8 )

-- monadio-plus ------------------------

import MonadIO        ( say )
import MonadIO.Base   ( getArgs )
import MonadIO.FPath  ( pResolve )

-- optparse-applicative ----------------

import Options.Applicative.Builder  ( argument, metavar )
import Options.Applicative.Types    ( Parser )

-- stdmain -----------------------------

import StdMain             ( stdMain )
import StdMain.UsageError  ( UsageParseFPProcIOError )

--------------------------------------------------------------------------------

newtype Options = Options { _input_files ∷ [File] }

parseOptions ∷ Parser Options
parseOptions = Options ⊳ many (argument readM (metavar "INPUT-FILE"))

----------------------------------------

inputFiles ∷ Options → NonEmpty File
inputFiles (_input_files → []) = FileA [absfile|/dev/stdin|] :| []
inputFiles (_input_files → xs) = fromList xs

----------------------------------------

myMain ∷ ∀ ε . (HasCallStack, Printable ε, AsIOError ε, AsFPathError ε) ⇒
         DoMock → Options → LoggingT (Log MockIOClass) (ExceptT ε IO) Word8
myMain do_mock opts = do
  let files = inputFiles opts
  forM_ files $ \ fn → do
    fn' ← pResolve @AbsFile fn
    fileFoldLinesUTF8 Informational 𝕹 [] (\ _ t → say t ⪼ return [])
                      (return []) fn' do_mock
  return 0

----------------------------------------

main ∷ IO ()
main = do
  let progDesc ∷ 𝕋 = "cat files"
  getArgs ≫ stdMain progDesc parseOptions (myMain @UsageParseFPProcIOError)

-- that's all, folks! ----------------------------------------------------------
