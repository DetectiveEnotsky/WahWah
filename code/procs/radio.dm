/datum/reception
	var/obj/machinery/message_server/message_server = null
	var/telecomms_reception = TELECOMMS_RECEPTION_NONE
	var/message = ""

/datum/receptions
	var/obj/machinery/message_server/message_server = null
	var/sender_reception = TELECOMMS_RECEPTION_NONE
	var/list/receiver_reception = new

/proc/get_message_server(z)
	if(message_servers)
		var/list/zlevels = GLOB.using_map.get_levels_with_trait(ZTRAIT_CONTACT)
		if(z)
			zlevels = GetConnectedZlevels(z)
		for (var/obj/machinery/message_server/MS in message_servers)
			if(MS.active && (MS.z in zlevels))
				return MS
	return null

/proc/check_signal(datum/signal/signal)
	return signal && signal.data["done"]

/proc/get_sender_reception(atom/sender, datum/signal/signal)
	return check_signal(signal) ? TELECOMMS_RECEPTION_SENDER : TELECOMMS_RECEPTION_NONE

/proc/get_receiver_reception(receiver, datum/signal/signal)
	if(receiver && check_signal(signal))
		var/turf/pos = get_turf(receiver)
		if(pos && (pos.z in signal.data["level"]))
			return TELECOMMS_RECEPTION_RECEIVER
	return TELECOMMS_RECEPTION_NONE

/proc/get_reception(atom/sender, receiver, message = "", do_sleep = 1)
	var/datum/reception/reception = new

	// check if telecomms I/O route 1459 is stable
	reception.message_server = get_message_server()

	var/datum/signal/signal = sender.telecomms_process(do_sleep)	// Be aware that this proc calls sleep, to simulate transmition delays
	reception.telecomms_reception |= get_sender_reception(sender, signal)
	reception.telecomms_reception |= get_receiver_reception(receiver, signal)
	reception.message = signal && signal.data["compression"] > 0 ? Gibberish(message, signal.data["compression"] + 50) : message

	return reception

/proc/get_receptions(atom/sender, list/atom/receivers, do_sleep = 1)
	var/datum/receptions/receptions = new
	receptions.message_server = get_message_server()

	var/datum/signal/signal
	if(sender)
		signal = sender.telecomms_process(do_sleep)
		receptions.sender_reception = get_sender_reception(sender, signal)

	for(var/atom/receiver in receivers)
		if(!signal)
			signal = receiver.telecomms_process()
		receptions.receiver_reception[receiver] = get_receiver_reception(receiver, signal)

	return receptions
