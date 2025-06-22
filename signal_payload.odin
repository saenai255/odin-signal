package signals

Signal_Payload :: struct($C, $S, $T: typeid) {
	id:     Signal_Id,
	sender: S,
	signal: ^Signal(C, S, T),
	ctx:    C,
	value:  T,
}
