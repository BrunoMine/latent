--[[
	Mod Latent para Minetest
	Latent v0.8-beta Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Comandos
  ]]

-- Abrir lista de jogadores exibindo a latencia no jogo (LAG)
minetest.register_chatcommand("lag", {
	params = "[Nenhum]",
	description = "Mostra uma lista de jogadores online e uma listagem de latencia",
	func = function(name,  param)
		if name then
			ver_players_online(name)
		end
	end
})

-- Comando de verificacao manual de ips
minetest.register_chatcommand("ips", {
	params = "<jogador>",
	description = "Verifica os ips dos jogadores online",
	privs = {server=true},
	func = function(name)
		for _, player in ipairs(minetest.get_connected_players()) do
			local pname = player:get_player_name()
			local ip = minetest.get_player_ip(pname)
			minetest.chat_send_player(name, pname.." ("..ip..")")
		end
	end,
})
