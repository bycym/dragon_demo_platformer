pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	player={}
	player.x=16
	player.y=40
  player.jump=2.5
  player.ax=0
  player.ay=0
  player.acc=0.3
  player.frict=0.25
  player.mx_spd=4
  player.facing=0
  player.grounded=1
	player.flowers=9
	player.spr=3
	player.life=5
	player.maxlife=3
	player.invc=30 --frames
	player.win=0

  global={}
  global.gravity=0.1
	global.camera_buffer=28
	global.tick = 0
	global.debug = 0

	cam={
		x=0,
		y=0,
		speed=4
	}
	enemies = {}

	knight_1={
		x=110,
		y=40,
		defspeed=1,
		speed=1,
		ay=0,
		spr=12,
		type=0,
		animspeed = 6
	}
	knight_2={
		x=80,
		y=136,
		defspeed=1,
		speed=1,
		ay=0,
		spr=12,
		type=0,
		animspeed = 6
	}
	knight_3={
		x=160,
		y=144,
		defspeed=1,
		speed=1,
		ay=0,
		spr=12,
		type=0,
		animspeed = 6
	}
	spearman_1 = {
		x=32,
		y=88,
		defspeed=1,
		speed=0.5,
		ay=0,
		spr=14,
		type=1,
		animspeed = 6
	}
	spearman_2 = {
		x=96,
		y=88,
		defspeed=1,
		speed=0.5,
		ay=0,
		spr=14,
		type=1,
		animspeed = 6
	}
	spearman_3 = {
		x=216,
		y=24,
		defspeed=1,
		speed=0.5,
		ay=0,
		spr=14,
		type=1,
		animspeed = 6
	}
	spearman_4 = {
		x=304,
		y=56,
		defspeed=1,
		speed=0.5,
		ay=0,
		spr=14,
		type=1,
		animspeed = 6
	}

	add(enemies,knight_1)
	add(enemies,knight_2)
	add(enemies,knight_3)
	add(enemies,spearman_1)
	add(enemies,spearman_2)
	add(enemies,spearman_3)
	add(enemies,spearman_4)



end

function check_princess(x,y,w,h)
	enough=false
	near=false
  for i=x,x+w,w do
    if (fget(mget(i/8,y/8))==4) then
			near=true
			if (player.flowers == 12) enough = true
		end
		if (fget(mget(i/8,(y+h)/8))==4) then
			near=true
      if (player.flowers == 12) enough = true
    end
  end

  for i=y,y+h,h do
    if (fget(mget(x/8,i/8),0)==4) then
			near=true
			if (player.flowers == 12) enough = true
		end
	  if (fget(mget((x+w)/8,i/8),0)==4) then
			near=true
    	if (player.flowers == 12) enough = true
    end
  end

	if enough and near then
		global.debug = true
		print('you brought me all\n the flowers.\n thanks!', player.x-20, player.y - 40, 14)
		player.win = 1
		--sfx(3)
	elseif near then
		print('find me all the flowers', player.x-40, player.y - 20, 14)
	end
end

function check_pickup(x,y,w,h)
	pickup=false
  for i=x,x+w,w do
    if (fget(mget(i/8,y/8))==2) then
			pickup = true
			mset(i/8,y/8,0)
		end
		if (fget(mget(i/8,(y+h)/8))==2) then
      pickup=true
			mset(i/8,(y+h)/8,0)
    end
  end

  for i=y,y+h,h do
    if (fget(mget(x/8,i/8),0)==2) then
			pickup = true
			mset(x/8,i/8,0)
		end
	  if (fget(mget((x+w)/8,i/8),0)==2) then
      pickup=true
			mset(x/8,i/8,0)
    end
  end
	return pickup
end

function check_collision(x,y,w,h)
  collide=false
  for i=x,x+w,w do
    if (fget(mget(i/8,y/8))==1) or
         (fget(mget(i/8,(y+h)/8))==1) then
          collide=true
    end
  end

  for i=y,y+h,h do
    if (fget(mget(x/8,i/8),0)==1) or
         (fget(mget((x+w)/8,i/8),0)==1) then
          collide=true
    end
  end
  return collide
end

function animate(object,starting_frame,number_of_frames,speed,ticks)
	if(not object.a_ct) object.a_ct=0
	if(not object.a_st)	object.a_st=0

	object.a_ct+=1

	if(object.a_ct%(30/speed)==0) then
	 object.a_st+=1
	 if(object.a_st==number_of_frames) object.a_st=0
	end

	object.a_fr=starting_frame+object.a_st
	spr(object.a_fr,object.x,object.y,1,1,ticks)
