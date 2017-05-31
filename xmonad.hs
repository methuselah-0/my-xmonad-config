import XMonad
import XMonad.Config
--import XMonad.Actions.Volume 
--for the union function 
import qualified Data.Map as M 
import Data.Map    (fromList)
import Data.Monoid (mappend)
--keys
import XMonad.Util.EZConfig
import Graphics.X11.ExtraTypes.XF86
--layouts
import XMonad.Layout 
import XMonad.Layout.Spacing 
import XMonad.Layout.NoBorders -- (smartBorders) if using pidginlayout
import XMonad.Layout.PerWorkspace  
import XMonad.Layout.SimplestFloat
import XMonad.Layout.IM  
import XMonad.Layout.Grid  --for chat-windows layout
--
import qualified XMonad.StackSet as W -- for functions to switch panes
import XMonad.Actions.CycleWS
import XMonad.Hooks.DynamicLog  
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run
import XMonad.Util.SpawnOnce
import XMonad.Util.Dmenu
import System.IO
import System.Posix.Process

main = do  
  topBar <- spawnPipe "xmobar ~/.xmonad/xmobarrc" --spawnPipe needs XMonad.Util.Run --enable together with logHook below for stdInReader in xmobar.

-- if you want bottom bar uncomment loghook section below as well.
-- spawnPipe needs XMonad.Util.Run --enable together with logHook below for stdInReader in xmobar.    
  bottomBar <- spawnPipe "xmobar ~/.xmonad/xmobar2rc" 
  xmonad $ defaultConfig  
    { modMask = mod4Mask
    , terminal = "urxvt"
    
    -- avoidStruts $ in front of myLayout is needed to make xmobar visible over other windows.    
    , layoutHook = avoidStruts $ myLayout 
    , handleEventHook = mconcat
                       [ docksEventHook
                       , handleEventHook defaultConfig
		       ]
    , logHook =  dynamicLogWithPP xmobarPP
          { ppOutput = hPutStrLn bottomBar
	  , ppCurrent = xmobarColor "#00ff00" "" . wrap "<" ">" -- for green you can use "#429942" "" and for additional indication of active work space you can append . wrap "<" ">"
	  , ppTitle = xmobarColor "green" "" -- if you don't want all stdin text add ". shorten 40" without quotes.
	  , ppLayout = const "" -- to disable the layout info on xmobar
	  }
    , workspaces = myWorkspaces                    
    , manageHook = manageDocks
               <+> myManageHook
	       <+> manageHook defaultConfig     
    , keys = myKeys
    , normalBorderColor = "#000000" -- "#60A1AD"=blue-greyish. These are HEX values coding for RGB or 256 colors.
    , focusedBorderColor = "#68e862" -- "#7df9ff" is cyan. 3 pairs of hexadecimal values each hex-pair=8bits=256 combinations/colors.
    , borderWidth = 1
    -- autostart starts trayer for the xmobars.
    , startupHook = spawn "/home/user1/.xmonad/autostart" -- <+> spawn "(command and arguments here)" 
    }
  
--the default format using the XMonad.Util.EZConfig module to define a
--key combination is myKey x = [((modkey, key), action)]. 
--For multiple modkeys, say 2: ((modkey 1 .|. modkey 2, key), action). 
--By typing the following command:
--xev | grep -A2 --line-buffered '^KeyRelease' | sed -n '/keycode /s/^.*keycode \([0-9]*\).* (.*, \(.*\)).*$/\1 \2/p'
--and then moving the cursor to the white window and hitting the key will send the names of the keys
--just hit to std.out, i.e. printed in a terminal. Default keybindings defined in /usr/share/xmonad/man/xmonad.hs. 
--Special laptop keys might need the Graphics.X11.ExtraTypes.XF86 module.

