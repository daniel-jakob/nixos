{ lib, config, pkgs, stylix, ... }:

{
  home.file.".config/rofi/themes/fancy.rasi".text = /*rasi*/''
    /**
     *
     * Author : Aditya Shakya (adi1090x)
     * Github : @adi1090x
     * 
     * Rofi Theme File
     * Rofi Version: 1.7.3
     **/

    /*****----- Configuration -----*****/
    configuration {
    	modi:                       "drun,run,filebrowser,window";
        show-icons:                 true;
        display-drun:               "Apps";
        display-run:                "Run";
        display-filebrowser:        "Files";
        display-window:             "Windows";
    	drun-display-format:        "{name}";
    	window-format:              "{w} · {c} · {t}";
    }

    /*****----- Global Properties -----*****/
    * {
        font:                        "Fira Code Nerd Font 10";
        background:                  #${config.stylix.base16Scheme.base00};
        background-alt:              #${config.stylix.base16Scheme.base01};
        foreground:                  #${config.stylix.base16Scheme.base05};
        selected:                    #${config.stylix.base16Scheme.base0E};
        active:                      #${config.stylix.base16Scheme.base0F};
        urgent:                      #${config.stylix.base16Scheme.base08};
    }

    /*****----- Main Window -----*****/
    window {
        /* properties for window widget */
        transparency:                "real";
        location:                    center;
        anchor:                      center;
        fullscreen:                  false;
        width:                       1000px;
        x-offset:                    0px;
        y-offset:                    0px;

        /* properties for all widgets */
        enabled:                     true;
        border-radius:               20px;
        cursor:                      "default";
        background-color:            @background;
    }

    /*****----- Main Box -----*****/
    mainbox {
        enabled:                     true;
        spacing:                     0px;
        background-color:            transparent;
        orientation:                 vertical;
        children:                    [ "inputbar", "listbox" ];
    }

    listbox {
        spacing:                     20px;
        padding:                     20px;
        background-color:            transparent;
        orientation:                 vertical;
        children:                    [ "message", "listview" ];
    }

    /*****----- Inputbar -----*****/
    inputbar {
        enabled:                     true;
        spacing:                     10px;
        padding:                     80px 60px;
        background-color:            transparent;
        background-image:            url("~/Pictures/village.jpg", width);
        text-color:                  @foreground;
        orientation:                 horizontal;
        children:                    [ "textbox-prompt-colon", "entry", "dummy", "mode-switcher" ];
    }
    textbox-prompt-colon {
        enabled:                     true;
        expand:                      false;
        str:                         "";
        padding:                     12px 15px;
        border-radius:               100%;
        background-color:            @background-alt;
        text-color:                  inherit;
    }
    entry {
        enabled:                     true;
        expand:                      false;
        width:                       300px;
        padding:                     12px 16px;
        border-radius:               100%;
        background-color:            @background-alt;
        text-color:                  inherit;
        cursor:                      text;
        placeholder:                 "Search";
        placeholder-color:           inherit;
    }
    dummy {
        expand:                      true;
        background-color:            transparent;
    }

    /*****----- Mode Switcher -----*****/
    mode-switcher{
        enabled:                     true;
        spacing:                     10px;
        background-color:            transparent;
        text-color:                  @foreground;
    }
    button {
        width:                       80px;
        padding:                     12px;
        border-radius:               100%;
        background-color:            @background-alt;
        text-color:                  inherit;
        cursor:                      pointer;
    }
    button selected {
        background-color:            @selected;
        text-color:                  @background-alt;
    }

    /*****----- Listview -----*****/
    listview {
        enabled:                     true;
        columns:                     2;
        lines:                       8;
        cycle:                       true;
        dynamic:                     true;
        scrollbar:                   false;
        layout:                      vertical;
        reverse:                     false;
        fixed-height:                true;
        fixed-columns:               true;
    
        spacing:                     10px;
        background-color:            transparent;
        text-color:                  @foreground;
        cursor:                      "default";
    }

    /*****----- Elements -----*****/
    element {
        enabled:                     true;
        spacing:                     10px;
        padding:                     4px;
        border-radius:               100%;
        background-color:            transparent;
        text-color:                  @foreground;
        cursor:                      pointer;
    }
    element normal.normal {
        background-color:            inherit;
        text-color:                  inherit;
    }
    element normal.urgent {
        background-color:            @urgent;
        text-color:                  @background-alt;
    }
    element normal.active {
        background-color:            @active;
        text-color:                  @background-alt;
    }
    element selected.normal {
        background-color:            @selected;
        text-color:                  @background-alt;
    }
    element selected.urgent {
        background-color:            @urgent;
        text-color:                  @background-alt;
    }
    element selected.active {
        background-color:            @urgent;
        text-color:                  @background-alt;
    }
    element-icon {
        background-color:            transparent;
        text-color:                  inherit;
        size:                        32px;
        cursor:                      inherit;
    }
    element-text {
        background-color:            transparent;
        text-color:                  inherit;
        cursor:                      inherit;
        vertical-align:              0.5;
        horizontal-align:            0.0;
    }

    /*****----- Message -----*****/
    message {
        background-color:            transparent;
    }
    textbox {
        padding:                     12px;
        border-radius:               100%;
        background-color:            @background-alt;
        text-color:                  @foreground;
        vertical-align:              0.5;
        horizontal-align:            0.0;
    }
    error-message {
        padding:                     12px;
        border-radius:               20px;
        background-color:            @background;
        text-color:                  @foreground;
    }

  '';
}

