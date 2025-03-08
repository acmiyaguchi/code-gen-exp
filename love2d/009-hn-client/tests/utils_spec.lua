-- Unit tests for utils module

local busted = require("busted")
local describe = busted.describe
local it = busted.it
local assert = require("luassert")

-- Setup path to find modules
package.path = "../?.lua;" .. package.path

local utils = require("utils")

describe("Utils module", function()
  describe("timeAgo", function()
    it("should handle 'just now' case", function()
      local now = os.time()
      assert.equals("just now", utils.timeAgo(now))
    end)
    
    it("should handle minutes", function()
      local time = os.time() - 120 -- 2 minutes ago
      assert.equals("2 minutes ago", utils.timeAgo(time))
    end)
    
    it("should handle singular minute", function()
      local time = os.time() - 60 -- 1 minute ago
      assert.equals("1 minute ago", utils.timeAgo(time))
    end)
    
    it("should handle hours", function()
      local time = os.time() - 7200 -- 2 hours ago
      assert.equals("2 hours ago", utils.timeAgo(time))
    end)
  end)
  
  describe("formatCommentText", function()
    it("should strip HTML tags", function()
      assert.equals("Hello world", utils.formatCommentText("<p>Hello world</p>"))
    end)
    
    it("should decode HTML entities", function()
      assert.equals("a < b", utils.formatCommentText("a &lt; b"))
      assert.equals("a > b", utils.formatCommentText("a &gt; b"))
      assert.equals("a & b", utils.formatCommentText("a &amp; b"))
    end)
  end)
  
  describe("getHostname", function()
    it("should extract hostname from URL", function()
      assert.equals("example.com", utils.getHostname("https://example.com/path"))
      assert.equals("sub.example.com", utils.getHostname("http://sub.example.com/path?query=1"))
    end)
    
    it("should handle URLs without protocol", function()
      assert.equals("example.com", utils.getHostname("example.com/path"))
    end)
  end)
  
  describe("json parsing", function()
    it("should parse story list", function()
      local json = "[1,2,3,4,5]"
      local result = utils.json.decode(json)
      assert.equals(5, #result)
      assert.equals(1, result[1])
      assert.equals(5, result[5])
    end)
    
    it("should parse story object", function()
      local json = [[{"id":123,"title":"Test Story","by":"testuser","score":100,"time":1630000000,"url":"http://example.com","type":"story"}]]
      local result = utils.json.decode(json)
      assert.equals(123, result.id)
      assert.equals("Test Story", result.title)
      assert.equals("testuser", result.by)
      assert.equals(100, result.score)
    end)
  end)
end)
