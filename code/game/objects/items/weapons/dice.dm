/obj/item/weapon/dice
	name = "d6"
	desc = "A die with six sides. Basic and servicable."
	icon = 'icons/obj/dice.dmi'
	icon_state = "d6"
	w_class = 1
	var/sides = 6
	var/result = null
	var/is_magic = 0
	var/mob/living/victim

/obj/item/weapon/dice/New()
	result = rand(1, sides)
	update_icon()


/obj/item/weapon/dice/d1
	name = "d1"
	desc = "A die with one side. Deterministic!"
	icon_state = "d1"
	sides = 1

/obj/item/weapon/dice/d2
	name = "d2"
	desc = "A die with two sides. Coins are undignified!"
	icon_state = "d2"
	sides = 2

/obj/item/weapon/dice/d4
	name = "d4"
	desc = "A die with four sides. The nerd's caltrop."
	icon_state = "d4"
	sides = 4

/obj/item/weapon/dice/d8
	name = "d8"
	desc = "A die with eight sides. It feels... lucky."
	icon_state = "d8"
	sides = 8

/obj/item/weapon/dice/d10
	name = "d10"
	desc = "A die with ten sides. Useful for percentages."
	icon_state = "d10"
	sides = 10

/obj/item/weapon/dice/d00
	name = "d00"
	desc = "A die with ten sides. Works better for d100 rolls than a golfball."
	icon_state = "d00"
	sides = 10

/obj/item/weapon/dice/d12
	name = "d12"
	desc = "A die with twelve sides. There's an air of neglect about it."
	icon_state = "d12"
	sides = 12

/obj/item/weapon/dice/d20
	name = "d20"
	desc = "A die with twenty sides. The prefered die to throw at the GM."
	icon_state = "d20"
	sides = 20

/obj/item/weapon/dice/d100
	name = "d100"
	desc = "A die with one hundred sides! Probably not fairly weighted..."
	icon_state = "d100"
	sides = 100

/obj/item/weapon/dice/attack_self(mob/user as mob)
	diceroll(user)

/obj/item/weapon/dice/throw_at(atom/target, range, speed, mob/user as mob)
	if(!..())
		return
	if(!throwing && !victim && get_turf(target) == get_turf(src) && isliving(target))
		victim = target
	diceroll(user)


/obj/item/weapon/dice/throw_impact(atom/hit_atom,mob/thrower)
	if(!victim && isliving(hit_atom))
		victim = hit_atom
	..()

/obj/item/weapon/dice/proc/diceroll(mob/user as mob)
	result = rand(1, sides)
	var/comment = ""
	if(sides == 20 && result == 20)
		comment = "Nat 20!"
	else if(sides == 20 && result == 1)
		comment = "Ouch, bad luck."
	update_icon()
	if(initial(icon_state) == "d00")
		result = (result - 1)*10
	if(user != null) //Dice was rolled in someone's hand
		user.visible_message("[user] has thrown [src]. It lands on [result]. [comment]", \
							 "<span class='notice'>You throw [src]. It lands on [result]. [comment]</span>", \
							 "<span class='italics'>You hear [src] rolling.</span>")
	else if(src.throwing == 0) //Dice was thrown and is coming to rest
		visible_message("<span class='notice'>[src] rolls to a stop, landing on [result]. [comment]</span>")
	if(is_magic)
		cause_shenanigans(user,victim)
	victim = null

/obj/item/weapon/dice/d4/Crossed(var/mob/living/carbon/human/H)
	if(istype(H) && !H.shoes)
		if(PIERCEIMMUNE in H.dna.species.specflags)
			return 0
		H << "<span class='userdanger'>You step on the D4!</span>"
		H.apply_damage(4,BRUTE,(pick("l_leg", "r_leg")))
		H.Weaken(3)

/obj/item/weapon/dice/update_icon()
	overlays.Cut()
	if(sides == 100)
		return
	overlays += "[src.icon_state][src.result]"


//!!-THE MAGIC STARTS HERE-!!//

/obj/item/weapon/dice/proc/cause_shenanigans(mob/user as mob) //Grab bag of problems. This is the D6.
	if(!victim)
		return

/obj/item/weapon/dice/d1/cause_shenanigans(mob/user as mob) //Bread and butter armor ignoring damage.
	if(!victim)
		return
	victim.apply_damage(20, BRUTE)
	playsound(get_turf(src),"sound/weapons/genhit1.ogg",20,1)
	add_logs(user, victim, "caused [result] damage", 0, src)

