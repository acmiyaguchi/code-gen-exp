local M = {}

-- Variable creation and manipulation
local var_id = 0
function M.var(c)
  return {type = "var", id = c or var_id}
end

function M.is_var(x)
  return type(x) == "table" and x.type == "var"
end

function M.var_eq(x1, x2)
  return M.is_var(x1) and M.is_var(x2) and x1.id == x2.id
end

-- Value term creation
function M.val(x)
  return {type = "val", value = x}
end

function M.is_val(x)
  return type(x) == "table" and x.type == "val"
end

-- Pair term creation
function M.pair(a, b)
  return {type = "pair", left = a, right = b}
end

function M.is_pair(x)
  return type(x) == "table" and x.type == "pair"
end

-- Helper functions for term comparison
local function term_eq(u, v)
  if M.is_var(u) and M.is_var(v) then
    return M.var_eq(u, v)
  elseif M.is_val(u) and M.is_val(v) then
    return u.value == v.value
  elseif M.is_pair(u) and M.is_pair(v) then
    return term_eq(u.left, v.left) and term_eq(u.right, v.right)
  else
    return false
  end
end

-- Walk through a substitution to find the final binding
function M.walk(u, s)
  if M.is_var(u) then
    for _, binding in ipairs(s) do
      if M.var_eq(binding[1], u) then
        return M.walk(binding[2], s)
      end
    end
  end
  return u
end

-- Extend a substitution with a new binding
function M.ext_s(x, v, s)
  return {{x, v}, table.unpack(s)}
end

-- Unification function
function M.unify(u, v, s)
  local u = M.walk(u, s)
  local v = M.walk(v, s)
  
  if M.is_var(u) and M.is_var(v) and M.var_eq(u, v) then
    return s
  elseif M.is_var(u) then
    return M.ext_s(u, v, s)
  elseif M.is_var(v) then
    return M.ext_s(v, u, s)
  elseif M.is_pair(u) and M.is_pair(v) then
    local s_prime = M.unify(u.left, v.left, s)
    if s_prime then
      return M.unify(u.right, v.right, s_prime)
    end
    return nil
  else
    if term_eq(u, v) then
      return s
    end
    return nil
  end
end

-- Empty stream
function M.mzero()
  return {}
end

-- Stream with a single state
function M.unit(s_c)
  return {s_c, M.mzero()}
end

-- Create an initial empty state with a counter
function M.empty_state()
  return {{}, 0}  -- {substitution, counter}
end

-- Unification goal constructor
function M.equiv(u, v)
  return function(s_c)
    local s = M.unify(u, v, s_c[1])
    if s then
      return M.unit({s, s_c[2]})
    else
      return M.mzero()
    end
  end
end

-- Fresh variable introduction
function M.call_fresh(f)
  return function(s_c)
    local c = s_c[2]
    return f(M.var(c))({s_c[1], c + 1})
  end
end

-- Goal combinators: disjunction (logical OR)
function M.disj(g1, g2)
  return function(s_c)
    return M.mplus(g1(s_c), g2(s_c))
  end
end

-- Goal combinators: conjunction (logical AND)
function M.conj(g1, g2)
  return function(s_c)
    return M.bind(g1(s_c), g2)
  end
end

-- Stream operators
function M.mplus(s1, s2)
  if #s1 == 0 then
    return s2
  elseif type(s1) == "function" then
    return function()
      return M.mplus(s2, s1())
    end
  else
    return {s1[1], M.mplus(table.unpack(s1, 2), s2)}
  end
end

function M.bind(s, g)
  if #s == 0 then
    return M.mzero()
  elseif type(s) == "function" then
    return function()
      return M.bind(s(), g)
    end
  else
    return M.mplus(g(s[1]), M.bind(table.unpack(s, 2), g))
  end
end

-- Helper function to take n results from a stream
function M.take(n, stream)
  local results = {}
  local s = stream
  
  for i = 1, n do
    if #s == 0 then
      break
    end
    
    if type(s) == "function" then
      s = s()
    else
      table.insert(results, s[1])
      s = s[2]
    end
  end
  
  return results
end

-- Convenience aliases
M["=="] = M.equiv

return M
