{ pkgs, touchpad }: pkgs.writeText "xmonad.hs" ''
{-# OPTIONS_GHC -Wno-deprecations #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE UnicodeSyntax     #-}

-- -Wno-deprecations : we need to replace docksEventHook with docks

import Prelude ()

import Debug.Trace  ( trace, traceShow )

-- base --------------------------------

import Control.Monad  ( (>>=), (>>), return, unless )
import Data.Function  ( (.), ($), flip )
import Data.Monoid    ( (<>) )
import Data.String    ( String, unwords )
import GHC.Num        ( (+) )
import GHC.Real       ( (/) )
import System.IO      ( FilePath, Handle, IO )

-- data-default ------------------------

import Data.Default  ( def )

-- directory ---------------------------

import System.Directory  ( getHomeDirectory )

-- unix --------------------------------

import System.Posix.Directory  ( createDirectory )
import System.Posix.Files      ( createNamedPipe, fileExist, ownerExecuteMode
                               , ownerReadMode, ownerWriteMode )
import System.Posix.User       ( getEffectiveUserName )

-- xmonad ------------------------------

import XMonad  ( Choose, Full( Full ), Mirror( Mirror ), Tall( Tall ), X
               , (<+>), (|||)
               , handleEventHook, layoutHook, logHook, manageHook
               , modMask, mod4Mask, startupHook, spawn, terminal, windows
               , workspaces, xmonad
               )

import XMonad.Operations  ( screenWorkspace )
import XMonad.StackSet  ( greedyView, shift, swapMaster, view )

-- xmonad-contrib ----------------------

import XMonad.Layout.NoBorders    ( smartBorders )
import XMonad.Layout.ThreeColumns ( ThreeCol( ThreeCol ) )
import XMonad.Hooks.ManageDocks   ( avoidStruts, docksEventHook, manageDocks )
import XMonad.Hooks.DynamicLog    ( dynamicLogWithPP, ppOutput, ppTitle, shorten
                                  , xmobarColor, xmobarPP )
import XMonad.Util.EZConfig       ( additionalKeysP )
import XMonad.Util.Run            ( hPutStrLn, spawnPipe, safeSpawn, unsafeSpawn )

--------------------------------------------------------------------------------

----------------------------------------------------------------------
--                        to test this, run                         --
-- /nix/store/q*-ghc-*-packages/bin/ghci -Wall ~/.xmonad/xmonad.hs  --
----------------------------------------------------------------------

defaultLayout :: Choose Tall (Choose (Mirror Tall) Full) a

defaultLayout = tiled ||| Mirror tiled ||| Full
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

--------------------

--   The first argument specifies how many windows initially appear in the main
-- window.
--   The second argument argument specifies the amount to resize while resizing
-- and the third argument specifies the initial size of the columns.
--   A positive size designates the fraction of the screen that the main window
-- should occupy, but if the size is negative the absolute value designates the
-- fraction a slave column should occupy. If both slave columns are visible,
-- they always occupy the same amount of space.

threeColLayout :: ThreeCol a
threeColLayout = ThreeCol 1 (3/100) (3/7)

--------------------

myLayout :: Choose (Choose Tall (Choose (Mirror Tall) Full)) ThreeCol a
myLayout = defaultLayout ||| threeColLayout

----------------------------------------

-- whenJust :: Applicative m => Maybe a -> (a -> m ()) -> m ()
-- whenJust mg f = maybe (pure ()) f mg

----------------------------------------

tmpdir :: FilePath -> FilePath
tmpdir name = "/tmp" </> name

i3pipe :: FilePath -> FilePath
i3pipe name = tmpdir name </> "i3status"

-- | create the given fifo (perms 0600) if the file doesn't already exist
ensureFifo :: FilePath -> IO ()
ensureFifo fn = fileExist fn >>= flip unless mkFifo
  where mkFifo = createNamedPipe fn (ownerReadMode + ownerWriteMode)

----------------------------------------

(</>) :: FilePath -> FilePath -> FilePath
pfx </> sfx = pfx <> "/" <> sfx

myBin ∷ FilePath → FilePath
myBin home = home </> "bin"

swBin ∷ FilePath
swBin = "/run/current-system/sw/bin"

nixXBin :: FilePath -> FilePath
nixXBin home = home </> ".nix-profiles/dev-x/bin"

rcDir :: FilePath -> FilePath
rcDir home = home </> "rc"

urxvt :: FilePath -> FilePath
urxvt home = swBin </> "urxvt"

xmobarrc :: FilePath
xmobarrc = "/etc/xmobarrc"

i3status :: FilePath
i3status = swBin </> "i3status"

i3statusrc :: FilePath
i3statusrc = "/etc/i3status"

----------------------------------------

myLogHook :: Handle -> X ()
myLogHook process =
  dynamicLogWithPP xmobarPP
                   { ppOutput = hPutStrLn process
                   , ppTitle  = xmobarColor "green" "" . shorten 50
                   }

----------------------------------------

spawnOn ∷ String → FilePath → [String] → X ()
spawnOn ws prog args = safeSpawn prog args >> (windows $ greedyView ws)

----------------------------------------

{- Keys:
            Yoga260
   Mute                (F1)
   Vol-                (F2)
   Vol+                (F3)
   Bright-             (F5)
   Bright+             (F6)
   TouchPad Toggle     (F7)
   WIFI                (F8) # Hardware
   Screen Normal       (F9)
   Screen Bottom Right (F10)
   Screen Bottom Left  (F11)
   Screen Invert       (F12)
 -}

keys ∷ [(String, X ())]
keys = [ ("M-0", windows $ greedyView "0")
       , ("M-S-0", windows $ shift "0")

       , ("<XF86AudioMute>",
          spawn "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle")
--       , ("M-<F3>" ,
       , ("<XF86AudioRaiseVolume>",
          spawn "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +1.5%")
       , ("<XF86AudioLowerVolume>",
          spawn "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -1.5%")
       , ("<XF86MonBrightnessUp>",
          spawn "${pkgs.acpilight}/bin/xbacklight -inc 5")
       , ("<XF86MonBrightnessDown>",
          spawn "${pkgs.acpilight}/bin/xbacklight -dec 5")
       , ("<XF86Tools>"            , spawn "${pkgs.xorg.xrandr}/bin/xrandr -o normal")
       , ("<XF86Search>"           , spawn "${pkgs.xorg.xrandr}/bin/xrandr -o right")
       , ("<XF86LaunchA>"          , spawn "${pkgs.xorg.xrandr}/bin/xrandr -o left")
       , ("<XF86Explorer>"         , spawn "${pkgs.xorg.xrandr}/bin/xrandr -o inverted")
       -- (F7)/Projector on Lenovo Yoga 260
       , ("<XF86Display>"          , spawn "${touchpad}/bin/touchpad toggle")
       , ("<XF86TouchpadToggle>"   , spawn "${touchpad}/bin/touchpad toggle")
       -- (F4)/Mic on Lenovo Yoga 260; toggle TrackPointer (nipple)
       , ("<XF86AudioMicMute>"     , spawn "${touchpad}/bin/touchpad -t toggle")
       -- (F5)/Play on Dell XPS 9315;  toggle TrackPad
       , ("<XF86AudioPlay>"        , spawn "${touchpad}/bin/touchpad toggle")
       ]

main :: IO ()
main = do
  name <- getEffectiveUserName
  home <- getHomeDirectory

  let rwx = ownerReadMode + ownerWriteMode + ownerExecuteMode
      tmp = tmpdir name
  fileExist (tmp) >>= \ e -> unless e $ createDirectory (tmpdir name) rwx

  let i3p = i3pipe name
  -- initialize i3status
  ensureFifo i3p
  unsafeSpawn $ unwords [ i3status, "-c", i3statusrc, ">", i3p ]
  xmobarArgs <- let rc = xmobarrc
                 in fileExist rc >>= \e -> if e then return [rc] else return []
  xmproc <- spawnPipe $ unwords ("${pkgs.haskellPackages.xmobar}/bin/xmobar" : xmobarArgs)
  xmonad $ additionalKeysP (def { modMask = mod4Mask
                                , manageHook = manageDocks <+> manageHook def
                                , layoutHook = avoidStruts $ smartBorders myLayout
                                  -- this is essential, and docksEventHook must be
                                  -- last, for the xmobar to position correctly wrt
                                  -- other windows
                                , handleEventHook =
                                    handleEventHook def <+> docksEventHook
                                , logHook    = myLogHook xmproc
                                , terminal   = urxvt home
                                , workspaces = [ "1", "2", "3", "4", "5"
                                               , "6", "7", "8", "9", "0" ]
                                })
                           keys

-- that's all, folks! ----------------------------------------------------------
''

# Local Variables:
# mode: haskell
# End:
