return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "mason-org/mason.nvim",
        "mason-org/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        require("conform").setup({
            formatters_by_ft = {
                c   = { "clang-format" },
                cpp = { "clang-format" },
            },
            formatters = {
                ["clang-format"] = {
                    prepend_args = {
                        "--style={BasedOnStyle: Google, IndentWidth: 4, TabWidth: 4, UseTab: Never}",
                    },
                },
            },
            format_on_save = {
                timeout_ms = 2000,
                lsp_fallback = false,
            },
        })
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "clangd",
                "lua_ls",
                "rust_analyzer",
                "omnisharp"
            },
            automatic_enable = false,
        })

        local lspconfig = require("lspconfig")
        local util = require("lspconfig.util")

        local base = require("lspconfig")
        local on_attach = base.on_attach

        lspconfig.clangd.setup({
            on_attach = function(client, bufnr)
                client.server_capabilities.signatureHelpProvider = false
                on_attach(client, bufnr)
            end,
            capabilities = capabilities,
        })

        lspconfig.rust_analyzer.setup({
            capabilities = capabilities,
        })

        lspconfig.zls.setup({
            capabilities = capabilities,
            root_dir = util.root_pattern(".git", "build.zig", "zls.json"),
            settings = {
                zls = {
                    enable_inlay_hints = true,
                    enable_snippets = true,
                    warn_style = true,
                },
            },
        })
        vim.g.zig_fmt_parse_errors = 0
        vim.g.zig_fmt_autosave = 0

        lspconfig.lua_ls.setup({
            capabilities = capabilities,
            settings = {
                Lua = {
                    format = {
                        enable = true,
                        defaultConfig = {
                            indent_style = "space",
                            indent_size = "2",
                        }
                    },
                }
            }
        })

        local omnisharp_bin = vim.fn.stdpath("data")
            .. "/mason/packages/omnisharp/libexec"

        local omnisharp_cmd = {
            "dotnet",
            omnisharp_bin .. "/OmniSharp.dll",
            "--languageserver",
            "--hostPID", tostring(vim.fn.getpid()),
            "--loglevel", "Debug",
        }

        local function on_init(client)
            return true
        end

        local function on_attach(bufnr)
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ async = false })
                end,
            })
        end

        lspconfig.omnisharp.setup {
            capabilities = capabilities,
            cmd = omnisharp_cmd,
            on_init = on_init,
            on_attach = on_attach,

            root_dir = function(fname)
                local unity_markers = {
                    "Assets/Scripts",
                    "ProjectSettings",
                    "Assembly-CSharp.csproj",
                    "UnityEngine.dll"
                }

                for _, marker in ipairs(unity_markers) do
                    local marker_path = vim.fn.finddir(marker, vim.fn.fnamemodify(fname, ":p:h") .. ";")
                    if marker_path ~= "" then
                        local unity_project_root = vim.fn.fnamemodify(marker_path, ":h")
                        return unity_project_root
                    end
                end

                return util.root_pattern("*.sln", "*.csproj")(fname)
                    or util.find_git_ancestor(fname)
                    or vim.fn.getcwd() -- Last resort
            end,

            settings = {
                RoslynExtensionsOptions = {
                    enableAnalyzersSupport = true,
                    enableImportCompletion = true,
                    enableSemanticHighlighting = true,
                },
                FormattingOptions = {
                    enableEditorConfigSupport = true,
                    organizeImports = true,
                },
                FileOptions = {
                    systemExcludeSearchPatterns = {
                        "**/node_modules/**/*",
                        "**/bin/**/*",
                        "**/obj/**/*"
                    },
                    excludeSearchPatterns = {}
                },
                RenameOptions = {
                    renameOverloads = true,
                    renameInComments = true,
                    renameInStrings = true,
                },
                ImplementTypeOptions = {
                    insertionBehavior = "WithOtherMembersOfTheSameKind",
                    propertyGenerationBehavior = "PreferAutoProperties"
                },
                EnableMsBuildLoadProjectsOnDemand = true,
                enableDecompilationSupport = true,
                enableImportCompletion = true,
                enableAsyncCompletion = true,
                analyzeOpenDocumentsOnly = false
            },

            init_options = {
                initializationTimeout = 120000,
            },

            handlers = {
                ["window/logMessage"] = function(err, method, params, client_id)
                    if params and params.type and params.message then
                        local msg_type = { "ERROR", "WARNING", "INFO", "LOG" }
                        local msg_type_name = msg_type[params.type] or "UNKNOWN"
                    end
                end,
            },

            flags = {
                debounce_text_changes = 150,
                allow_incremental_sync = true,
            },
        }

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<Up>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<Down>'] = cmp.mapping.select_next_item(cmp_select),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                -- FIX: Uncomment when copilot needed
                -- { name = "copilot", group_index = 2 },
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })

        vim.api.nvim_create_user_command('StartOmniSharp', function()
            local cs_file = vim.fn.globpath(vim.fn.getcwd(), "**/*.cs", true, true)[1]
            if cs_file then
                vim.cmd("edit " .. cs_file)
                vim.lsp.start({
                    name = "omnisharp",
                    cmd = omnisharp_cmd,
                    root_dir = vim.fn.getcwd(),
                })
            else
                print("not c#")
            end
        end, {})
    end
}
