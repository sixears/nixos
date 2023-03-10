{-# OPTIONS_GHC -Wall #-}

{-# LANGUAGE DataKinds            #-}
{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE KindSignatures       #-}
{-# LANGUAGE LambdaCase           #-}
{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE NoImplicitPrelude    #-}
{-# LANGUAGE QuasiQuotes          #-}
{-# LANGUAGE PatternSynonyms      #-}
{-# LANGUAGE RankNTypes           #-}
{-# LANGUAGE ScopedTypeVariables  #-}
{-# LANGUAGE TupleSections        #-}
{-# LANGUAGE TypeApplications     #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE UnicodeSyntax        #-}
{-# LANGUAGE ViewPatterns         #-}

import Prelude ( Integer, maxBound )

import Base1

-- base --------------------------------

import Control.Applicative  ( optional )
import Control.Concurrent   ( killThread, myThreadId )
import Data.Function        ( flip )
import Data.Int             ( Int64 )
import Data.List            ( reverse )
import Data.List.NonEmpty   ( uncons )
import Data.String          ( unlines )
import System.Environment   ( getProgName )
import System.IO            ( IOMode( ReadMode ), hPutStrLn, stderr, stdin )
import Text.Read            ( readEither )

-- filelock ----------------------------

import System.FileLock  ( SharedExclusive( Exclusive ) )

-- fpath -------------------------------

import FPath.AbsFile           ( AbsFile )
import FPath.AsFilePath        ( AsFilePath )
import FPath.File              ( File, FileAs )
import FPath.Error.FPathError  ( AsFPathError )
import FPath.Parseable         ( readM )

-- lens --------------------------------

import Control.Lens.Getter  ( view )

-- log-plus ----------------------------

import Log  ( Log, info', notice' )

-- logging-effect ----------------------

import Control.Monad.Log  ( LoggingT, MonadLog
                          , Severity( Informational, Notice ) )

-- mockio-log --------------------------

import MockIO.IOClass      ( HasIOClass )
import MockIO.Log          ( DoMock, HasDoMock )
import MockIO.MockIOClass  ( MockIOClass )

-- mockio-plus -------------------------

import MockIO.Flock                  ( flock, flockNB, unflock )
import MockIO.OpenFile               ( readFile )
import MockIO.Process                ( CmdRW( CmdW ), doProc )
import MockIO.Process.OutputDefault  ( OutputDefault( outDef ) )

-- monadio-plus ------------------------

import MonadIO.Base                  ( getArgs )
import MonadIO.Error.CreateProcError ( AsCreateProcError )
import MonadIO.Error.ProcExitError   ( AsProcExitError )
import MonadIO.Flock                 ( NamedFileLock )
import MonadIO.FPath                 ( pResolve )
import MonadIO.NamedHandle           ( pattern ??? )
import MonadIO.Process.ExitInfo      ( ExitInfo )
import MonadIO.Process.ExitStatus    ( ExitStatus( ExitVal ), exitVal )

-- optparse-applicative ----------------

import Options.Applicative.Builder  ( argument, eitherReader, help, long
                                    , metavar, option, short, strArgument )
import Options.Applicative.Types    ( Parser, ReadM )

-- optparse-plus -----------------------

import OptParsePlus  ( parseNE )

-- parsec ------------------------------

import Text.Parsec.Prim  ( parse )

-- parsec-plus -------------------------

import ParsecPlus  ( AsParseError, Parsecable( parsec, parser ), ParseError )

-- parser-plus -------------------------

import ParserPlus  ( convertReadParser, parseMillis )

-- parsers -----------------------------

import Text.Parser.Char         ( digit )
import Text.Parser.Combinators  ( eof )

-- stdmain -----------------------------

import StdMain             ( stdMain )
import StdMain.UsageError  ( AsUsageError, UsageParseFPProcIOError )

-- timers ------------------------------

import Control.Concurrent.Suspend  ( Delay, msDelay )
import Control.Concurrent.Timer    ( TimerIO, oneShotTimer, stopTimer )

--------------------------------------------------------------------------------

newtype PID = PID Word32

instance Parsecable PID where
  parser = let check_bound i = if i > maxBound @Word32
                               then ???? $ [fmt|%d too big for Word32|] i
                               else ???? $ fromIntegral i
            in PID ??? convertReadParser check_bound (some digit)

------------------------------------------------------------

data Options = Options { _queue_files ??? NonEmpty File
                       , _exe         ??? AbsFile
                       , _args        ??? [????]
                       , _timeout     ??? ???? (????,Delay)
                       }

queue_files ??? Lens' Options (NonEmpty File)
queue_files = lens _queue_files (\ o qf ??? o { _queue_files = qf })

exe ??? Lens' Options AbsFile
exe = lens _exe (\ o e ??? o { _exe = e })

args ??? Lens' Options [????]
args = lens _args (\ o as ??? o { _args = as })

timeout ??? Lens' Options (???? (????,Delay))
timeout = lens _timeout (\ o t ??? o { _timeout = t })

read_delay ??? ???? ??? ???? ???? Delay
read_delay s = case readEither @Integer s of
                 ???? e ??? ???? e
                 ???? i ??? if i > fromIntegral (maxBound @Int64)
                       then ???? $ "too big for Int64: " ??? s
                       else ???? $ msDelay (fromIntegral i)

readDelay ??? ReadM (????,Delay)
readDelay =
  eitherReader $
    \ s ??? fmap (s,) $ first show (parse (parseMillis ??? eof) s s) ??? read_delay

parseOptions ??? Parser Options
parseOptions =
  let queue_help   = help "queue against this file"
      timeout_help =
        help (unlines [ "total time limit waiting for locks, in seconds; "
                      , "takes up to 3 decimal digits, for millisecond "
                      , "precision"
                      ])
   in Options ??? parseNE (option readM (short 'q' ??? long "queue" ??? queue_help))
      ??? argument readM (metavar "EXECUTABLE")
      ??? many (strArgument (metavar "CMDARG"))
      ??? optional (option readDelay
                         (?? [ short 't', long "timeout", timeout_help ]))

data Block = Block | NoBlock
  deriving (Eq,Show)

data Locked = Locked | NotLocked
  deriving (Eq,Show)

----------------------------------------

{- | Read a file; return `????` if there is no file to read. -}

----------------------------------------

data FlockPID = Flocked NamedFileLock | NotFlocked (???? PID)

grab_lock ??? (MonadIO ??, FileAs ??, Printable ??, AsFilePath ??,
             Printable ??, AsIOError ??, AsParseError ??,
             MonadError ?? ??, MonadLog (Log ??) ??,
             Default ??, HasIOClass ??, HasDoMock ??) =>
            ?? ??? DoMock ??? ?? NamedFileLock
grab_lock fn do_mock =
  flock Notice Exclusive fn do_mock

grab_lock_nb ??? (MonadIO ??, FileAs ??, Printable ??, AsFilePath ??,
                Printable ??, AsIOError ??, AsParseError ??,
                MonadError ?? ??, MonadLog (Log ??) ??,
                Default ??, HasIOClass ??, HasDoMock ??) =>
               ?? ??? DoMock ??? ?? FlockPID
grab_lock_nb fn do_mock = do
  flockNB Notice Exclusive fn do_mock ??? \ case
    -- Be sure this is the final action; so that the fl gets returned, and thus
    -- the caller has a chance to unlock it.
    ???? fl ??? return $ Flocked fl
    ????    ??? do
      txt ??? readFile @_ @???? Informational
                     (???? $ \ f ??? [fmt|readFile: '%T'|] f) (return "") fn do_mock
      mpid ??? case parsec @PID @ParseError (toString fn) txt of
               ???? e   ??? info' (toText e) ??? return ????
               ???? pid ??? return $ ???? pid

      return $ NotFlocked mpid

----------------------------------------

{- | Work through a list of files, trying to flock each (non-blocking) in turn.
     Stop once we have a successful lock; return a list of files tried.
 -}
find_lock_nb ??? (MonadIO ??,
                Printable ??, AsIOError ??, AsParseError ??,
                MonadError ?? ??, MonadLog (Log ??) ??,
                Default ??, HasIOClass ??, HasDoMock ??) =>
               NonEmpty AbsFile ??? DoMock ??? ?? ([AbsFile], FlockPID)
find_lock_nb fns do_mock = first reverse ??? find_lock_nb_ fns [] do_mock

find_lock_nb_ ??? (MonadIO ??,
                Printable ??, AsIOError ??, AsParseError ??,
                MonadError ?? ??, MonadLog (Log ??) ??,
                Default ??, HasIOClass ??, HasDoMock ??) =>
               NonEmpty AbsFile ??? [AbsFile] ??? DoMock ??? ?? ([AbsFile], FlockPID)
find_lock_nb_ fns accum do_mock = do
  let (fn,fns') = uncons fns
  grab_lock_nb fn do_mock ??? \ case
    NotFlocked ???? ??? do
      notice' $ [fmtT|Failed to flock '%T'|] fn
      case fns' of
        ????       ??? return (fn:accum,NotFlocked ????)
        ???? fns'' ??? find_lock_nb_ fns'' (fn:accum) do_mock

    NotFlocked (???? (PID pid)) ??? do
      notice' $ [fmtT|Failed to flock '%T': pid <%d> is already queued|] fn pid
      case fns' of
        ????       ??? return (fn:accum,NotFlocked (???? (PID pid)))
        ???? fns'' ??? find_lock_nb_ fns'' (fn:accum) do_mock

    Flocked l ??? return (accum,Flocked l)

----------------------------------------

{- | Given a list of files, and an existing flock: wait on a flock of each file
     in turn; once we have gained one, release the prior lock (having removed
     our PID from the file).  Return with the final lock. -}
chase_flock ??? (MonadIO ??,
                Printable ??, AsIOError ??, AsParseError ??,
                MonadError ?? ??, MonadLog (Log ??) ??,
                Default ??, HasIOClass ??, HasDoMock ??) =>
               [AbsFile] ??? NamedFileLock ??? DoMock ??? ?? NamedFileLock
chase_flock []       l _       = return l
chase_flock (fn:fns) l do_mock = do
  l' ??? grab_lock fn do_mock
  unflock Notice l do_mock
  chase_flock fns l' do_mock

----------------------------------------

doWithLock ??? ??? ?? ?? ?? .
             (MonadIO ??,
              AsIOError ??, AsParseError ??, Printable ??, MonadError ?? ??,
              HasDoMock ??, HasIOClass ??, Default ??, MonadLog (Log ??) ??) ???
             ???? TimerIO ??? NonEmpty AbsFile ??? (NamedFileLock ??? ?? Word8) ??? DoMock
           ??? ?? Word8
doWithLock tid queue io do_mock = do
  (fns,mpid) ??? find_lock_nb queue do_mock

  case mpid of
    NotFlocked _ ??? return 3
    Flocked l ??? do
      -- chase the flock along the functions in reverse order
      l' ??? chase_flock (reverse fns) l do_mock
      -- we take care to always unflock the lock file
      case tid of
        ????   ??? return ()
        ???? t ??? liftIO $ stopTimer t
      io l'

----------------------------------------

flockProcRun ??? ??? ?? .
               (HasCallStack, Printable ??, AsUsageError ??, AsParseError ??,
                AsIOError ??, AsProcExitError ??, AsCreateProcError ??,
                AsFPathError ??) ???
               ???? TimerIO ??? DoMock ??? Options
             ??? LoggingT (Log MockIOClass) (ExceptT ?? IO) Word8
flockProcRun tid do_mock opts = do
  queue_absfiles ??? mapM (pResolve @AbsFile) (opts ??? queue_files)
  let exit_val ??? ExitInfo ??? Word8
      exit_val (view exitVal ??? ExitVal v) = v
      -- this is used to decode the return of doProc; doProc throws on
      -- signal, so we can never hit an ExitSig pattern
      exit_val _ = 255
      io ??? NamedFileLock ??? LoggingT (Log MockIOClass) (ExceptT ?? IO) Word8
      io l = do
        (x,()) ??? doProc Notice CmdW (unflock Notice l do_mock)
                        outDef (??? stdin "stdin" ReadMode)
                        (opts ??? exe,opts ??? args) do_mock
        return $ exit_val x
  doWithLock tid queue_absfiles io do_mock

--------------------

{- | Start a kill timer (if indicated by opts); this will kill the main thread
     after some time.  Call `flockProcRun`, which should stop the timer if it
     gains all the locks (before the timer expires.

     We take care to run the remote executable from the main thread: when I
     tried running the executable from a subsidiary thread, I needed to hit
     'return' in ghci to make stuff happen.
-}
myMain ??? ??? ?? .
         (HasCallStack, Printable ??, AsUsageError ??, AsParseError ??,
          AsIOError ??, AsProcExitError ??, AsCreateProcError ??, AsFPathError ??) ???
         DoMock ??? Options ??? LoggingT (Log MockIOClass) (ExceptT ?? IO) Word8
myMain do_mock opts = do
  mainTID ??? liftIO myThreadId
  killTID ??? ???? TimerIO ??? liftIO $ case opts ??? timeout of
              ????       ??? return ????
              ???? (s,t) ??? fmap ???? $ flip oneShotTimer t $ do
                progn ??? getProgName
                hPutStrLn stderr $ [fmt|%s: timed out after %ss|] progn s
                killThread mainTID
  flockProcRun killTID do_mock opts

----------------------------------------

main ??? IO ()
main = do
  let progDesc = "queue executions"
  getArgs ??? stdMain progDesc parseOptions (myMain @UsageParseFPProcIOError)

-- that's all, folks! ----------------------------------------------------------
