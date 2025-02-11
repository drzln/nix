local M = {
  font = wezterm.font("FiraCode Nerd Font"),
  font_size = 12.0,
  color_scheme = "tokyo-city-terminal-dark",
  hide_tab_bar_if_only_one_tab = true,
  window_close_confirmation = "NeverPrompt",
  set_environment_variables = {
    TERM = 'wezterm',
  },
};

return M;
