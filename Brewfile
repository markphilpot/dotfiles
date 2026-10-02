# Loads brew/core.rb plus the profiles enabled on this machine.
#
# List this machine's extra profiles, separated by spaces or newlines, in
# ~/.config/dotfiles/profiles (not tracked). Each name maps to brew/<name>.rb.
# Add profiles for a single run with HOMEBREW_DOTFILES_PROFILES="dev audio"
# (brew only passes through environment variables that start with HOMEBREW_).

cask_args appdir: "/Applications"

brew_dir = File.join(File.dirname(File.realpath(__FILE__)), "brew")
profiles_file = File.expand_path(ENV.fetch("HOMEBREW_DOTFILES_PROFILES_FILE", "~/.config/dotfiles/profiles"))

profiles = ["core"]
profiles += File.read(profiles_file).gsub(/#.*$/, "").split if File.exist?(profiles_file)
profiles += ENV.fetch("HOMEBREW_DOTFILES_PROFILES", "").split

profiles.uniq.each do |profile|
  path = File.join(brew_dir, "#{profile}.rb")
  abort "Unknown Brewfile profile: #{profile} (expected #{path})" unless File.exist?(path)
  instance_eval(File.read(path), path)
end
