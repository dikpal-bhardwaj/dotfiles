local M = {}

function M.run()
    local ft = vim.bo.filetype
    local filename = vim.fn.expand '%:t'
    local filepath = vim.fn.expand '%:p'
    local filedir = vim.fn.expand '%:p:h'
    local basename = vim.fn.expand '%:t:r' -- filename without extension

    local cmd = ''

    if ft == 'c' then
        cmd = string.format('gcc %s -o %s && %s', filepath, filedir .. '/' .. basename, filedir .. '/' .. basename)
    elseif ft == 'cpp' then
        cmd = string.format('g++ %s -o %s && %s', filepath, filedir .. '/' .. basename, filedir .. '/' .. basename)
    elseif ft == 'python' then
        cmd = string.format('python3 %s', filepath)
    elseif ft == 'java' then
        cmd = string.format('javac %s && java -cp %s %s', filename, filedir, basename)
    else
        vim.notify('No runner setup for filetype: ' .. ft, vim.log.levels.WARN)
        return
    end

    -- Open terminal at bottom and run the command
    vim.cmd 'botright split | resize 15 | terminal'
    vim.fn.chansend(vim.b.terminal_job_id, cmd .. '\n')
end

return M
