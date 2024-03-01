local M = {}

local irregulars = {
  ["analysis"] = "analyses",
  ["axis"] = "axes",
  ["basis"] = "bases",
  ["child"] = "children",
  ["crisis"] = "crises",
  ["datum"] = "data",
  ["foot"] = "feet",
  ["formula"] = "formulae",
  ["goose"] = "geese",
  ["hypothesis"] = "hypotheses",
  ["index"] = "indices",
  ["larva"] = "larvae",
  ["man"] = "men",
  ["medium"] = "media",
  ["memorandum"] = "memoranda",
  ["mouse"] = "mice",
  ["octopus"] = "octopi",
  ["ox"] = "oxen",
  ["passerby"] = "passersby",
  ["phenomenon"] = "phenomena",
  ["quiz"] = "quizzes",
  ["stimulus"] = "stimuli",
  ["tooth"] = "teeth",
  ["woman"] = "women",
}

---@param word string
---@return string
function M.pluralize(word)
  if 2 > #word then
    return word
  end

  if irregulars[word] then
    return irregulars[word]
  end

  if word:match("[^aeiou]y$") then
    return word:sub(1, -2) .. "ies"
  end

  if word:match("[^aeiou]o$") or word:match("[cs]h$") or word:match("[sxz]$") then
    return word .. "es"
  end

  if word:match("f$") then
    return word:sub(1, -2) .. "ves"
  end

  if word:match("fe$") then
    return word:sub(1, -3) .. "ves"
  end

  return word .. "s"
end

return M