end

function move_camera()
	if (player.x - cam.x <= (64 + global.camera_buffer)) then
		cam.x -= cam.speed
	elseif (player.x - cam.x > (64 - global.camera_buffer)) then
		cam.x += cam.speed
	end
end

function vertical_collision(x,y,w,h)
	collide=false
	for i=x,x+w,w do
		if (fget(mget(i/8,y/8))==1) or
				 (fget(mget(i/8,(y+h)/8))==1) then
					collide=true
		end
	end
	return collide
end

function horizontal_collision(x,y,w,h)
	collide = false
	for i=y,y+h,h do
		if (fget(mget(x/8,i/8),0)==1) or
				 (fget(mget((x+w)/8,i/8),0)==1) then
					collide=true
		end
	end
	return collide
end

function move_enemy(object,w,h)
	next_wall = 0
	next_floor = 0
-- type 0
	if object.type == 0 then

		if object.speed > 0 then
			next_wall = mget(object.x/8+(1*sgn(object.speed)),object.y/8)
		end

		if object.speed < 0 then
			next_wall = mget(ceil(object.x/8)+(1*sgn(object.speed)),object.y/8)
		end

		if(fget(next_wall)==1) then
			object.speed = object.speed * (-1)
		end

		next_floor = mget(flr(object.x/8),(object.y/8)+1)
		if fget(next_floor,0) == false then
			object.ay += global.gravity
		else
			object.ay = 0
		end
	end
-- type 1
	if object.type == 1 then
		if object.speed > 0 then
			next_floor = mget(object.x/8+(1*sgn(object.speed)),object.y/8+1)
		end

		if object.speed < 0 then
			next_floor = mget(ceil(object.x/8)+(1*sgn(object.speed)),object.y/8+1)
		end

		if(fget(next_floor) == 0) then
			object.speed = object.speed * (-1)
		end

		if object.speed > 0 then
			next_wall = mget(object.x/8+(1*sgn(object.speed)),object.y/8)
		end

		if object.speed < 0 then
			next_wall = mget(ceil(object.x/8)+(1*sgn(object.speed)),object.y/8)
		end

		if(fget(next_wall)==1) then
			object.speed = object.speed * (-1)
		end

		next_wall = mget(flr(object.x/8),flr((object.y+object.ay)/8)+1)
		if(fget(next_wall,0) == 0) then
			object.ay += global.gravity
		else
			object.ay = 0
		end

	end
	object.x += object.speed
	object.y += object.ay
	if (object.speed < 0) animate(object,object.spr,2,object.animspeed,true)
	if (object.speed > 0) animate(object,object.spr,2,object.animspeed,false)
end

function switch_skin()
	if btnp(4)  and (player.spr == 1) then
			player.spr = 3
	elseif btnp(4) and (player.spr == 3) then
			player.spr = 1
	end
end

function control_player()
	if(btn(0)) and (player.ax < player.mx_spd and player.ax > -player.mx_spd) then
		player.ax-=player.acc
    player.facing=0
    animate(player,player.spr,2,6,true)
	elseif(btn(1)) and (player.ax < player.mx_spd and player.ax > -player.mx_spd) then
		player.ax+=player.acc
    player.facing=1
    animate(player,player.spr,2,6,false)
	else
    if(player.facing == 1) then
      spr(player.spr,player.x,player.y)
    else
      spr(player.spr,player.x,player.y,1,1,true,false)
    end
  end
  if btn(2) and player.grounded == 1 then
		sfx(0)
		player.ay -= player.jump
		player.grounded = 0
	end

  if player.ax > 0 then
 		player.ax -= player.frict
     if(player.ax < 0) player.ax=0
 	end
 	if player.ax < 0 then
 		player.ax += player.frict
     if(player.ax > 0) player.ax=0
 	end

  if(grounded) then
    player.ay =0.0
  else
    player.ay += global.gravity
  end

  if check_collision(player.x+player.ax,player.y,7,7) then
    player.ax =0
  end
  if check_collision(player.x,player.y+player.ay,7,7) then
    if player.ay > 0 then
      player.grounded = 1;
    end
    player.ay =0
  end

  player.x += player.ax
  player.y += player.ay

	if (check_pickup(player.x,player.y,7,7)) then
		sfx(1)
		player.flowers+=1
	end
	if (check_pickup(player.x,player.y,7,7)) then
		sfx(1)
		player.flowers+=1
	end
		switch_skin()
		check_princess(player.x,player.y,7,7)
