--- Window filter essentially asks a question 'should this buffer be excluded', which means - if it returns true, the buffer is excluded from the epic headband team B)
---@alias WinFilterFunc fun(bid: number, bname: string, bt: string, ft: string, prev: boolean): boolean

--- A function for displaying text on the buffer
---@alias WinTextFunc fun(bid: number, bname: string, bt: string, ft: string): string


--- A function that returns two string values wrapping a section
---@alias WrapFunction fun(bid: number, bname: string, bt:string, ft:string): string, string

---@class UserConfig The configuration table user is meant to pass to setup
---@field public enable boolean Whether to enable the winbar
---@field public general_separator string Separator between the file section and navic section, if both are present, can be disabled by setting it to ''
---@field public unsaved_buffer_text string | WinTextFunc The text to display for an unsaved buffer, can be @WinTextFunc
---@field public window_filter WinFilterFunc A function that filters buffers out (buffers for which it will return false won't have winbar enabled)
--
---@field public file_section UserConfig.FileSection Configuration for the file section of the winbar
---@field public location_section UserConfig.LocationSection Configuration for the navic section of the winbar

---@class UserConfig.FileSection
---@field public enable boolean Whether to enable or disable the file section
---@field public text string | WinTextFunc Style of the file section can be 'filename' | 'shortened' | 'shortened_lower' | 'full' | 'full_lower or a @WinTextFunc that will return the text
---@field public bold_filename boolean Whether set the NvimHeadbandFilename hl group as bold
---@field public wrap string[] | WrapFunction | nil Can be a list of two strings, a @WrapFunction that returns two strings or a nil
--
---@field public devicons UserConfig.FileSection.DevIcons Configuration for the file section's devicons

---@class UserConfig.FileSection.DevIcons
---@field public enable boolean Whether to enable devicons in front of the filename
---@field public highlight boolean Whether to enable devicons highlighting

---@class UserConfig.LocationSection
---@field public enable boolean Whether to enable the navic section
---@field public depth_limit number The depth limit of the navic symbols, 0 means none
---@field public depth_limit_indicator string The depth limit indicator that is used when the limit is reached
---@field public wrap string[] | WrapFunction | nil Can be a list of two strings, a @WrapFunction that returns two strings or a nil
--
---@field public empty_symbol UserConfig.LocationSection.EmptySymbol Configuration for the empty navic symbol
---@field public separator UserConfig.LocationSection.Separator Configuration for the separator between the navic elements
---@field public icons UserConfig.LocationSection.Icons Configuration for navic icons

---@class UserConfig.LocationSection.EmptySymbol
---@field public symbol string The symbol that will be displayed when navic is available but the location is empty, can be disabled by setting it to ''
---@field public highlight boolean Whether to highlight the empty location symbol

---@class UserConfig.LocationSection.Separator
---@field public symbol string The symbol to use for a navic separator
---@field public highlight boolean Whether to register the default highlight group for the separator

---@class UserConfig.LocationSection.Icons
---@field public default_icons boolean Whether to enable the default navic icons
---@field public highlights string How to highlight the default navic groups, the valid options are 'none' | 'link'| 'default'
