local wezterm = require 'wezterm'

return {
  color_scheme = 'tokyonight',
  default_prog = { 'fish' },
  enable_tab_bar = false,
  font = wezterm.font 'Fira Code',
  harfbuzz_features = {
    'cv01', -- 'a'
    'cv02', -- 'g'
    'cv06', -- 'i'
    'cv14', -- '3'
    'cv16', -- '*'
    'cv18', -- '%'
    'cv24', -- '/='
    'cv25', -- '.-'
    'cv26', -- ':-'
    'cv27', -- '[]'
    'cv28', -- '{. .}'
    'cv29', -- '{}'
    'cv30', -- '|'
    'cv31', -- '()'
    'cv32', -- '.='
    'onum', -- 1234567890
    'ss01', -- 'r'
    'ss02', -- '<= >='
    'ss04', -- '$'
    'ss05', -- '@'
    'ss06', -- '\\'
    'ss07', -- '=~ !~'
    'ss09', -- '>>= <<= ||= |='
    'zero', -- '0'
  },
  hide_mouse_cursor_when_typing = false,
  window_background_opacity = 0.95,
}
