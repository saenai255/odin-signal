package signals

Signal_Listener :: struct($C, $S, $T: typeid) {
	emit_fn: proc(payload: Signal_Payload(C, S, T)),
	ctx:     C,
	id:      Signal_Id,
}
