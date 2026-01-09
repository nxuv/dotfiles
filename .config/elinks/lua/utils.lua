---@diagnostic disable: lowercase-global

function remove_class(document, class_name)
    elements = document:getElementsByClassName(class_name)
    for _, element in ipairs(elements) do element:remove() end
end

function remove_tags(document, tag_name)
    elements = document:getElementsByTagName(tag_name)
    for _, element in ipairs(elements) do element:remove() end
end

function remove_id(document, id_name)
    document:getElementById(id_name):remove()
end

-- for node in document.body:walk() do
--     if node.localName == "meta" then end
-- end

function replace_attribute_if(node, attr, if_value, replace_value)
    if node:getAttribute(attr) == if_value then
        node:setAttribute(attr, replace_value)
    end
end

function insert_hr_before_class(document, classname)
    elements = document:getElementsByClassName(classname)
    for _, element in ipairs(elements) do
        element.parentNode:insertBefore(document:createElement("hr"), element)
    end
end

function insert_hr_after_class(document, classname)
    elements = document:getElementsByClassName(classname)
    for _, element in ipairs(elements) do
        element.parentNode:insertBefore(document:createElement("hr"), element.nextSibling)
    end
end

function insert_hr_before_tag(document, tag)
    elements = document:getElementsByTagName(tag)
    for _, element in ipairs(elements) do
        element.parentNode:insertBefore(document:createElement("hr"), element)
    end
end

function insert_hr_after_tag(document, tag)
    elements = document:getElementsByTagName(tag)
    for _, element in ipairs(elements) do
        element.parentNode:insertBefore(document:createElement("hr"), element.nextSibling)
    end
end

function insert_text_in_tag(document, tag, text)
    elements = document:getElementsByTagName(tag)
    for _, element in ipairs(elements) do
        if #element.children > 0 then
            element:insertBefore(document:createTextNode(text), element.firstElementChild)
        else
            element.textContent = text .. element.textContent
        end
    end
end

