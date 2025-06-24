package signals

import "core:testing"

@(test)
single_signal_test :: proc(t: ^testing.T) {
	Ctx :: struct {
		t:              ^testing.T,
		calls:          int,
		expected_value: bool,
	}

	ctx := Ctx{t, 0, false}

	sig := init(^Ctx, any, bool)
	defer deinit(sig)

	connect(sig, &ctx, proc(payload: Signal_Payload(^Ctx, any, bool)) {
		testing.expect_value(payload.ctx.t, payload.value, payload.ctx.expected_value)
		payload.ctx.calls += 1
	})

	testing.expect_value(t, ctx.calls, 0)

	ctx.expected_value = true
	emit(sig, nil, true)
	testing.expect_value(t, ctx.calls, 1)

	ctx.expected_value = false
	emit(sig, nil, false)
	testing.expect_value(t, ctx.calls, 2)
}

@(test)
chained_signals_test :: proc(t: ^testing.T) {
	Ctx :: struct {
		t:          ^testing.T,
		result:     int,
		sig1_calls: int,
		sig2_calls: int,
		sig3_calls: int,
		sig1:       ^Signal(^Ctx, any, int),
		sig2:       ^Signal(^Ctx, any, int),
		sig3:       ^Signal(^Ctx, any, int),
	}

	ctx: Ctx
	ctx.t = t

	sig := init(^Ctx, any, int)
	defer deinit(sig)
	ctx.sig1 = sig

	sig2 := init(^Ctx, any, int)
	defer deinit(sig2)
	ctx.sig2 = sig2

	sig3 := init(^Ctx, any, int)
	defer deinit(sig3)
	ctx.sig3 = sig3

	connect(sig, &ctx, proc(payload: Signal_Payload(^Ctx, any, int)) {
		payload.ctx.sig1_calls += 1

		testing.expect_value(payload.ctx.t, payload.sender.id, nil)
		testing.expect_value(payload.ctx.t, payload.sender.data, nil)

		emit(payload.ctx.sig2, payload.ctx.sig1, payload.value * 2)
	})

	connect(sig2, &ctx, proc(payload: Signal_Payload(^Ctx, any, int)) {
		payload.ctx.sig2_calls += 1

		sender := payload.sender.(^Signal(^Ctx, any, int))
		testing.expect_value(payload.ctx.t, sender, payload.ctx.sig1)

		emit(payload.ctx.sig3, payload.ctx.sig2, payload.value * 2)
	})

	connect(sig3, &ctx, proc(payload: Signal_Payload(^Ctx, any, int)) {
		payload.ctx.sig3_calls += 1
		payload.ctx.result = payload.value * 2

		sender := payload.sender.(^Signal(^Ctx, any, int))
		testing.expect_value(payload.ctx.t, sender, payload.ctx.sig2)
	})

	emit(sig, nil, 1)

	testing.expect_value(t, ctx.sig1_calls, 1) // 1 * 2 = 2
	testing.expect_value(t, ctx.sig2_calls, 1) // 2 * 2 = 4
	testing.expect_value(t, ctx.sig3_calls, 1) // 4 * 2 = 8
	testing.expect_value(t, ctx.result, 8)

}
