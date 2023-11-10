{-# OPTIONS_GHC -Wall #-}

{-# LANGUAGE NoImplicitPrelude    #-}
{-# LANGUAGE RankNTypes           #-}
{-# LANGUAGE ScopedTypeVariables  #-}
{-# LANGUAGE TypeApplications     #-}
{-# LANGUAGE UnicodeSyntax        #-}
{-# LANGUAGE ViewPatterns         #-}

import Base1

-- base --------------------------------

import Control.Applicative  ( optional )
import Data.List            ( repeat, reverse, zip )
import Data.Maybe           ( fromMaybe )

-- fpath -------------------------------

import FPath.AbsFile           ( absfile )
import FPath.Error.FPathError  ( AsFPathError )
import FPath.File              ( File( FileA ) )
import FPath.Parseable         ( readM )

-- log-plus ----------------------------

import Log  ( Log )

-- logging-effect ----------------------

import Control.Monad.Log  ( LoggingT )

-- mockio-log --------------------------

import MockIO.MockIOClass  ( MockIOClass )

-- monadio-plus ------------------------

import MonadIO        ( say )
import MonadIO.Base   ( getArgs )
import MonadIO.File   ( fileFoldLinesUTF8 )

-- natural -----------------------------

import Natural  ( length )

-- optparse-applicative ----------------

import Options.Applicative.Builder  ( argument, help, long, metavar, short
                                    , showDefault, strOption, value )
import Options.Applicative.Types    ( Parser )

-- stdmain -----------------------------

import StdMain             ( stdMainNoDR )
import StdMain.UsageError  ( UsageParseFPProcIOError )

-- text --------------------------------

import Data.Text  ( intercalate, replicate, splitOn )

--------------------------------------------------------------------------------

data Options = Options { _input_files        ∷ [File]
                       , _delimiter          ∷ 𝕋
                       , _output_delimiter   ∷ 𝕄 𝕋
                       }

parseOptions ∷ Parser Options
parseOptions =
  let output_help = "output field delimiter (default: input delimiter"
  in  Options ⊳ many (argument readM (metavar "INPUT-FILE"))
              ⊵ strOption (ю [ short 'd', long "delimiter", value "\t"
                             , showDefault
                             , help "split on this string" ])
              ⊵ optional (strOption (ю [ short 't', long "output-delimiter"
                                       , showDefault
                                       , help output_help ]))

----------------------------------------

inputFiles ∷ Options → NonEmpty File
inputFiles (_input_files → []) = FileA [absfile|/dev/stdin|] :| []
inputFiles (_input_files → xs) = fromList xs

----------------------------------------

data E3 α β = L α | R β | B α β

{-| Like `zip`, but extends the shorter list to match -}
zip' ∷ [α] → [β] → [E3 α β]
zip' xs ys =
  let extend ∷ [α] → [𝕄 α]
      extend as = (𝕵 ⊳ as) ⊕ repeat 𝕹
      to3 ∷ [(𝕄 α, 𝕄 β)] → [E3 α β]
      to3 []                = []
      to3 ((𝕵 a, 𝕹)   : cs) = L a : to3 cs
      to3 ((𝕹 , 𝕵 b)  : cs) = R b : to3 cs
      to3 ((𝕵 a, 𝕵 b) : cs) = B a b : to3 cs
      to3 ((𝕹  , 𝕹)   : _) = []
  in  to3 $ zip (extend xs) (extend ys)

----------------------------------------

foldLine ∷ MonadIO η ⇒ 𝕋 → ([ℕ],[[𝕋]]) → 𝕋 → η ([ℕ],[[𝕋]])
foldLine delimiter (acc,lines) t = do
  let fields = splitOn delimiter t
  let update (B f i) = let l = length f in if l > i then l else i
      update (R i)   = i
      update (L f)   = length f
  return ([ update x | x ← zip' fields acc ], fields : lines)

----------------------------------------

myMain ∷ ∀ ε . (HasCallStack, Printable ε, AsIOError ε, AsFPathError ε) ⇒
         Options → LoggingT (Log MockIOClass) (ExceptT ε IO) Word8
myMain opts = do
  let files            = inputFiles opts
      delimiter        =  _delimiter opts
      output_delimiter = fromMaybe delimiter $ _output_delimiter opts
      foldL acc = fileFoldLinesUTF8 acc (foldLine delimiter)
  (ns,lines) ← foldM foldL ([],[]) files
  let pad (n,t) = t ⊕ replicate (fromIntegral $ n - length t) " "
  forM_ (reverse lines) $ \ fields → do
    say $ intercalate output_delimiter $ pad ⊳ (zip ns fields)
  return 0

----------------------------------------

main ∷ IO ()
main = do
  let progDesc ∷ 𝕋 = "cat files"
  getArgs ≫ stdMainNoDR progDesc parseOptions (myMain @UsageParseFPProcIOError)

-- that's all, folks! ----------------------------------------------------------
