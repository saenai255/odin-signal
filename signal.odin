package signals

import "core:fmt"

Signal_Id :: int

Signal :: struct($T, $C, $S: typeid) {
	listeners: map[int](Signal_Listener(T, C, S)),
	_last_id:  Signal_Id,
}


init :: proc($T, $C, $S: typeid) -> ^Signal(T, C, S) {
	self := new(Signal(T, C, S))
	self.listeners = make(map[Signal_Id]Signal_Listener(T, C, S))
	self._last_id = 0
	return self
}

deinit :: proc(self: ^Signal($T, $C, $S)) {
	delete(self.listeners)
	free(self)
}

emit :: proc(self: ^Signal($T, $C, $S), sender: S, value: T) {
	for _, listener in self.listeners {
		listener.emit_fn(
			Signal_Payload(T, C, S) {
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
	self: ^Signal($T, $C, $S),
	ctx: C,
	fn: proc(payload: Signal_Payload(T, C, S)),
) -> Signal_Id {
	signal_listener := Signal_Listener(T, C, S) {
		ctx     = ctx,
		emit_fn = fn,
		id      = self._last_id + 1,
	}

	self._last_id += 1

	self.listeners[signal_listener.id] = signal_listener

	return signal_listener.id
}

disconnect :: proc(self: ^Signal($T, $C, $S), id: Signal_Id) {
	if id in self.listeners {
		delete_key(&self.listeners, id)
	}
}
