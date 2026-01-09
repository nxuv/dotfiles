require("utils")

local M = {}

M.filter = function(document)
    remove_class(document, "icon")
    remove_class(document, "navbar-nav")

    -- local blob = document:getElementsByClassName("blob")[1]
    -- blob.parentNode:insertBefore(document:createElement("hr"), blob)

    insert_hr_before_class(document, "header-extension")

    local code_views = document:getElementsByClassName("code-viewport")
    ---@diagnostic disable-next-line: unused-local
    for _, code in ipairs(code_views) do
        remove_class(document, "lines")
    end
    local highlights = document:getElementsByClassName("highlight")
    for _, highlight in ipairs(highlights) do
        if highlight.tagName == "DIV" then
            for node in highlight:walk() do
                if node.tagName == "SPAN" then
                    replace_attribute_if(node, "class", "c" , "token_comment")
                    replace_attribute_if(node, "class", "c1", "token_comment")
                    replace_attribute_if(node, "class", "ch", "token_comment")
                    replace_attribute_if(node, "class", "cm", "token_comment")
                    replace_attribute_if(node, "class", "cp", "token_comment")
                    replace_attribute_if(node, "class", "cpf", "token_comment")
                    replace_attribute_if(node, "class", "cs", "token_comment")

                    replace_attribute_if(node, "class", "k" , "token_keyword")
                    replace_attribute_if(node, "class", "kc", "token_keyword")
                    replace_attribute_if(node, "class", "kd", "token_keyword")
                    replace_attribute_if(node, "class", "kp", "token_keyword")
                    replace_attribute_if(node, "class", "kr", "token_keyword")
                    replace_attribute_if(node, "class", "kt", "token_keyword")
                    replace_attribute_if(node, "class", "kn", "token_keyword")
                    replace_attribute_if(node, "class", "no", "token_keyword")

                    replace_attribute_if(node, "class", "gu", "token_number")
                    replace_attribute_if(node, "class", "il", "token_number")
                    replace_attribute_if(node, "class", "l" , "token_number")
                    replace_attribute_if(node, "class", "m" , "token_number")
                    replace_attribute_if(node, "class", "mb", "token_number")
                    replace_attribute_if(node, "class", "mf", "token_number")
                    replace_attribute_if(node, "class", "mh", "token_number")
                    replace_attribute_if(node, "class", "mi", "token_number")
                    replace_attribute_if(node, "class", "mo", "token_number")
                    replace_attribute_if(node, "class", "se", "token_number")

                    replace_attribute_if(node, "class", "na",  "token_special")
                    replace_attribute_if(node, "class", "nc",  "token_special")
                    replace_attribute_if(node, "class", "nd",  "token_special")
                    replace_attribute_if(node, "class", "ne",  "token_special")
                    replace_attribute_if(node, "class", "nf",  "token_special")

                    replace_attribute_if(node, "class", "dl",  "token_string")
                    replace_attribute_if(node, "class", "ld",  "token_string")
                    replace_attribute_if(node, "class", "s" ,  "token_string")
                    replace_attribute_if(node, "class", "s1",  "token_string")
                    replace_attribute_if(node, "class", "s2",  "token_string")
                    replace_attribute_if(node, "class", "sa",  "token_string")
                    replace_attribute_if(node, "class", "sb",  "token_string")
                    replace_attribute_if(node, "class", "sc",  "token_string")
                    replace_attribute_if(node, "class", "sd",  "token_string")
                    replace_attribute_if(node, "class", "sh",  "token_string")
                    replace_attribute_if(node, "class", "si",  "token_string")
                    replace_attribute_if(node, "class", "sr",  "token_string")
                    replace_attribute_if(node, "class", "ss",  "token_string")
                    replace_attribute_if(node, "class", "sx",  "token_string")

                    -- replace_attribute_if(node, "class", "nx", "token_identifier")
                    -- replace_attribute_if(node, "class", "o",  "token_operator")
                    -- replace_attribute_if(node, "class", "p",  "token_parens")
                end
            end
        end
    end
end

return M

