package signals

Signal_Payload :: struct($T, $C, $S: typeid) {
	id:     Signal_Id,
	sender: S,
	signal: ^Signal(T, C, S),
	ctx:    C,
	value:  T,
}
