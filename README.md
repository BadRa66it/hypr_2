<div align="center">
    <h1>ICE</h1>
</div>

# Gallery
![](./ScreenShots/HyprLand/Rice.png)

# Installations

> Just [R.T.F.M](https://en.wikipedia.org/wiki/RTFM)

- First of all, Install the newest [Hyprland](https://hyprland.org/) using this [guide](https://wiki.hyprland.org/Getting-Started/Installation/) depend on your Distro:

  ```zsh
  yay -S hyprland-git
  ```

### Base setups:

- Install waybar, Rofi, Dunst, kitty terminal, swaybg, swaylock-effects, swayidle, pamixer, light, Brillo, Canva:

```
yay -S waybar-hyprland rofi dunst kitty swaybg swaylock-effects-git swayidle pamixer light brillo canva
```

### Necessary Font:

- [JetBrains Mono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/JetBrainsMono.zip)

- [Iosevka Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Iosevka.zip)

- [Font Awesome](https://archlinux.org/packages/community/any/ttf-font-awesome/)
  ```
  yay -S ttf-font-awesome
  ```

Once you download them and unpack them, place them into `~/.fonts` or `~/.local/share/fonts.`

Then run this command for your system to detect the newly installed fonts.

```
fc-cache -fv
```

## Copy Files

```
git clone https://github.com/BadRa66it/hypr_2.git
cd hypr_2
cp -r ./configs/* ~/.config/
```

> Finally, now you can login with Late Night Hyprland Rice

Congratulations, at this point you successfully have installed Hyprland Balcony Rice
