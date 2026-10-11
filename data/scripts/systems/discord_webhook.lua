-- Sends Discord webhook notifications.
-- The URL layout is https://discord.com/api/webhooks/:id/:token
-- Leave empty if you wish to disable.

if not announcementChannels then
	announcementChannels = {
		["serverAnnouncements"] = "https://discord.com/api/webhooks/1556470729221087252/zGllNAFxj9kPP4HmquOyBGncj7C3Mok3SCqjYDwyIprwpN9h9MCl2g9AwCyzUFkaovWQ", -- Used for an announcement channel on your discord
		["raids"] = "", -- Used to isolate raids on your discord
		["player-kills"] = "", -- Self-explaining
		["player-levels"] = "", -- Self-explaining
		["reports"] = "https://discord.com/api/webhooks/1558692692127518752/W2T-V9vLblX49SZvwW-o7epqzth2AfgxxnLzcOgIEhM7zGlTWktsa1C0iXxaFg7pUsXe",
		["bans"] = "https://discord.com/api/webhooks/1556436478261854309/AfkLsBysNA-Fh-2o4QSQzuWe2I9eHMO_4ENFz5KNxqBEmgy-QcOftbJdGAhcgkw4IFzM", -- Used to isolate bans on your discord
		["other"] = "" -- Used for other stuff that doesn't fit in the other channels
	}
end

--[[
	Example of notification (After you do the config):
	This is going to send a message into your server announcements channel

	local message = blablabla
	local title = test
	Webhook.sendMessage(title, message, WEBHOOK_COLOR_YELLOW,
                        announcementChannels["serverAnnouncements"])

	Dev Comment: This lib can be used to add special webhook channels
	where you are going to send your messages. Webhook.specialSend was designed
	to be used with countless possibilities.
]]
