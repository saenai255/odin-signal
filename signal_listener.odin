package signals

Signal_Listener :: struct($T, $S, $C: typeid) {
	emit_fn: proc(payload: Signal_Payload(T, S, C)),
	ctx:     C,
	id:      Signal_Id,
}
