if ngx.var.cookie_user == nil then
    ngx.say("cookie user: missing")
else
    ngx.say("cookie user: [", ngx.var.cookie_user, "]")
end
