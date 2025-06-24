package signals

Signal_Payload :: struct($T, $S, $C: typeid) {
	id:     Signal_Id,
	sender: S,
	signal: ^Signal(T, S, C),
	ctx:    C,
	value:  T,
}