end

function control_enemies()
	for monster in all(enemies) do
		move_enemy(monster,7,7)
	end
end

function player_enemy_collision()
	for monster in all(enemies) do
		if( (flr(monster.x/8) == flr(player.x/8)) and (flr(monster.y) == flr(player.y))
			and global.tick > player.invc) then

			player.life -= 1
			global.tick = 0
		end
	end
end


function _update()
	if player.life > 0 then
		if player.win == 0 then
		global.tick += 1
		if(global.tick > 1200) global.tick = 0
			cls()
		  map()
		  control_player()
			control_enemies()
			player_enemy_collision()
		else
			print("YOU WON!",player.x-20, player.y + 20,12)
			print("Press '\142' to restart",player.x-40, player.y + 28,12)
			if(btn(4)) _init()
		end
	else
		cls()
		print("GAME OVER",player.x-4,player.y,8)
		print("PRESS '\151' to continue",player.x-30,player.y+8,8)
		if(btn(5)) _init()
	end
end

function set_ui()
	ui={
		flowers = player.flowers,
		life = player.life
	}
	draw_ui(ui)
end

function draw_ui(object)
	index = 1
	for k,v in pairs(object) do
  	print(k.." = "..v,player.x-60,player.y-50+(index*6),10)
		index+=1
	end

end

function _draw()
	camera(player.x-60,player.y-60)
	set_ui()
	print(player.life,player.x-60,player.y-60,10)
	rectfill(player.x-100,player.y-60,player.x+100,player.y-50,7)
	rectfill(player.x-100,player.y-60,player.x+100,player.y-52,0)
	for i=1,player.maxlife do
		spr(63,player.x+20+(i*10),player.y-60,1,1)
	end
	for i=1,player.life do
		spr(62,player.x+20+(i*10),player.y-60,1,1)
	end
	spr(32,player.x-60,player.y-60,1,1)
	print(": "..player.flowers,player.x-52,player.y-57,7)
	--print(stat(1),player.x-60,player.y-52,10)
	--print(stat(7),player.x-60,player.y-44,10)
end


