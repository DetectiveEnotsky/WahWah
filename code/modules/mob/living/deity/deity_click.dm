/mob/living/deity/ClickOn(atom/A, params)
	if(A == src)
		if(form)
			open_menu()
		else
			choose_form()
		return
	var/list/modifiers = params2list(params)
	if(modifiers["shift"] || modifiers["ctrl"])
		return
	if(current_boon && is_follower(A))
		grant_boon(A)
	else if(istype(A, /obj/structure/deity))
		var/obj/structure/deity/D = A
		if(D.linked_god == src)
			D.attack_deity(src)
			return
	..()
