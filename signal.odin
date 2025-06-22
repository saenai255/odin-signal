package signals

Signal_Id :: int

Signal :: struct($C, $S, $T: typeid) {
	listeners: map[int](Signal_Listener(C, S, T)),
	_last_id:  Signal_Id,
}

init_empty :: proc() -> Signal(any, any, any) {
	return init_with_ctx_and_sender_and_value(any, any, any)
}

init_with_sender :: proc($S: typeid) -> Signal(any, S, any) {
	return init_with_ctx_and_sender_and_value(any, S, any)
}

init_with_ctx_and_value :: proc($C, $T: typeid) -> Signal(C, any, T) {
	return init_with_ctx_and_sender_and_value(C, any, T)
}

init_with_ctx_and_sender :: proc($C, $S: typeid) -> Signal(C, S, any) {
	return init_with_ctx_and_sender_and_value(C, S, any)
}

init_with_sender_and_value :: proc($S, $T: typeid) -> Signal(any, S, T) {
	return init_with_ctx_and_sender_and_value(any, S, T)
}

init_with_ctx_and_sender_and_value :: proc($C, $S, $T: typeid) -> Signal(C, S, T) {
	return Signal(C, S, T){listeners = make(map[int]Signal_Listener(C, S, T)), _last_id = 0}
}

init :: proc {
	init_with_sender,
	init_with_sender_and_value,
	init_with_ctx_and_sender_and_value,
}

deinit :: proc(self: ^Signal($C, $S, $T)) {
	delete(self.listeners)
}

emit :: proc(self: ^Signal($C, $S, $T), sender: S, value: T) {
	for _, listener in self.listeners {
		listener.emit_fn(
			Signal_Payload(C, S, T) {
				id = listener.id,
				sender = sender,
				signal = self,
				ctx = listener.ctx,
				value = value,
			},
		)
	}
}

connect :: proc(
	self: ^Signal($C, $S, $T),
	ctx: C,
	fn: proc(payload: Signal_Payload(C, S, T)),
) -> Signal_Id {
	signal_listener := Signal_Listener(C, S, T) {
		ctx     = ctx,
		emit_fn = fn,
		id      = self._last_id + 1,
	}

	self._last_id += 1

	self.listeners[signal_listener.id] = signal_listener

	return signal_listener.id
}

disconnect :: proc(self: ^Signal($C, $S, $T), id: Signal_Id) {
	if id in self.listeners {
		delete_key(&self.listeners, id)
	}
}
