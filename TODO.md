# Need to
 1. Setup navic
 2. Register default highlights
 3. Reorder, rethink and redo the config
 	- Add an option to override navic icons
	- file_section and navic_section the same type
	- highlights separate section?
	- better highlighting option
 5. Add these options:
	- file_section/location_section.position = 'right' | 'left' | 'centered' (note: the separator will only be available if both sections have the same position, file_section is 'left' by default, location_section is 'left' by default)
	- file_section/location_section.reverse = true/false

# Soon

# Docs
 1. Vim docs
 2. Move the config description from the codeblock to a separate section in markdown
 3. Move the config to a separate file since it's gonna be huge

# Planned
 1. Clickable and hoverable breadcrumbs (when shortened it should show the full folder, etc., for shoretened breadcrums an option to mkake them full for a second (`:toogle_short()`?))
 2. Add option to make sections 'bubbly' (like lualines bubble theme)
 3. Add option to make sections 'captured' (like the dots from the one guy)
