--[[
	Mod Latent para Minetest
	Latent v0.8-beta Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Funcionalidades basicas
  ]]

dofile(minetest.get_modpath("latent") .. "/diretrizes.lua") -- Carregar Diretrizes.

-- Tempo gasto verificando um IP (em segundos)
local TEMPO_VERIFICANDO = ((PINGS * 3) + 3) 

-- Diretorio do mundo/mapa
local dirmapa = string.gsub(minetest.get_worldpath(), "(% +)", "\\ ")

-- Diretorio do mod
local dirmod = string.gsub(minetest.get_modpath("latent"), "(% +)", "\\ ")

-- Lista de jogadores online
local lista = {}

-- Ler resultado do ping
local function ler_ping(ip, slot)
	local entrada = io.open(minetest.get_worldpath() .. "/latent_ping" .. slot, "r")
	local leitura = tonumber(entrada:read("*l"))
	if leitura ~= nil then
		lista[ip] = leitura -- Escreve o novo valor de ping no ip
		io.close(entrada)
	end
end

-- Pingar um ip
local function pingar(ip, slot)
	if ip then
		os.execute(dirmod.."/pingar.sh "..PINGS.." "..ip.." > "..dirmapa.."/latent_ping"..slot.." &")
		minetest.after(TEMPO_VERIFICANDO, ler_ping, ip, slot)
	end
end


-- Atualizar lista
local function atualizar_lista()
	local slot = 1
	for _, player in ipairs(minetest.get_connected_players()) do
		local ip = minetest.get_player_ip(player:get_player_name())
		pingar(ip, slot)
		slot = slot + 1
	end	
	minetest.after(TEMPO_VERIFICANDO+PAUSA, atualizar_lista)	
end


-- Retira da lista o jogador que sair do servidor
minetest.register_on_leaveplayer(function(player)
	local Nlista = {}
	for _, player in ipairs(minetest.get_connected_players()) do
		local ip = minetest.get_player_ip(player:get_player_name())
		Nlista[ip] = lista[ip] -- Repassa os ips de quem está online
	end	
	lista = Nlista
end)

-- Adiciona na lista o jogador que entrar no servidor
minetest.register_on_joinplayer(function(player)
	lista[minetest.get_player_ip(player:get_player_name())] = tonumber(0)
end)


-- Funcao de concatenar valores
local function explode(sep, input)
        local t={}
        local i=0
        for k in string.gmatch(input,"([^"..sep.."]+)") do 
            t[i]=k
            i=i+1
        end
        return t
end
local function get_max_lag() -- pega o lag do servidor
        local arrayoutput = explode(", ",minetest.get_server_status())
        local arrayoutput = explode("=",arrayoutput[4])
        return arrayoutput[1]
end


-- Funcao de ver players online
function ver_players_online(name)
	local texto = ""
	local name1 = ""
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if texto ~= "" then
			texto = texto..","..name
		else
			texto = name
			name1 = name
		end
		if tonumber(lista[minetest.get_player_ip(name)]) ~= nil then 
			if tonumber(lista[minetest.get_player_ip(name)]) > 1 then 
				texto = texto.." ("..lista[minetest.get_player_ip(name)].."ms)"
			end
		end
	end
	local lag_server = get_max_lag()
	local t = string.split(lag_server, ".")
	lag_server = tonumber(t[1])
	minetest.show_formspec(name, "", "size[7,10]"..
		"bgcolor[#080808BB;true]"..
		"textlist[0,1.5;6.7,6;;"..texto..";0;true]"..
		"image[-0.8,0.6;1,1;latent_players.png]"..
		"label[0,0.5;LAG do Servidor "..lag_server.."ms\nJogadores Online nesse momento]"..
		"button_exit[5,0.5;2,1;;Voltar]"
	)
end

-- Verificar valores criticos de latencia
local function verificar_valores_criticos()
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local ip = minetest.get_player_ip(name)
		if lista[ip] then
			if tonumber(lista[ip]) >= LATENCIA_CRITICA then
				minetest.chat_send_player(name, "[AVISO] Sua conectividade esta muito ruim. Isso Pode afetar severamente a sua jogabilidade")
			end		
		end
	end
	minetest.after(PAUSA_VERIFICAR_VALORES_CRITICOS ,verificar_valores_criticos)
end


dofile(minetest.get_modpath("latent") .. "/comandos.lua") -- Carregar Comandos.

-- Iniciando loops de verificacao
atualizar_lista()
verificar_valores_criticos()
