-- HandyNotes_HigherLearning
-- enUS and enGB Localization file

local L = LibStub("AceLocale-3.0"):NewLocale("HandyNotes_HigherLearning", "enUS", true)

if not L then return end

-- General
L["HandyNotes"] = "HandyNotes - Higher Learning"
L["Title"] = "Higher Learning"
L["Desc"] = "Shows the books you still need to read for the Higher Learning achievement"
L["Create waypoint"] = "Create waypoint"
L["Close"] = "Close"

-- Options
L["Setting desc"] = "These settings control the look and feel of the icons."
L["Icon Scale"] = "Icon Scale"
L["The scale of the icons"] = "The scale of the icons"
L["Icon Alpha"] = "Icon Alpha"
L["The alpha transparency of the icons"] = "The alpha transparency of the icons"

L["Minimap Icon Scale"] = "Minimap Icon Scale"
L["The scale of the icons on the Minimap"] = "The scale of the icons on the Minimap"
L["Minimap Icon Alpha"] = "Minimap Icon Alpha"
L["The alpha transparency of the icons on the Minimap"] = "The alpha transparency of the icons on the Minimap"

L["Show completed"] = "Show read books"
L["Display completed nodes"] = "Display books you have already read"

L["Show extra"] = "Show location notes"
L["Extra desc"] = "Show additional note information in the tooltip"

-- Notes
L["Introduction"] = '"Introduction"'
L["Abjuration"] = '"Abjuration"'
L["Conjuration"] = '"Conjuration"'
L["Divination"] = '"Divination"'
L["Enchantment"] = '"Enchantment"'
L["Illusion"] = '"Illusion"'
L["Necromancy"] = '"Necromancy"'
L["Transmutation"] = '"Transmutation"'

L["IntroductionNote"] = "On the floor at the base of the bookshelf\non the right side of the room."
L["AbjurationNote"] = "Downstairs. On the right side.\nOn the floor next to a stool with books upon it."
L["ConjurationNote"] = "On the right side of the room as you\nenter. Stand in front of the bookshelves.\n"..
		"The book is in the empty space on the\nbottom shelf of the left hand bookshelf."
L["DivinationNote"] = "At the top of the stairs, look left.\nThe book is on the floor between the two bookshelves."
L["EnchantmentNote"] = "On the balcony. On a\ncrate with nothing upon it.\nNext to a larger crate."
L["IllusionNote"] = "On a crate with nothing upon it.\nIn the corner."
L["NecromancyNote"] = "Upstairs, in the room with four small beds.\nOn the empty bookshelf."
L["TransmutationNote"] = "Downstairs. Look at the pair\nof bookshelves. \nThe book will be in the empty bookshelf."