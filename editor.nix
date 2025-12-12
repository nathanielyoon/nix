{ pkgs, ... }:
{
  # Enable helix editor.
  programs.helix = {
    enable = true;
    defaultEditor = true;
  };
  home.packages = with pkgs; [
    nil
    nixd
    nixfmt-rfc-style
    bash-language-server
    shfmt
    clang-tools
    rust-analyzer
    rustfmt
    vscode-langservers-extracted
    marksman
    taplo
    superhtml
    typst
    tinymist
    typstyle
    ruff
    ty
    zls
    kdlfmt
    lua-language-server
    stylua
  ];
  programs.helix.themes.base = {
    inherits = "base16_transparent";
    "ui.cursor.primary".modifiers = [ "reversed" ];
  };
  programs.helix.settings = {
    theme = "base";
    editor = {
      scrolloff = 0;
      scroll-lines = 2;
      line-number = "relative";
      gutters = [
        "line-numbers"
        "diff"
      ];
      completion-timeout = 5;
      completion-trigger-len = 1;
      completion-replace = true;
      color-modes = true;
      trim-final-newlines = true;
      popup-border = "popup";
      end-of-line-diagnostics = "hint";
      statusline = {
        left = [
          "total-line-numbers"
          "file-name"
          "read-only-indicator"
          "file-modification-indicator"
        ];
        right = [
          "diagnostics"
          "register"
          "selections"
          "primary-selection-length"
          "position"
        ];
      };
      lsp = {
        auto-signature-help = false;
        display-inlay-hints = false;
      };
      cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
      soft-wrap.enable = true;
      inline-diagnostics.cursor-line = "warning";
    };
    keys =
      let
        insert = {
          "C-v" = "signature_help";
          "C-h" = ":toggle-option lsp.display-inlay-hints";
        };
        normal = insert // {
          "Y" = "yank_joined";
          "a" = [
            "append_mode"
            "collapse_selection"
          ];
          "i" = [
            "insert_mode"
            "collapse_selection"
          ];
          "~" = "switch_to_lowercase";
          "`" = "switch_case";
          "x" = "extend_line";
        };
      in
      {
        normal = normal // {
          "H" = [
            "select_mode"
            "ensure_selections_forward"
            "flip_selections"
            "goto_first_nonwhitespace"
          ];
          "L" = [
            "select_mode"
            "ensure_selections_forward"
            "goto_line_end"
          ];
        };
        select = normal // {
          "H" = [
            "ensure_selections_forward"
            "flip_selections"
            "goto_first_nonwhitespace"
          ];
          "L" = [
            "ensure_selections_forward"
            "goto_line_end"
          ];
        };
        insert = insert;
      };
  };
  programs.helix.languages.language-server = {
    deno-lsp = {
      command = "deno";
      args = [ "lsp" ];
      environment.NO_COLOR = "1";
      config.deno = {
        enable = true;
        lint = false;
        unstable = true;
        maxTsServerMemory = 24576;
        cacheOnSave = true;
        disablePaths = [ "./dist" ];
        typescript.preferences = {
          useAliasesForRenames = false;
          importModuleSpecifierPreference = "project-relative";
          diagnostics.ignoredCodes = [
            2581
            2582
          ];
        };
      };
    };
    ruff = {
      command = "ruff";
      args = [ "server" ];
    };
    tinymist.command = "tinymist";
    superhtml = {
      commmand = "superhtml";
      args = [ "lsp" ];
    };
    nil = {
      command = "nil";
      config.nil.nix.flake.autoArchive = true;
    };
    nixd.command = "nixd";
    vscode-json = {
      command = "vscode-json-language-server";
      args = [ "--stdio" ];
      config.json.schemas = [
        {
          fileMatch = [
            "deno.json"
            "deno.jsonc"
          ];
          url = "https://raw.githubusercontent.com/denoland/deno/main/cli/schemas/config-file.v1.json";
        }
        {
          fileMatch = [
            "wrangler.json"
            "wrangler.jsonc"
          ];
          url = "https://unpkg.com/wrangler@latest/config-schema.json";
        }
      ];
    };
    zls.config.zls.enable_argument_placeholders = false;
  };
  home.file.clangd = {
    text = ''
      Completion:
        ArgumentLists: Delimiters
      Hover:
        MacroContentLimit: 0
      Documentation:
        CommentFormat: Markdown
    '';
    target = ".config/clangd/config.yaml";
  };
  programs.helix.languages.language =
    let
      deno-fmt = extension: {
        command = "deno";
        args = [
          "fmt"
          "-"
          "--ext"
          extension
        ];
      };
    in
    [
      {
        name = "nix";
        formatter.command = "nixfmt";
        language-servers = [
          "nixd"
          "nil"
        ];
        auto-format = true;
      }
      {
        name = "bash";
        indent = {
          tab-width = 4;
          unit = "    ";
        };
        formatter = {
          command = "shfmt";
          args = [
            "-i"
            "4"
          ];
        };
        auto-format = true;
      }
      {
        name = "typst";
        language-servers = [ "tinymist" ];
        formatter = {
          command = "typstyle";
          args = [ "--wrap-text" ];
        };
        auto-format = true;
      }
      {
        name = "toml";
        formatter = {
          command = "taplo";
          args = [
            "fmt"
            "-"
          ];
        };
        auto-format = true;
      }
      {
        name = "html";
        language-servers = [ "superhtml" ];
        formatter = {
          command = "superhtml";
          args = [
            "fmt"
            "--stdin"
          ];
        };
        auto-format = true;
      }
      {
        name = "typescript";
        shebangs = [ "deno" ];
        roots = [
          "deno.json"
          "deno.jsonc"
          "package.json"
          "tsconfig.json"
        ];
        file-types = [
          "ts"
          "mts"
          "cts"
        ];
        language-servers = [ "deno-lsp" ];
        formatter = deno-fmt "ts";
        auto-format = true;
      }
      {
        name = "javascript";
        shebangs = [ "node" ];
        roots = [
          "deno.json"
          "deno.jsonc"
          "package.json"
          "tsconfig.json"
        ];
        file-types = [
          "js"
          "mjs"
          "cjs"
        ];
        language-servers = [ "deno-lsp" ];
        formatter = deno-fmt "js";
        auto-format = true;
      }
      {
        name = "json";
        formatter = deno-fmt "json";
        language-servers = [ "vscode-json" ];
        auto-format = true;
      }
      {
        name = "jsonc";
        scope = "source.json";
        injection-regex = "jsonc";
        file-types = [
          "jsonc"
          { glob = "{deno,bun}.lock"; }
        ];
        formatter = deno-fmt "jsonc";
        language-servers = [ "vscode-json" ];
        auto-format = true;
      }
      {
        name = "markdown";
        formatter = deno-fmt "md";
        language-servers = [ "marksman" ];
        auto-format = true;
      }
      {
        name = "css";
        formatter = deno-fmt "css";
        auto-format = true;
      }
      {
        name = "c";
        auto-format = true;
      }
      {
        name = "cpp";
        auto-format = true;
      }
      {
        name = "python";
        auto-format = true;
      }
      {
        name = "kdl";
        auto-format = true;
      }
      {
        name = "lua";
        formatter = {
          command = "stylua";
          args = [ "-" ];
        };
        auto-format = true;
      }
      {
        name = "zig";
        rulers = [ 100 ];
        auto-format = true;
      }
    ];
}
