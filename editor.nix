{ pkgs, lib, ... }:
{
  # Enable helix editor.
  programs.helix = {
    enable = true;
    defaultEditor = true;
  };

  # Remove blink from primary cursor.
  programs.helix.themes.base = {
    inherits = "base16_transparent";
    "ui.cursor.primary".modifiers = [ "reversed" ];
  };
  programs.helix.settings.theme = "base";

  # Configure editor settings.
  programs.helix.settings.editor = {
    scrolloff = 3;
    scroll-lines = 2;
    line-number = "relative";
    gutters = [
      "line-numbers"
      "diff"
    ];
    auto-format = true;
    completion-timeout = 5;
    completion-trigger-len = 1;
    completion-replace = true;
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
    lsp.auto-signature-help = false;
    cursor-shape = {
      normal = "block";
      insert = "bar";
      select = "underline";
    };
    soft-wrap.enable = true;
    inline-diagnostics.cursor-line = "warning";
  };

  # Configure keymap.
  programs.helix.settings.keys =
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
        "x" = "extend_line_below";
        "X" = "extend_line_above";
        "'" = "repeat_last_motion";
      };
    in
    {
      normal = normal // {
        "H" = [
          "select_mode"
          "ensure_selections_forward"
          "flip_selections"
          "goto_first_nonwhitespace"
          "normal_mode"
        ];
        "L" = [
          "select_mode"
          "ensure_selections_forward"
          "goto_line_end"
          "normal_mode"
        ];
        # Replicates old repeat_last_motion behavior. See
        # <https://github.com/helix-editor/helix/discussions/7710#discussioncomment-6517417>.
        "f" = "extend_next_char";
        "F" = "extend_prev_char";
        "t" = "extend_till_char";
        "T" = "extend_till_prev_char";
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

  # Add language support.
  home.packages = with pkgs; [
    nil
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
    typescript
    typescript-go
    typescript-language-server
  ];
  programs.helix.languages =
    let
      command =
        string:
        let
          parts = lib.splitString " " string;
        in
        {
          command = builtins.head parts;
          args = builtins.tail parts;

        };
    in
    {
      language-server = {
        # Use one of the language servers based on roots, see
        # <https://github.com/helix-editor/helix/discussions/11418#discussioncomment-10235793>.
        typescript-language-server.required-root-patterns = [
          "tsconfig.json"
          "package.json"
        ];
        deno-lsp = command "deno lsp" // {
          required-root-patterns = [ ];
          environment.NO_COLOR = "1";
          config.deno = {
            enable = true;
            lint = true;
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
        ruff = command "ruff server";
        superhtml = command "superhtml lsp";
        nil.config.nil.nix = {
          maxMemoryMB = 8590; # 8 GiB, because toml doesn't support null
          flake.autoArchive = true;
        };
        vscode-json-language-server.config.json.schemas =
          lib.attrsToList {
            "https://raw.githubusercontent.com/denoland/deno/main/cli/schemas/config-file.v1.json" = [
              "deno.json"
              "deno.jsonc"
            ];
            "https://unpkg.com/wrangler@latest/config-schema.json" = [
              "wrangler.json"
              "wrangler.jsonc"
            ];
          }
          |> builtins.map (pair: {
            url = pair.name;
            fileMatch = pair.value;
          });
        zls.config.zls = {
          enable_argument_placeholders = false;
          warn_style = true;
        };
      };
      language =
        let
          deno-fmt = extension: command "deno fmt --ext ${extension} --unstable-sql -";
        in
        lib.attrsToList {
          bash = {
            indent = {
              tab-width = 4;
              unit = "    ";
            };
            formatter = command "shfmt --indent 4";
          };
          c.formatter.command = "clang-format";
          cpp.formatter.command = "clang-format";
          css.formatter = deno-fmt "css";
          html = {
            language-servers = [ "superhtml" ];
            formatter = command "superhtml fmt --stdin";
          };
          typescript = {
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
            language-servers = [
              "deno-lsp"
              "typescript-language-server"
            ];
            formatter = deno-fmt "ts";
          };
          javascript = {
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
            language-servers = [
              "deno-lsp"
              "typescript-language-server"
            ];
            formatter = deno-fmt "js";
          };
          json.formatter = deno-fmt "json";
          jsonc = {
            file-types = [
              "jsonc"
              { glob = "{deno,bun}.lock"; }
            ];
            formatter = deno-fmt "jsonc";
          };
          lua.formatter = command "stylua -";
          markdown.formatter = deno-fmt "md";
          nix = { };
          python.formatter = command "ruff format -";
          sql.formatter = deno-fmt "sql";
          toml = {
            # Required to avoid `this document has been excluded`. See
            # <https://github.com/tamasfe/taplo/issues/580#issuecomment-2004174721>.
            roots = [ "." ];
            formatter = command "taplo fmt -";
          };
          typst.formatter = command "typstyle --wrap-text";
        }
        |> builtins.map (
          { name, value }:
          value
          // {
            inherit name;
            auto-format = true;
          }
        );
    };
  # Required to avoid `this document has been excluded`. See
  # <https://github.com/tamasfe/taplo/issues/320#issuecomment-2897257730>.
  home.file.".taplo.toml".text = ''
    include = ["**/*.toml", "**/*.toml.tmpl"]
  '';
  home.file.".config/clangd/config.yaml".text = ''
    Completion:
      ArgumentLists: Delimiters
    Hover:
      MacroContentLimit: 0
    Documentation:
      CommentFormat: Markdown
  '';
}