myKeys x = M.union (keys defaultConfig x) (M.fromList (keysToAdd x))
  where
    keysToAdd x =
      [ -- toggle all bars
      ((mod4Mask, xK_b), sendMessage ToggleStruts) --modmask x for taking arguments.

      -- show upper bar , hide lower
      , ((mod4Mask .|. controlMask, xK_b), sendMessage $ SetStruts [U] [D])
      -- show only lower bar
      , ((mod4Mask .|. shiftMask, xK_b), sendMessage $ SetStruts [D] [minBound .. maxBound])
      -- hide all bars (no toggle)
      , ((mod4Mask .|. mod1Mask, xK_b), sendMessage $ SetStruts [] [minBound .. maxBound])

      , ((mod4Mask, xK_d), spawn "dmenu_run -i -nb black -nf green -sf orange -sb darkgreen -fn \"xft:terminus:pixelsize=12\"")
      , ((mod4Mask, xK_F1), kill)
      , ((0, xF86XK_Sleep), spawn "systemctl hibernate")
      , ((0, xF86XK_ScreenSaver), spawn "alock -b none -c none -i blank")
      , ((0, xF86XK_MonBrightnessUp), spawn "xbacklight +20") 
      , ((0, xF86XK_MonBrightnessDown), spawn "xbacklight -20")
      -- volume control alsa
      , ((0, xF86XK_AudioMute), spawn "amixer set Master toggle") -- mute volume    
      , ((0, xF86XK_AudioLowerVolume), spawn "amixer set Master 3%- unmute") -- decrease volume  
      , ((0, xF86XK_AudioRaiseVolume), spawn "amixer set Master 3%+ unmute") -- increase volume
      -- volume control pulseaudio for alternative sound source.
      , ((mod4Mask, xF86XK_AudioMute), spawn "./scripts/pamixer2.sh -t") -- mute volume    
      , ((mod4Mask, xF86XK_AudioLowerVolume), spawn "~/./.xmonad/scripts/pamixer2.sh -d 3") -- decrease volume  
      , ((mod4Mask, xF86XK_AudioRaiseVolume), spawn "~/./.xmonad/scripts/pamixer2.sh -i 3") -- increase volume            
--      , ((0, xK_F6), return ()) --returns mean do nothing. Can be used to undo defult llbindings.
-- use the three below if the three above don't work.
--      , ((mod4Mask, xK_F7), setVolume 0 >> return())
--      , ((mod4Mask, xK_F8), lowerVolume 4 >> return()) --if muted, (doesn't work) substitute lowerVolume 4 for setMute False >> lowerVolume 4
--      , ((mod4Mask, xK_F9), raiseVolume 4 >> return()) 
      , ((0, xF86XK_AudioPrev), spawn "mpc prev") -- play previous song in mpd
      , ((0, xF86XK_AudioPlay), spawn "mpc toggle") -- play/pause mpd  
      , ((0, xF86XK_AudioNext), spawn "mpc next") -- play next song in mpd
      , ((mod4Mask, xK_m), spawn "mpc play") -- play present or first song in mpd playlist    
      , ((0, xK_Print), spawn "scrot") -- capture screenshot of full desktop.        
      , ((mod4Mask, xK_Print), spawn "scrot -s") -- capture screenshot of focused window.
--  , ((mod4Mask .|. shiftMask, xK_l), spawn "slimlock") -- slimlock to be installed
      , ((mod4Mask, xK_Up), windows W.swapUp)  
      , ((mod4Mask, xK_Down), windows W.swapDown)
      , ((mod4Mask, xK_Right), sendMessage Expand)  --expands the master pane 
      , ((mod4Mask, xK_Left), sendMessage Shrink)  --expands the master pane     
      , ((mod4Mask, xK_KP_Add), sendMessage (IncMasterN 1)) -- increase the number of window on master pane  
      , ((mod4Mask, xK_KP_Subtract ), sendMessage (IncMasterN (-1))) -- decrease the number of window
      ]

-- see https://hackage.haskell.org/package/xmonad-contrib-0.11.1/docs/XMonad-Hooks-FadeInactive.html for nice stuff.
-- Option is to prefix defaultLayout with: onWorkspace "2:pidgin" pidginLayout $ onWorkspaces ["4:Graphics", "6:float"] simplestFloat $ 
myLayout = defaultLayout
  where
  
    -- Personal settings for the default layouts "tiled", "Mirror tiled" and "Full".
    -- Defaults to leftmost tile option. 
    defaultLayout = tiled1 ||| Mirror tiled1 ||| Full 

    -- spacing needs the module XMonad.Layout.Spacing
    -- spacing x sets the number of pixels for space between tiled windows.
    tiled1 = spacing 3 $ Tall nmaster delta ratio
    
    -- The default number of windows in the master pane  
    nmaster = 1 

    -- Default proportion of screen occupied by master pane  
    ratio = 2/3

    -- Percent of screen to increment by when resizing panes  
    delta = 3/100  

    -- Custom layouts which can be used for specific workspaces. Dep.: XMonad.Layout.NoBorders
    nobordersLayout = noBorders $ Full
    gridLayout = Grid
    pidginLayout = withIM (0/100) (Role "buddy_list") gridLayout

    -- gimpLayout = withIM (0.20) (Role "gimp-toolbox") $ reflectHoriz $ withIM (0.20) (Role "gimp-dock") Full 
    
-- All layouts together.
-- Function onWorkspace and onWorkspaces needs XMonad.Layout.PerWorkspace.
-- Function simplestFloat needs XMonad.Layout.SimplestFloat

-- needs XMonad.Layout.noBorders (smartBorders)
nobordersLayout = smartBorders $ Full  

-- Amount and names of workspaces  
myWorkspaces = ["1:Main","2:Text","3:Web","4:XMPP","5:Tox","6:IRC","7:Mail","8:Mpd","9:Torrent"] 

-- Default screens for some applications.
-- Use xprop command or bottom xmobar to get title or class names.
-- (?: Set client titles with environment variables through getEnvironment.)
myManageHook = composeAll . concat $
  [[ title =? "emacs" --> doShift "2:Text"
  , className =? "Iceweasel" --> doShift "3:Web"  
  , title =? "Gajim" --> doShift "4:XMPP"
  , title =? "toxic" --> doShift "5:Tox"
  , title =? "weechat" --> doShift  "6:IRC"
  , className =? "Icedove" --> doShift "7:Mail"
  , title =? "alpine" --> doShift "7:Mail"
  , title =? "ncmpcpp" --> doShift "8:Mpd"
  , className =? "Transmission-gtk" --> doShift "9:Torrent"
-- className =? "Pavucontrol" --> doFloat  
  ]  
  ,[ className =? someProgram --> doFloat | someProgram <- float_classes ]
  ,[ title =? pop_up --> doFloat | pop_up <- float_titles ]
  ]
    where 
      float_classes = ["Gimp"]
      float_titles = ["Firefox Preferences", "Downloads", "Add-ons", "Rename", "Create" ]
--      browser = case (a, b) -- look at getEnvironment in System.Environment 