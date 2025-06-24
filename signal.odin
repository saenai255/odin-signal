package signals

import "core:fmt"

Signal_Id :: int

Signal :: struct($T, $S, $C: typeid) {
	listeners: map[int](Signal_Listener(T, S, C)),
	_last_id:  Signal_Id,
}


init :: proc($T, $S, $C: typeid) -> ^Signal(T, S, C) {
	self := new(Signal(T, S, C))
	self.listeners = make(map[Signal_Id]Signal_Listener(T, S, C))
	self._last_id = 0
	return self
}

deinit :: proc(self: ^Signal($T, $S, $C)) {
	delete(self.listeners)
	free(self)
}

emit :: proc(self: ^Signal($T, $S, $C), sender: S, value: T) {
	for _, listener in self.listeners {
		listener.emit_fn(
			Signal_Payload(T, S, C) {
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
	self: ^Signal($T, $S, $C),
	ctx: C,
	fn: proc(payload: Signal_Payload(T, S, C)),
) -> Signal_Id {
	signal_listener := Signal_Listener(T, S, C) {
		ctx     = ctx,
		emit_fn = fn,
		id      = self._last_id + 1,
	}

	self._last_id += 1

	self.listeners[signal_listener.id] = signal_listener

	return signal_listener.id
}

disconnect :: proc(self: ^Signal($T, $S, $C), id: Signal_Id) {
	if id in self.listeners {
		delete_key(&self.listeners, id)
	}
}