/obj/item/weapon/dice/d2/cause_shenanigans(mob/user as mob) //Life and death, all or nothing
	if(!victim)
		return
	if(result == 1)
		victim.revive()
		victim.visible_message("<span class='notice'>[src] glows, and [victim] suddenly looks healthy!</span>")
		playsound(get_turf(src),"sound/magic/Staff_Healing.ogg",50,1)
		add_logs(user, victim, "inadvertantly healed", 0, src)
	else
		if(victim.stat == DEAD)
			return
		victim.death(0)
		victim.visible_message("<span class='warning'>[src] glows, and [victim] suddenly falls over, dead!</span>")
		playsound(get_turf(src),"sound/magic/wandodeath.ogg",50,1)
		add_logs(user, victim, "instantly slayed", 0, src)

/obj/item/weapon/dice/d4/cause_shenanigans(mob/user as mob) //impedance, slowing people down, has effects even without victims
	switch(result)
		if(1)
			for(var/turf/T in orange(3, get_turf(src)))
				if(!T.density)
					new /obj/effect/spider/stickyweb(T)
			playsound(get_turf(src),"sound/effects/zzzt.ogg",30,1)
		if(2)
			new/obj/effect/spacevine_controller(get_turf(src))
			playsound(get_turf(src),"sound/magic/SummonItems_generic.ogg",40,1)
		if(3)
			for(var/turf/T in orange(2, get_turf(src)))
				if(!T.density)
					var/obj/item/weapon/grown/bananapeel/oh_banana
					var/honk = pick("HONK", "...")
					if(honk == "HONK")
						oh_banana = new /obj/item/weapon/grown/bananapeel(T)
					else
						oh_banana = new /obj/item/weapon/grown/bananapeel/mimanapeel(T)
					oh_banana.potency = pick(1,10,20,30,40,50)
			playsound(get_turf(src),"sound/spookoween/scary_horn2.ogg",50,1)

		if(4)
			var/obj/effect/timestop/T = new /obj/effect/timestop
			T.loc = get_turf(src)
			T.immune = user
			T.timestop()

/obj/item/weapon/dice/d8/cause_shenanigans(mob/user as mob) //Prismatic spray, the die
/*	if(!victim)
		return
	switch(result)
		if(1) //20 points fire damage (Reflex half)
			if(prob(80))
				victim.apply_damage(20, BURN)
				victim.IgniteMob()
			else
				victim.apply_damage(10, BURN)
		if(2) //40 points acid damage (Reflex half)
		if(3) //80 points electricity damage (Reflex half)
			if(prob(80))
				victim.electrocute_act(80,"Shocking Die")
			else
				victim.apply_damage(40, BURN)
		if(4) //Poison (Kills; Fortitude partial, take 1d6 points of Con damage instead)

		if(5) //Turned to stone (Fortitude negates)
			if(prob(80))
				new /obj/structure/closet/statue(get_turf(victim),victim)
			else

		if(6) //Insane, as insanity spell (Will negates)
		if(7) //Sent to another plane (Will negates)
		if(8) //Struck by two rays; roll twice more, ignoring any “8” results.
	*/

/obj/item/weapon/dice/d10/cause_shenanigans(mob/user as mob) //An extended joke relating to a certain extremely shallow character

/obj/item/weapon/dice/d12/cause_shenanigans(mob/user as mob) //Summon Items, doesn't need a target, most are pretty useless
	switch(result)
		if(1)	new /obj/item/weapon/bikehorn(get_turf(src))
		if(2)	new /obj/item/weapon/sord(get_turf(src))
		if(3)	new /obj/item/weapon/coin/antagtoken(get_turf(src))
		if(4)	new /obj/item/weapon/grenade/chem_grenade/colorful(get_turf(src))
		if(5)	new /obj/item/weapon/reagent_containers/food/snacks/burger/spell(get_turf(src))
		if(6)	new /obj/item/weapon/greentext(get_turf(src))
		if(7)	new /obj/item/weapon/throwing_star(get_turf(src)) //just the one
		if(8)	new /obj/item/weapon/scythe(get_turf(src))
		if(9)	new /obj/item/weapon/storage/belt/champion/wrestling(get_turf(src))
		if(10)	new /obj/item/weapon/veilrender/honkrender(get_turf(src))
		if(11)	new /obj/item/weapon/katana(get_turf(src))
		if(12)	new /obj/item/weapon/twohanded/mjollnir/(get_turf(src))

	var/datum/effect/effect/system/smoke_spread/smoke = new
	smoke.set_up(max(1,1), 0, get_turf(src))
	smoke.start()
	if(result == 10)
		playsound(get_turf(src),"sound/spookoween/scary_clown_appear.ogg",50,1)
	if(result == 12)
		playsound(get_turf(src),"sound/magic/lightningbolt.ogg",50,1)
	else
		playsound(get_turf(src),"sound/magic/SummonItems_generic.ogg",50,1)

