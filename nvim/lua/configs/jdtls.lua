local M = {}

function M.setup()
  -- 1. YOUR JAVA PATH (Provided by you)
  local java_cmd = "/Users/guilhermejose/.sdkman/candidates/java/current/bin/java"

  -- 2. MASON JDTLS PATHS
  local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
  local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  
  -- 3. MACOS SPECIFIC CONFIGURATION
  -- We hardcode 'config_mac' since we know you are on macOS
  local os_config = jdtls_path .. "/config_mac"

  -- 4. WORKSPACE DIRECTORY
  -- Creates a unique data folder for every project to prevent conflicts
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  local workspace_dir = vim.fn.stdpath("data") .. "/site/java/workspace-root/" .. project_name

  local config = {
    cmd = {
      java_cmd,
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-Xmx1g",
      "--add-modules=ALL-SYSTEM",
      "--add-opens", "java.base/java.util=ALL-UNNAMED",
      "--add-opens", "java.base/java.lang=ALL-UNNAMED",
      
      "-jar", launcher_jar,
      "-configuration", os_config,
      "-data", workspace_dir,
    },

    -- 5. ROOT DETECTION (Robust)
    -- This ensures the server attaches even to single files (cwd fallback)
    root_dir = vim.fs.root(0, {".git", "mvnw", "gradlew", "pom.xml", "build.gradle"}) or vim.fn.getcwd(),

    -- 6. NVCHAD INTEGRATION
    capabilities = require("nvchad.configs.lspconfig").capabilities,
    on_attach = function(client, bufnr)
      require("nvchad.configs.lspconfig").on_attach(client, bufnr)
    end,
  }

  require("jdtls").start_or_attach(config)
end

return M
