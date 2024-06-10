local fx = require("fx/lib/fx")
local mod = require 'core/mods'
local hook = require 'core/hook'
local tab = require 'tabutil'
-- Begin post-init hack block
if hook.script_post_init == nil and mod.hook.patched == nil then
    mod.hook.patched = true
    local old_register = mod.hook.register
    local post_init_hooks = {}
    mod.hook.register = function(h, name, f)
        if h == "script_post_init" then
            post_init_hooks[name] = f
        else
            old_register(h, name, f)
        end
    end
    mod.hook.register('script_pre_init', '!replace init for fake post init', function()
        local old_init = init
        init = function()
            old_init()
            for i, k in ipairs(tab.sort(post_init_hooks)) do
                local cb = post_init_hooks[k]
                print('calling: ', k)
                local ok, error = pcall(cb)
                if not ok then
                    print('hook: ' .. k .. ' failed, error: ' .. error)
                end
            end
        end
    end)
end
-- end post-init hack block


local FxSpring = fx:new{
    subpath = "/fx_spring"
}


function FxSpring:add_params()
    params:add_group("fx_spring", "fx spring", 5)
    FxSpring:add_slot("fx_spring_slot", "slot")
    FxSpring:add_taper("fx_spring_predelay", "predelay", "predelay", 0, 1, 0.015, 1, "s")
    FxSpring:add_taper("fx_spring_room", "room", "room", 0, 1, 0.5, 1, "")
    FxSpring:add_taper("fx_spring_damp", "damp", "damp", 0, 1, 0.8, 1, "")
end

mod.hook.register("script_post_init", "fx spring mod post init", function()
    FxSpring:add_params()
end)

mod.hook.register("script_post_cleanup", "fx spring mod post cleanup", function()
end)

return FxSpring
