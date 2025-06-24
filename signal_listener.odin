package signals

Signal_Listener :: struct($T, $C, $S: typeid) {
	emit_fn: proc(payload: Signal_Payload(T, C, S)),
	ctx:     C,
	id:      Signal_Id,
}