/obj/item/weapon/dice/d20/cause_shenanigans(mob/user as mob) //Summon Monster, doesn't need a target, monsters aren't wizard friendly
	switch(result)
		if(1)	new /mob/living/simple_animal/mouse(get_turf(src))
		if(2)	new /mob/living/simple_animal/chicken(get_turf(src))
		if(3)	new /mob/living/simple_animal/pet/corgi/puppy(get_turf(src))
		if(4)	new /mob/living/simple_animal/pet/cat/kitten(get_turf(src))
		if(5)	new /mob/living/simple_animal/cow(get_turf(src))
		if(6)	new /mob/living/simple_animal/parrot(get_turf(src))
		if(7)	new /mob/living/simple_animal/hostile/blob/blobspore(get_turf(src))
		if(8)	new /mob/living/simple_animal/hostile/headcrab(get_turf(src))
		if(9)	new /mob/living/simple_animal/hostile/hivebot/range(get_turf(src))
		if(10)	new /mob/living/simple_animal/hostile/viscerator(get_turf(src))
		if(11)	new /mob/living/simple_animal/hostile/bear(get_turf(src))
		if(12)	new /mob/living/simple_animal/hostile/carp(get_turf(src))
		if(13)	new /mob/living/simple_animal/hostile/faithless(get_turf(src))
		if(14)	new /mob/living/simple_animal/hostile/creature(get_turf(src))
		if(15)	new /mob/living/simple_animal/hostile/poison/giant_spider(get_turf(src))
		if(16)	new /mob/living/simple_animal/hostile/hivebot/strong(get_turf(src))
		if(17)	new /mob/living/simple_animal/hostile/blob/blobbernaut(get_turf(src))
		if(18)	new /mob/living/simple_animal/hostile/carp/megacarp(get_turf(src))
		if(19)	new /mob/living/simple_animal/hostile/statue(get_turf(src))
		if(20)	new /mob/living/simple_animal/hostile/carp/ranged(get_turf(src))
	var/datum/effect/effect/system/smoke_spread/smoke = new
	smoke.set_up(max(1,1), 0, get_turf(src))
	smoke.start()
	if(result < 7)
		playsound(get_turf(src),"sound/magic/SummonItems_generic.ogg",50,1)
	else
		playsound(get_turf(src),"sound/magic/Summon_Karp.ogg",50,1)

/obj/item/weapon/dice/d00/cause_shenanigans(mob/user as mob) //Hardset health in a radius

/obj/item/weapon/dice/d100/cause_shenanigans(mob/user as mob) //Highly variable damage with vague chance of d2
	if(!victim)
		return
	var/damage_type
	//looks stupid, but saves calculations
	var/list/primes = list(2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97)
	var/list/mult2	= list(4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98)
	var/list/mult3	= list(9,15,21,27,33,39,45,51,57,63,69,75,81,87,93,99)
	var/list/mult5  = list(25,35,55,65,85,95)
	if(result == 1) //WHOOPS
		victim.revive()
		victim.visible_message("<span class='notice'>[src] glows, and [victim] suddenly looks healthy!</span>")
		add_logs(user, victim, "inadvertantly healed", 0, src)
		playsound(get_turf(src),"sound/effects/pray.ogg",50,1)
		return
	if(result == 100)
		victim.death(0)
		victim.visible_message("<span class='warning'>[src] glows, and [victim] suddenly falls over, dead!</span>")
		add_logs(user, victim, "instantly slayed", 0, src)
		playsound(get_turf(src),"sound/magic/wandodeath.ogg",50,1)
		return
	if(result in primes)
		damage_type = BURN
		playsound(get_turf(src),"sound/items/welder2.ogg",result/2,1)
	if(!damage_type && result in mult2)
		damage_type = BRUTE
		playsound(get_turf(src),"sound/weapons/genhit1.ogg",result/2,1)
	if(!damage_type && result in mult3)
		damage_type = TOX
		playsound(get_turf(src),"sound/effects/attackblob.ogg",result/2,1)
	if(!damage_type && result in mult5)
		damage_type = OXY
		playsound(get_turf(src),"sound/effects/splat.ogg",result/2,1)
	if(!damage_type) //mult7: 49, 77, 91
		damage_type = CLONE
		playsound(get_turf(src),"sound/effects/EMPluse.ogg",result/2,1)

	victim.apply_damage(result, damage_type) //Practical odds: 48% Brute, 25% Burn, 16% Toxin, 6% Oxygen, 3% Clone, 1% Instant Death, 1% Fully Healed
	victim.visible_message("<span class='warning'>[src] glows, and [victim] grimaces.</span>")
	add_logs(user, victim, "caused [result] damage", 0, src)