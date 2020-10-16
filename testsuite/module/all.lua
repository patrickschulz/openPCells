do
    local status, msg = pcall(_load_module, "testsuite/module/modules/correct")
    report("correct", status, msg)
end

do
    local status = pcall(_load_module, "testsuite/module/modules/syntaxerror")
    report("syntaxerror", not status, "_load_module did succeed on module with syntax error")
end

do
    local status = pcall(_load_module, "testsuite/module/modules/semanticerror")
    report("semanticerror", not status, "_load_module did succeed on module with semantic error")
end