__gfx__
00000000009d1d00009d1d0000b5150000b5150000ce8e0000ce8e00244444444444444400000000000000000000000000000666555556660000006055555060
0000000009d0dddd09d0dddd0b5055550b5055550ce0eeee0ce0eeee4444444444444442000000000000000000000000555550665f8f8066555550605f8f8060
007007000077dddd0077dddd00775555007755550077eeee0077eeee44444444444444200000000000000000000000005f8f80604ffff0605f8f80402ffff040
000770000977dddd0977dddd0b7755550b7755550c77eeee0c77eeee24444444444444000000000000000000000000004ffff0604ffff0602ffff0402ffff040
00077000009677700096777000b5777000b5777000ce777000c67770044444444444440000000000000000000000000055655ff055655ff055955f4055955f40
0070070019116610019116101b11665001b116108c88668008c88680044444444444449000000000000000000000000054245040542450406642504026625040
0000000001d16611011d1610015166550115161008e86688088e8680944444444444444900000000000000000000000044444000444440006622204056622040
00000000009904400009940000bb0330000bb30000cc0dd0000ccd00444444444444444400000000000000000000000050006000050600005006004005060040
0bbbbbbbbbbbbbbb0000000000000000000000000000000003003030444444444444444400000000000000000000000000000000000000000000000000000000
bbbbbbbb3bbbbbb300000000000bb000000000000000000003003b30444444444444442200000000000000000000000000000000000000000000000000000000
33333333333333330007000000bb3b000000000000000000003b0b00244444444444440000000000000000000000000000000000000000000000000000000000
444433444444334400b77000003b33000000000000000000003b0300024444444444449000000000000000000000000000000000000000000000000000000000
44443444444434440077600000333b0000000000000000000b003030004444444444444000000000000000000000000000000000000000000000000000000000
0444444444444444077763000033b30000000000000000000b003030094444444444444900000000000000000000000000000000000000000000000000000000
004400444044004407b6660000344b00000b0000000b000000030300044444444444444400000000000000000000000000000000000000000000000000000000
000000000000000000663000000440000b0b0b00000b0b00000b0b00944444444444444400000000000000000000000000000000000000000000000000000000
0000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb444444bbbbbbbbbbbb0000000000000000000000000000000000000000000000000
0000000000000000bbb0bbb03bb3bb3b3bb3bb3b33b333333bb33b3b3bb33b4444b33bbbbbb33bbb000000000000000000000000000000000000000000000000
0000000000000000bb30b330333333333333333333333333333bbb33333bbb44443bbb33bb3bbb33000000000000000000000000000000000000000000000000
0008000000000000b330b3b32233332222333322223322223333b3323333b3444433b3223333b322000000000000000000000000000000000000000000000000
008a8000000000000240b33344222244442222444422444422233324222334444423324422233244000000000000000000000000000000000000000000000000
00080000000000000bb3002324444444f44444444444444444422244444224444442244444422442000000000000000000000000000000000000000000000000
0003b000000060000b3b3b40244224f4444444f44444444444444444444444444444444444444442000000000000000000000000000000000000000000000000
00030000060655000032423002200222444444444444444444444444444444444444444422222220000000000000000000000000000000000000000000000000
000000000000000000024000bbbbbbbb44444444444444444444444400bbbbbbbbbbbbb044444444444444440000000000000000000000000000000000000000
0000000000000000000240003bb3bb3b444444444444444444444444bb33bb3b3b33bb3b44494444444444440000000000000000000000000077077000770770
00000000000000000002440033333333244444444444444444444442b3333333b333333344909444444444440000000000000000000000000788788707667667
00090000000000000000240022333322024444444444444444444420223333222233332249000244444444440000000000000000000000000788888707666667
009a9000000000000004440044222244244444444444444444444420242222444422224249000244444444440000000000000000000000000078887000766670
00090000000060000002440044444444244444444444444444444442024444444444444244202444444444440000000000000000000000000078887000766670
00b3b0000066550000024400442224f4024224444222222442222442244444444444442044424444444444440000000000000000000000000007870000076700
00030000066555500024444042000222002002222000000220000220244444444444442044444444444444440000000000000000000000000000700000007000
__gff__
0000000000040001010000000000000001000000000000010100000000000000020000010101010101010000000000000200000101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
393535353535353535353535353535353535393a3535353535353535353535353535353535393a353535353535353a080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0800000000000000000000000000000000001708000000000000000000000000000000000017180000000000000017080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000000000001708000000000000220000000000000000000017180000000000000017080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000000000001708000000000000320015000000000000000017360005150000000017080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0800220000000000000000000000000000001708000000002137262426380015000000000034233333332900000017080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800321520140000000000372438000030001708000000372426273a28262624380000000000000000001600000017080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2825242525263800000037273a28252524252708000037273535353535353535360000000000220000000000211417080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3935353535353600000034353535353535353908212017180000000000000000000000000014320000000023333327080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0800000000000000000000000000000000001728252527360000000000000015312013003724242638000014213017080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08000000000000000000000000000000002017393a3a1800000000000023333325262526273a3a3a28252425262427080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
180000000000140000003000000000000023273a3a3918000000000000001600173935353535353535353535353535360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
080000150000372626243800151413000000173a3a3a18001500000000000000171800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
180000232525273a393a282525252900000017393a3928333329000000000000171800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0800000034353535353535353536000000003435353536000016000000131420170800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000030001300000000001600000000000000000000233333270800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2829000000000000002333332900000022000000000000000000220000000000171800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0821201513001500000016000000140032150000000014151415320000000000170800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2825262524262538000000311537252626262900000023333333332900000000170800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a393a3a3a3a3a28252625262525273a3a180013150020160031003000141500171800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a3a3a3a3a3a393a3a3a3a3535353a3a39282625262526242525242626252526260800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3535353535353535353536000000343535353535363435353634353535353535353600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001d350213502535027350273502635022350203501b350173501235009350033500135037300373003530033300313002f3002c3002b3002830022300193000e3000a3000830002300023001f00019000
0007000026050140002c050310502f00033000170000e7000e0000e700030000e7002f0000e700170000e7000e0000e700030000e7002f0000e700170000e7000e0000e700030000e7002f0000e700170000e700
00080000270502c050340502c05030050360503d70020700367003570000700007003370000700397000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0008000026050290502905026050220501f0501d0501f05024050280502c0503305037050330503f000221002110025100261001700017000190001b0001d0003410021000210002000035100000000000000000
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41434344

